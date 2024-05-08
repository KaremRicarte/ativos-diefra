#INCLUDE 'RWMake.ch'
#INCLUDE 'Totvs.ch'
#INCLUDE 'ParmType.ch'
#INCLUDE 'FwMvcDef.ch'

Static cVersao	:= "1.00"
Static cDtVersao:= "08/05/2024"

/*=================================================================================================
Autor      : Cirilo Rocha
Data       : 08/05/2024
Consultoria: Prox
Cliente    : Diefra
Módulo     : SigaATF
Ticket     : 38771
Info       : Tela de aprovação dos lotes de inventário
=================================================================================================*/
#DEFINE cAliasCab	'ZZ4'
#DEFINE cAliasGrid	'ZZ5'
#DEFINE	cTitulo		'Cadastro de '+FwSX2Util():GetX2Name(cAliasCab)

#DEFINE MODEL_CAB	'MODEL_'+cAliasCab
#DEFINE MODEL_GRID	'MODEL_'+cAliasGrid

//Parâmetros usados em MVC
#Define nTP_MODEL	1
#Define nTP_VIEW	2
#Define _MsgLinha_		FileNoExt(ProcSource())+'('+StrZero(ProcLine(),5)+')'

#xTranslate _PrxFieldGet(<cCampo>) => ;
	FieldGet(FieldPos(<cCampo>))
//-------------------------------------------------------------------------------------------------
User Function DIATV002()

	//-- Declaração de variáveis ----------------------------------------------
	Private oMBrw	:= BrowseDef()						AS Object	//-- Privado por causa das legendas

	oMainWnd:cTitle(Left(oMainWnd:cTitle,Rat(' [',oMainWnd:cTitle))+'['+FileNoExt(ProcSource())+'_v'+cVersao+' | '+cDtVersao+']')		//-- Mostra versão no título da janela

	oMBrw:Activate()

Return

/*=================================================================================================
Autor      : Cirilo Rocha
Data       : 15/01/2024 
Info       : BrowseDef monta o browser utilizado pela rotina
=================================================================================================*/
Static function BrowseDef()							AS Object
	
	//-- Declaração de variáveis ----------------------------------------------
	Local oMBrw										AS Object

	//-- Inicializa Variáveis -------------------------------------------------
	oMBrw 	:= FwMBrowse():New()

	//Definimos o titulo que sera exibido como metodo SetDescription
	oMBrw:SetDescription(cTitulo)

	//Definimos a tabela que sera exibida na Browse utilizando o metodo SetAlias
	oMBrw:SetAlias(cAliasGrid)		//-- Browser é baseado na tabela GRID

	oMBrw:SetMenuDef('DIATV002')	//Nome do programa fonte
	//oMBrw:SetOnlyFields( {'ZZ4_FILIAL','ZZ4_PONTCO','ZZ4_DTINI'} )

	//Adiciona um filtro ao browse
	//oMBrw:SetFilterDefault( "(ZZ4_ATIVO == '1')" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1 = Ativo, 2 = Inativo )

	oMBrw:AddLegend( ' ZZ5_OBRA == "S" '						, 'GREEN' 	, 'Ativo Presente'	)
	oMBrw:AddLegend( ' ZZ5_OBRA == " " '						, 'WHITE' 	, 'Não Inventariado')
	oMBrw:AddLegend( ' ZZ5_OBRA == "N" .AND. EMPTY(ZZ5_USRAPR) ', 'YELLOW' 	, 'Ativo Ausente - Não Aprovado')
	oMBrw:AddLegend( ' ZZ5_OBRA == "N" .AND. !EMPTY(ZZ5_USRAPR)', 'ORANGE' 	, 'Ativo Ausente - Aprovado')

	//Desliga a exibicao dos detalhes
	oMBrw:DisableDetails()

Return oMBrw

/*=================================================================================================
Autor      : Cirilo Rocha
Data       : 08/05/2024
Info       : Monta o aRotina da tela
=================================================================================================*/
Static Function MenuDef()	AS Array

	//-- Declaração de variáveis ----------------------------------------------
	Local aRotina 	:= {}	AS Array

	//-- Inicializa Variáveis -------------------------------------------------
	aAdd( aRotina,{ 'Visualizar'	, 'U_DIATV02A'					, 0, OP_VISUALIZAR	,0, NIL})
	aAdd( aRotina,{ 'Aprovação'		, 'U_DIATV02B'					, 0, OP_ALTERAR		,0, NIL})
	aAdd( aRotina,{ 'Legendas' 		, 'oMBrw:aLegends[1][2]:View()'	, 0, OP_VISUALIZAR	,0, NIL})

Return( aRotina )
/*=================================================================================================
Autor      : Cirilo Rocha
Data       : 08/05/2024
Info       : Montar as estrutura de dados e as regras
=================================================================================================*/
Static Function ModelDef()							AS Object

	//-- Declaração de variáveis ----------------------------------------------
	Local xAux										AS Array
	Local oModel    								AS Object
	Local oGrid										AS Object
	Local oStruCab  								AS Object
	Local oStruGrid 								AS Object

	// Construção de uma estrutura de dados
	oStruCab := FwFormStruct( nTP_MODEL, cAliasCab , /*bAvalCampo*/,/*lViewUsado*/ ) 
	oStruGrid:= FwFormStruct( nTP_MODEL, cAliasGrid, /*bAvalCampo*/,/*lViewUsado*/ )

	oStruCab:SetProperty('*'		  , MODEL_FIELD_NOUPD,.T.)	//-- Nenhum campo do cabeçalho é editável
	
	//-- Apenas o campo ZZ5_APROVA do Grid são editável
	oStruGrid:SetProperty('*'		  , MODEL_FIELD_NOUPD,.T.)
	oStruGrid:SetProperty('ZZ5_APROVA', MODEL_FIELD_NOUPD,.F.)

	xAux := FwStruTrigger( 'ZZ5_APROVA', 'ZZ5_APROVA','U_DIATV02G()')
	oStruGrid:AddTrigger(xAux[1],xAux[2],xAux[3],xAux[4])	//Adiciona gatilho!

	oModel   := MpFormModel():New(	'DIATV02M'				,;	//01	//Não pode ter o mesmo nome do fonte
									/*bPreVld*/				,; 	//02
									{ |oMod| sfTudoOK(oMod)},;	//03 bPostVld
									/*bSave*/				,;	//04
									/*bCancel*/				)	//05

	oModel:SetVldActivate({|oMod| sfPreVld( oMod ) })	//Pré-validação (funciona melhor que bPreVld no New)

	//-- Cabeçalho ------------------------------------------------------------
	oModel:AddFields(	MODEL_CAB	,;	//01
						/*cOwner*/	,;	//02
						oStruCab	,;	//03
						/*bPre*/	,;	//04
						/*bPost*/	,;	//05
						/*bLoad*/	) 	//06

	oModel:GetModel(MODEL_CAB):SetPrimaryKey( { 'ZZ4_FILIAL','ZZ4_CC','ZZ4_MESANO' } )

	// Adiciona a Descrição do Componente do Modelo de Dados
	oModel:SetDescription(cTitulo)

	// Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:GetModel( MODEL_CAB ):SetDescription( cTitulo )

 	//-- Itens ----------------------------------------------------------------
 	oModel:AddGrid(	MODEL_GRID		,;	//01 cID Modelo
 					MODEL_CAB		,;	//02 cIDOwner
 					oStruGrid 		,;	//03 oStruct
 					/*bLinePre*/	,;	//04 bLinePre
 					/*bLinhaOK*/	,;	//05 Validação equivale ao LinhaOK
 					/*bPre*/		,;	//06 bPre
 					/*bPost*/		,;	//07 bPost
 					{|oFldMod,lCopy| sfLoadField(oFldMod,lCopy) } ) 	//08 bLoad

 	oModel:SetRelation( MODEL_GRID , {	{ 'ZZ5_FILIAL'	, "FWxFilial('ZZ5')"},;
										{ 'ZZ5_CC'		, 'ZZ4_CC' 			},;
 	 									{ 'ZZ5_MESANO'	, 'ZZ4_MESANO'		}}, (cAliasGrid)->(IndexKey(1) ) )

 	oGrid	:= oModel:GetModel( MODEL_GRID )
	oGrid:SetOptional( .T. )
	oGrid:SetNoInsertLine( .T. )
	oGrid:SetNoDeleteLine( .T. )
 	oGrid:SetUniqueLine( { 'ZZ5_ITEM','ZZ5_CC','ZZ5_MESANO' } )
 //	oGrid:SetMaxLine(99)
	oGrid:SetDescription( FwSX2Util():GetX2Name(cAliasGrid)+' ('+cAliasGrid+')' )

Return( oModel )

/*=================================================================================================
Autor      : Cirilo Rocha
Data       : 08/05/2024
Info       : Montar a interface da tela 
=================================================================================================*/
Static Function ViewDef();
					AS Object

	//-- Declaração de variáveis ----------------------------------------------
	Local oModel    := FWLoadModel('DIATV002')		AS Object	//-- Nome do fonte onde está o modelo
	Local oView    	:= FWFormView():New()			AS Object

	Local oStruCab									AS Object
	Local oStruGrid									AS Object

	//-------------------------------------------------------------------------
	oView:SetModel( oModel )
//	oView:SetContinuousForm()

	oStruCab 	:= FwFormStruct( nTP_VIEW, cAliasCab)
	oView:AddField( 'VIEW_'+cAliasCab	, oStruCab	, MODEL_CAB )

	oStruGrid 	:= FwFormStruct( nTP_VIEW, cAliasGrid)
	oView:AddGrid ( 'VIEW_'+cAliasGrid	, oStruGrid	, MODEL_GRID )

	//-- Painel Superior ------------------------------------------------------
	oView:CreateVerticalBox(  'PAINEL_PRINCIPAL', 100 )

		oView:CreateHorizontalBox( 'CABECALHO' ,  33, 'PAINEL_PRINCIPAL' )
		oView:SetOwnerView( 'VIEW_'+cAliasCab 	, 'CABECALHO')	//Relaciona o identificador (ID) da View com o 'box' para exibição
		
		oView:EnableTitleView('VIEW_'+cAliasGrid,oModel:GetModel( MODEL_GRID ):GetDescription())
		oView:CreateHorizontalBox( 'GRID_'+cAliasGrid, 66, 'PAINEL_PRINCIPAL',,/*cIDFolder*/,/*cIDSheet*/ )
		oView:SetOwnerView( 'VIEW_'+cAliasGrid 	, 'GRID_'+cAliasGrid )	//Relaciona o identificador (ID) da View com o 'box' para exibição
		
	//Fim PAINEL_PRINCIPAL

Return( oView )

/*=================================================================================================
Autor      : Cirilo Rocha
Data       : 08/05/2024
Info       : Faz a carga dos dados do Grid, customizado para carregar apenas os itens com pendências
=================================================================================================*/
Static Function sfLoadField(oFieldModel	,;
							lCopy		)			AS Array

	//Declaracao de variaveis----------------------------------------------------------------------
	Local aDados									AS Array
	Local aLoad 	:= {}							AS Array
	Local aFields									AS Array
	Local cChvDoc									AS Character
	Local nX										AS Numeric

	//Parametros da rotina-------------------------------------------------------------------------
	ParamType 0		VAR oFieldModel		AS Object
	ParamType 1		VAR lCopy			AS Logical

	//---------------------------------------------------------------------------------------------
	aFields	:= @oFieldModel:oFormModelStruct:aFields
	cChvDoc		:= ZZ4->(ZZ4_FILIAL+ZZ4_NUMERO)
	ZZ5->(dbSetOrder(1))
	ZZ5->(dbSeek(cChvDoc))
	While 	ZZ5->(!EOF()) .And. ;
			ZZ5->(ZZ5_FILIAL+ZZ5_NUMERO) == cChvDoc
		//-- Apenas itens com divergência ---
		If ZZ5->ZZ5_OBRA == 'N'
			FwFreeArray(aDados)
			aDados	:= {}
			For nX := 1 to Len(aFields)
				aAdd(aDados,ZZ5->(_PrxFieldGet(aFields[nX][MODEL_FIELD_IDFIELD])))
			Next
			aAdd(aLoad, {ZZ5->(Recno()),aDados} )
		EndIf
		ZZ5->(dbSkip())
	EndDo

Return aLoad

/*=================================================================================================
Autor      : Cirilo Rocha
Data       : 08/05/2024
Info       : Pré-validação do modelo
=================================================================================================*/
Static Function sfPreVld( oMod )					AS Logical

	//Declaracao de variaveis----------------------------------------------------------------------
	Local lRet		:= .T.							AS Logical
	Local nOperation 								AS Numeric

	//Parametros da rotina-------------------------------------------------------------------------
	ParamType 0		VAR oMod						AS Object

	//Inicializa Variaveis-------------------------------------------------------------------------
	nOperation	:= oMod:GetOperation()

	If .Not. sfVldPend()
		lRet	:= .F.
		Help('',1,_MsgLinha_,,'Lote selecionado do CC '+ZZ4->ZZ4_CC+' e mês '+;
			Transform(ZZ4->ZZ4_MESANO,'@R 99/9999')+' NÃO possui itens pendentes de '+;
			'aprovação.',1,,,,,,,/*{'Solucao'}*/)
	EndIf

Return lRet

/*=================================================================================================
Autor      : Cirilo Rocha
Data       : 08/05/2024
Info       : Verifica se existem itens pendentes de aprovação
=================================================================================================*/
Static Function sfVldPend()							AS Logical
	
	//-- Declaracao de variaveis ----------------------------------------------
	Local lRet										AS Logical

	Local cQuery									AS Character
	Local oQry										AS Object

	//-------------------------------------------------------------------------
	cQuery	:= ""
	cQuery	+= "SELECT TOP 1 1 QTDREG "+CRLF
	cQuery	+= "FROM "+FWSX2Util():GetFile('ZZ5')+" ZZ5 "+CRLF
	cQuery	+= "WHERE ZZ5.D_E_L_E_T_ <> '*' "+CRLF
	cQuery	+= "	AND ZZ5_FILIAL	= ? "+CRLF
	cQuery	+= "	AND ZZ5_CC 		= ? "+CRLF
	cQuery	+= "	AND ZZ5_MESANO 	= ? "+CRLF
	cQuery	+= "	AND ZZ5_OBRA = 'N' "+CRLF
	cQuery	+= "	AND ZZ5_APROVA = ' ' "+CRLF
	oQry	:= FwExecStatement():New(cQuery)
	oQry:setString(1,ZZ4->ZZ4_FILIAL)
	oQry:setString(2,ZZ4->ZZ4_CC)
	oQry:setString(3,ZZ4->ZZ4_MESANO)

	lRet	:=  oQry:execScalar('QTDREG') > 0		//oQry:getFixQuery() retorna query processada

	oQry:Destroy()
	FreeObj(oQry)

Return lRet

/*=================================================================================================
Autor      : Cirilo Rocha
Data       : 08/05/2024
Info       : Chama a rotina de visualização dos lotes, precisa ser assim porque o browser desta
				tela é baseado na ZZ5 então preciso posicionar na ZZ4 para poder abrir
=================================================================================================*/
User Function DIATV02A()

	//-- Pré-Validação do registro --------------------------------------------
	ZZ4->(DbSetOrder(1))
	ZZ4->(dbSeek(FwXFilial('ZZ4')+ZZ5->ZZ5_NUMERO))
	
	FWExecView(	'Visualizar','DIATV001',MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOK*/,/*bOk*/,;
				/*nPercReducao*/,/*aButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/,/*oModel*/)

Return

/*=================================================================================================
Autor      : Cirilo Rocha
Data       : 08/05/2024
Info       : Rotina para aprovação dos itens inventariados, feito aqui para poder posicionar a tabela
				ZZ4 do cabeçalho da rotina.
=================================================================================================*/
User Function DIATV02B()

	//-- Declaracao de variaveis ----------------------------------------------
	Local aButtons									AS Array

	//-- Pré-Validação do registro --------------------------------------------
	ZZ4->(DbSetOrder(1))
	ZZ4->(dbSeek(FwXFilial('ZZ4')+ZZ5->ZZ5_NUMERO))
	
	aButtons:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},;
				{.T.,"Salvar"},{.T.,"Fechar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},;
				{.T.,Nil},{.T.,Nil},{.T.,Nil}}

	FWExecView(	'Aprovação','DIATV002',MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOK*/,/*bOk*/,;
				/*nPercReducao*/,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/,/*oModel*/)

Return

/*=================================================================================================
Autor      : Cirilo Rocha
Data       : 08/05/2024
Info       : Função chamada no gatilho do campo ZZ5_APROVA para preencher os dados do aprovador
=================================================================================================*/
User Function DIATV02G()							AS Character
	
	//-- Declaracao de variaveis ----------------------------------------------
	Local cRet										AS Character
	Local oMod := FWModelActive() 					AS Object		//Carrega o modelo ativo (se informar o parâmetro muda o objeto ativo)

	cRet	:= oMod:GetValue(MODEL_GRID,'ZZ5_APROVA')
	If 	.Not. Empty(cRet) .And. ;
		Empty(oMod:GetValue(MODEL_GRID,'ZZ5_USRAPR'))

		oMod:LoadValue(MODEL_GRID,'ZZ5_USRAPR',__cUserID+'-'+FwGetUserName(__cUserID))
		oMod:LoadValue(MODEL_GRID,'ZZ5_DTAPRO',Date())
		oMod:LoadValue(MODEL_GRID,'ZZ5_HRAPRO',Left(Time(),5))
	EndIf	

Return cRet

/*=================================================================================================
Autor      : Cirilo Rocha
Data       : 08/05/2024
Info       : Validação se todos os itens pendentes foram aprovados ou rejeitados
=================================================================================================*/
Static Function sfTudoOK(oMod)					AS Logical

	//-- Declaracao de variaveis ----------------------------------------------
	Local lRet		:= .T.							AS Logical
	Local nX										AS Numeric
	Local oGrid		:= oMod:GetModel(MODEL_GRID)	AS Object

	//-------------------------------------------------------------------------
	For nX := 1 to oGrid:Length()
		If Empty(oGrid:GetValue('ZZ5_APROVA',nX))
			lRet	:= .F.
			Help('',1,_MsgLinha_,,'Existem itens pendentes de aprovação/rejeição. Item '+cValToChar(nX),1,,,,,,,;
						{'Todos os itens precisam ter o campo aprovação preenchido.'})
		EndIf
	Next

Return lRet
