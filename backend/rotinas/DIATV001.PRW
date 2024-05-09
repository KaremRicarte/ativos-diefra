#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'FwMBrowse.ch'
#Include 'FwMVCDef.ch'

/***********************************************************************
Autor: KAREM RICARTE
Data: 22/02/2022
Consultoria : Prox
Uso: Diefra
Tipo: Atualizações
Rotina: Ativo Fixo
Função: DIATV001
Info: Rotina para geração de inventário de Obras
************************************************************************/
User Function DIATV001()

	Local lCkFileZZ4 := ChkFile("ZZ4")
	Local lCkFileZZ5 := ChkFile("ZZ5")
	Local aArea      := {}

	Private oBrowse
	Private cCodVend
	
//	If xCodVen()

		If lCkFileZZ4 .And. lCkFileZZ5

			aArea := ZZ4->(GetArea())

			//Iniciamos a construção básica de um Browse.
			oBrowse := FWMBrowse():New()

			//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
			oBrowse:SetAlias("ZZ4")

			//Definimos o título que será exibido como método SetDescription
			oBrowse:SetDescription("INVENTARIO ATIVO")

			//Adiciona um filtro ao browse
			oBrowse:SetFilterDefault( "" )

			//Legendas no Browse
			
			oBrowse:AddLegend( "ZZ4_STATUS == 'A'","GREEN" ,"ATIVADO")
			oBrowse:AddLegend( "ZZ4_STATUS == 'D'","RED"   ,"DESATIVADO"  )


			//Ativamos a classe
			oBrowse:Activate()

			RestArea(aArea)

		Else 	
			MsgAlert("WorkArea não foi criada para as tabelas ZZ4 e ZZ5! Favor contatar o administrador do sistema!")
		Endif 	
		
//	Endif 	

Return

/*=================================================================
Autor: KAREM RICARTE
Data: 05/02/2020
Consultoria : Prox
Uso: Diefra
Info: Itens do menu (Browse)
*==================================================================*/
Static Function MenuDef()

	Local aRotina := {}

	//Opções do menu
	ADD OPTION aRotina TITLE "Pesquisar"  			ACTION 'PesqBrw' 				OPERATION 1  ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 			ACTION "VIEWDEF.DIATV001"		OPERATION 2  ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    			ACTION "VIEWDEF.DIATV001" 		OPERATION 3  ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    			ACTION "VIEWDEF.DIATV001" 		OPERATION 4  ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    			ACTION "VIEWDEF.DIATV001" 		OPERATION 5  ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir" 			ACTION "VIEWDEF.DIATV001"	 	OPERATION 8  ACCESS 0
	ADD OPTION aRotina TITLE "Copiar" 				ACTION "VIEWDEF.DIATV001" 		OPERATION 9  ACCESS 0
	ADD OPTION aRotina TITLE "Legenda" 				ACTION "U_xLegendaZZ4"  	 	OPERATION 10 ACCESS 0
//	ADD OPTION aRotina TITLE "Orçamento PDF"    	ACTION "U_XTSFIN03"		  	 	OPERATION 11 ACCESS 0
//	ADD OPTION aRotina TITLE "Enviar Orçamento"    	ACTION "U_XTSFIN04"		  	 	OPERATION 11 ACCESS 0
//	ADD OPTION aRotina TITLE "Estornar Financeiro" 	ACTION "U_XESTFIN"		  	 	OPERATION 11 ACCESS 0

Return(aRotina)

/*=================================================================
Autor: KAREM RICARTE
Data: 05/02/2020
Consultoria : Prox
Uso: Diefra
Info: Regras de visualização dos registros na tela
*==================================================================*/
Static Function ViewDef()

	Local oView
	Local oModel 	  := ModelDef()
	Local oStr1       := FWFormStruct(2,'ZZ4')
	Local oStr2       := FWFormStruct(2,'ZZ5')

	//Cria o objeto de View
	oView := FWFormView():New()
	oView:Refresh()

	//Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('VIEW_ZZ4', oStr1,'ZZ4MASTER')
	oView:AddGrid('VIEW_ZZ5' , oStr2,'ZZ5DETAIL')

	//Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox('CABEC',30)
	oView:CreateHorizontalBox('GRID' ,70)

	//Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('VIEW_ZZ4','CABEC')
	oView:SetOwnerView('VIEW_ZZ5','GRID')

	//Habilitando título
	oView:EnableTitleView('VIEW_ZZ4','Inventario')
	oView:EnableTitleView('VIEW_ZZ5','Itens')

	//Campo incremental
	oView:AddIncrementField('VIEW_ZZ5','ZZ5_ITEM')

	   //Não permite a edição dos campos do cabeçalho
//    oView:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
		
	//Removo os campos da grid
/*	oStr2:RemoveField('ZZ5_NUMERO')
	oStr2:RemoveField('ZZ5_CLIENT')
	oStr2:RemoveField('ZZ5_LOJA'  )
	oStr1:RemoveField('ZZ4_STATUS') */

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

Return(oView)

/*=================================================================
Autor: KAREM RICARTE
Data: 06/02/2020
Consultoria : Prox
Uso: Diefra
Info: Modelo do formulário
*==================================================================*/
Static Function ModelDef()

	Local oModel
	Local oStr1   := FWFormStruct(1,'ZZ4',/*bAvalCampo*/,/*lViewUsado*/) // Construção de uma estrutura de dados
	Local oStr2   := FWFormStruct(1,'ZZ5',/*bAvalCampo*/,/*lViewUsado*/) // Construção de uma estrutura de dados
	Local aZZ5Rel := {}

	//Cria o objeto do Modelo de Dados
	//Irie usar uma função DIATV001V que será acionada quando eu clicar no botão "Confirmar"
	oModel := MPFormModel():New('INVENTARIO', /*bPreValidacao*/, { | oModel | DIATV001V(oModel)} , /*{ | oMdl | LDFATA09C( oMdl ) }*/ ,, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields('ZZ4MASTER',/*cOwner*/,oStr1,{|oModel|DIATV001T(oModel)})

	oModel:AddGrid('ZZ5DETAIL','ZZ4MASTER',oStr2,/*bLinePre*/,/*linOk*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner

	//Fazendo o relacionamento entre o Pai e Filho
	aAdd(aZZ5Rel, {'ZZ5_NUMERO', 'ZZ4_NUMERO'})

	//IndexKey -> quero a ordenação e depois filtrado
	oModel:SetRelation('ZZ5DETAIL', aZZ5Rel, ZZ5->(IndexKey(1)))

	//Não repetir informações ou combinações
	//oModel:GetModel('ZZ5DETAIL'):SetUniqueLine({"ZZ5_FILIAL","ZZ5_NUMERO","ZZ5_PRODUT","ZZ5_CLIENT","ZZ5_LOJA"}) 

	oModel:SetDescription('INVENTARIO')

	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({"ZZ5_FILIAL","ZZ5_NUMERO","ZZ5_ITEM","ZZ5_CBASE"})
	
	//Inicializadores padrão
 	//oStr1:SetProperty('ZZ4_NUMERO',MODEL_FIELD_INIT,{||GETSXENUM()})
	oStr1:SetProperty('ZZ4_NUMERO',    MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZZ4", "ZZ4_NUMERO")')) 
	oStr1:SetProperty('ZZ4_USUARI',    MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'cUserName')) 
//	oStr1:SetProperty('ZZ4_CC',        MODEL_FIELD_WHEN,   {||  IIF(empty(ZZ4_CC), .T., .F.)     } )  
	oStr1:SetProperty('ZZ4_CC',        MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'ExistCpo("CTT", M->ZZ4_CC)'))  
	
	oStr1:SetProperty('ZZ4_CC',        MODEL_FIELD_VALID,   { || DIAPGRD() } )  
//	oStr1:SetProperty('ZZ4_CC',        MODEL_FIELD_NOUPD,   .T.)  
//	oStr2:SetProperty('ZZ5_NUMERO',    MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZZ4", "ZZ4_NUMERO")')) 
    //Validação de Campo
//	oStFilho:SetProperty('ZZ3_CODCD',  MODEL_FIELD_OBRIGAT, .F. ) 
	//oStr1:SetProperty('ZZ4_USUARI',MODEL_FIELD_INIT,cUserName)
    //oStr1:SetProperty('ZZ4_NUMERO',MODEL_FIELD_INIT,{})
	//oStr1:SetProperty('ZZ4_NOMVEN',MODEL_FIELD_INIT,{||AllTrim(Posicione("SA3",1,xFilial("SA3")+AvKey(cCodVend,"A3_COD"),"A3_NOME"))})

	//Setando as descrições
	oModel:SetDescription("INVENTARIO")
	oModel:GetModel('ZZ4MASTER'):SetDescription('INVENTARIO')
	oModel:GetModel('ZZ5DETAIL'):SetDescription('Itens')

Return(oModel)



static Function DIAPGRD() 

Local oModel := FWModelActive()  
Local oGrid  := oModel:GetModel('ZZ5DETAIL')
Local _cCC   := oModel:GetValue( 'ZZ5DETAIL', 'ZZ5_CBASE' )
lOCAL nX 
Local lRet     := .T. 
Local aResp := {} 




IF !Empty(_cCC) 
	Aviso( 'Atenção','O Lote já foi carregado por centro de custo e não pode ser alterado, somente cancelado e iniciado novamente')
	lRet	:= .F.
	return  lRet
EndIf  


aResp := xCodAtv()

/*
for nX := 1 to oGrid:Length()
    oGrid:GoLine(nX)
    oGrid:DeleteLine()
next    */

aSaveLine := FWSaveRows()
	nTamGD	:= oGrid:Length()
	For nX := 1 to len(aResp)
		If !Empty(oGrid:GetValue('ZZ5_CBASE')) //.Not. aTail(aResp[nX])	//Nao usado
			If oGrid:AddLine() == nTamGD	//Erro ao adicionar linha
				oModel:GetErrorMsgText() 
				Exit
			EndIf
		EndIf

		nTamGD	:= oGrid:Length()
		If .Not. oGrid:SetValue('ZZ5_CBASE',aResp[nX][1])	//Erro ao setar campo
			lRet	:= .F.
			oModel:GetErrorMsgText() 
			Exit 
		ElseIf  .Not. oGrid:SetValue('ZZ5_PLAQUE',aResp[nX][2])	//Erro ao setar campo 
			lRet	:= .F.
			oModel:GetErrorMsgText() 
			Exit 
		ElseIf  .Not. oGrid:SetValue('ZZ5_DESCRI',aResp[nX][3])	//Erro ao setar campo 
			lRet	:= .F.
			oModel:GetErrorMsgText() 
			Exit 
		
		EndIf
		
	
	Next
	FWRestRows( aSaveLine,/*oMdl*/)

return lRet


Static Function xCodAtv()

	Local cQuery   := ""
	Local cTemp    := GetNextAlias()
	Local _aAtivos, _aAtivos2 := {}
	Local oModel := FwModelActive()
	Local _cValor   := oModel:GetValue( 'ZZ4MASTER', 'ZZ4_CC' )
	
	cQuery := " SELECT N3_CBASE, N1_DESCRIC, N1_CHAPA  FROM "+RetSQLName("SN3")+" SN3" 
	cQuery += " INNER JOIN "+RetSQLName("SN1")+" SN1
	cQuery += " ON N3_CBASE =  N1_CBASE AND N3_FILIAL = N1_FILIAL 
	cQuery += " WHERE N3_FILIAL = '"+xFilial("SN3")+"'"
	cQuery += "		AND N3_CCUSTO  = '"+_cValor+"'"
	cQuery += "	    AND N3_DTBAIXA = ''
	cQuery += "		AND SN3.D_E_L_E_T_ = '' "
	
	If Select(cTemp) > 0
    	(cTemp)->(DbCloseArea())
    	cTemp := GetNextAlias()
   	Endif
	
	cQuery := ChangeQuery(cQuery)
    
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)

	DbSelectArea(cTemp)

	_aAtivos2 := {}

	While !Eof()
		
		_aAtivos := {} 
		
		aadd(_aAtivos, (cTemp)->N3_CBASE)
		aadd(_aAtivos, (cTemp)->N1_CHAPA)
		aadd(_aAtivos, (cTemp)->N1_DESCRIC)
	

		aadd(_aAtivos2 ,_aAtivos)

		DbSkip()

	EndDo 
	
/*
If Empty(cCodVend)
	lRet := .F.
	MsgAlert("Favor solicitar o seu cadastro de vendedor para que possa acessar esta rotina!")
Endif 
*/ 
Return (_aAtivos2)

/*=================================================================
Autor: KAREM RICARTE
Data: 06/02/2020
Consultoria : Prox
Uso: Diefra
Info: Adiciono uma estrutura de formulário de edição por campo
*==================================================================*/
Static Function DIATV001T(oModel)

	Local lRet  := .T.
	Local oStr2 := oModel:GetModel('ZZ5DETAIL')

Return(lRet)

/*=================================================================
Autor: KAREM RICARTE
Data: 06/02/2020
Consultoria : Prox
Uso: Diefra
Info: Validações ao confirmar uma ação nOpc (Inclus.,Alter.,Exclu.)
*==================================================================*/
Static Function DIATV001V(oModel)

	Local lRet    := .T.
	Local oStr1   := oModel:GetModel('ZZ4MASTER' )
	Local oStr2   := oModel:GetModel('ZZ5DETAIL' )
	Local nOpc    := oModel:GetOperation()
	Local nTotLin := oStr2:Length() //Verifico o total de linhas que há inseridas na grid
	Local nX      := 0
	Local aArea   := GetArea()

	//Início de transação
	Begin Transaction

		//Validação de alteração
		If nOpc ==  4 .And. M->ZZ4_STATUS == '3'
		
			lRet := .F.
			MsgAlert("Orçamento já encontra-se aprovado! Favor criar um novo orçamento!")

		Elseif nOpc == 4 .And. M->ZZ4_STATUS == '2'

			If MsgYesNo("Para que seja efetivada a alteração o orçamento mudará o status para 'Aberto'! Confirma a ação?")
				M->ZZ4_STATUS := "1"
			Else 	
				lRet := .F.
				MsgAlert("Operação cancelada pelo usuário!")	
			Endif 	

		Endif
		// ---

		If lRet

			For nX := 1 To nTotLin

				//Função para ir para próxima linha que consta na variável nX
				oStr2:GoLine(nX)

				//Carrego as informações do cabeçalho para os campos ocultos da grid 
				oStr2:LoadValue('ZZ5_FILIAL',oStr1:GetValue('ZZ4_FILIAL'))
			//	oStr2:LoadValue('ZZ5_NUMERO',oStr1:GetValue('ZZ4_NUMERO'))
			//	oStr2:LoadValue('ZZ5_CLIENT',oStr1:GetValue('ZZ4_CLIENT'))
			//	oStr2:LoadValue('ZZ5_LOJA'  ,oStr1:GetValue('ZZ4_LOJA'  ))

			Next nX

		Endif 

	//Final de transação
	End Transaction

	//Restauro a área trabalhada
	RestArea(aArea)

	FwModelActive(oModel,.T.)

Return(lRet)

/*=================================================================
Autor: KAREM RICARTE
Data: 23/02/2022
Consultoria : Prox
Uso: Diefra
Info: Validação para verificar se o usuário possui permissão na rotina
*==================================================================*/

/*=================================================================
Autor: KAREM RICARTE
Data: 23/02/2022
Consultoria : Prox
Uso: Diefra
Info: Gatilho para preenchimento da descrição do grupo de produto
*==================================================================*/
User Function xGatZZ51()

	Local oView      := FwViewActive()
	Local oZZ5Detail := oView:GetModel():GetModel("ZZ5DETAIL")
	Local cDesc      := AllTrim(Posicione("SB1",1,xFilial("SB1")+oZZ5Detail:GetValue('ZZ5_PRODUT'),'B1_DESC'))

	//Atualizo o campo da grid com a descrição do grupo de produtos
	oZZ5Detail:LoadValue("ZZ5_DESCRI",cDesc)

Return(cDesc)

/*=================================================================
Autor: KAREM RICARTE
Data: 23/02/2022
Consultoria : Prox
Uso: Diefra
Info: Gatilho para preenchimento do preço
*==================================================================*/
User Function xGatZZ52()

	Local oView      := FwViewActive()
	Local oZZ5Detail := oView:GetModel():GetModel("ZZ5DETAIL")
	Local nPreco     := Posicione("SB1",1,xFilial("SB1")+oZZ5Detail:GetValue('ZZ5_PRODUT'),'B1_PRV1')

	//Atualizo o campo da grid com o preço de venda do produto e o valor base 
	oZZ5Detail:LoadValue("ZZ5_PRCVEN",nPreco)
	oZZ5Detail:LoadValue("ZZ5_VLBASE",nPreco)

Return(nPreco)

/*=================================================================
Autor: KAREM RICARTE
Data: 23/02/2022
Consultoria : Prox
Uso: Diefra
Info: Gatilho para preenchimento do valor total 
*==================================================================*/
User Function xGatZZ53()

	Local oView      := FwViewActive()
	Local oZZ5Detail := oView:GetModel():GetModel("ZZ5DETAIL")
	Local nTotal     := oZZ5Detail:GetValue('ZZ5_QTDVEN') * oZZ5Detail:GetValue('ZZ5_PRCVEN') 

	//Atualizo o campo da grid com a descrição do grupo de produtos
	oZZ5Detail:LoadValue("ZZ5_VALOR",nTotal)

Return(nTotal)

/*=================================================================
Autor: KAREM RICARTE
Data: 11/05/2022
Consultoria : Prox
Uso: Diefra
Info: Gatilho para preenchimento do desconto(R$)
*==================================================================*/
User Function xGatZZ54()

	Local oView      := FwViewActive()
	Local oZZ5Detail := oView:GetModel():GetModel("ZZ5DETAIL")
	Local nDesconto  := IIf(oZZ5Detail:GetValue('ZZ5_DESCVL') > 0,(oZZ5Detail:GetValue('ZZ5_QTDVEN') * oZZ5Detail:GetValue('ZZ5_PRCVEN')) - oZZ5Detail:GetValue('ZZ5_DESCVL'),oZZ5Detail:GetValue('ZZ5_QTDVEN') * oZZ5Detail:GetValue('ZZ5_PRCVEN'))

	//Atualizo o campo da grid com a descrição do grupo de produtos
	If !Empty(oZZ5Detail:GetValue('ZZ5_DESCPE'))
		oZZ5Detail:LoadValue("ZZ5_DESCPE",0)
		oZZ5Detail:LoadValue("ZZ5_VALOR",oZZ5Detail:GetValue('ZZ5_QTDVEN') * oZZ5Detail:GetValue('ZZ5_VLBASE') - oZZ5Detail:GetValue('ZZ5_DESCVL') )
	Else 	
		oZZ5Detail:LoadValue("ZZ5_VALOR",nDesconto)
	Endif 

Return(nDesconto)

/*=================================================================
Autor: KAREM RICARTE
Data: 11/05/2022
Consultoria : Prox
Uso: Diefra
Info: Gatilho para preenchimento do desconto(%)
*==================================================================*/
User Function xGatZZ55()

	Local oView      := FwViewActive()
	Local oZZ5Detail := oView:GetModel():GetModel("ZZ5DETAIL")
	Local nDesconto  := IIf(oZZ5Detail:GetValue('ZZ5_DESCPE') > 0,(oZZ5Detail:GetValue('ZZ5_QTDVEN') * oZZ5Detail:GetValue('ZZ5_PRCVEN')) * oZZ5Detail:GetValue('ZZ5_DESCPE') / 100,oZZ5Detail:GetValue('ZZ5_QTDVEN') * oZZ5Detail:GetValue('ZZ5_PRCVEN'))
	
	nDesconto := (oZZ5Detail:GetValue('ZZ5_QTDVEN') * oZZ5Detail:GetValue('ZZ5_PRCVEN')) - nDesconto

	If nDesconto > 0

		//Atualizo o campo da grid com a descrição do grupo de produtos
		If !Empty(oZZ5Detail:GetValue("ZZ5_DESCVL"))
			oZZ5Detail:LoadValue("ZZ5_DESCVL",0)
			nDesconto := (oZZ5Detail:GetValue('ZZ5_QTDVEN') * oZZ5Detail:GetValue('ZZ5_VLBASE')) * oZZ5Detail:GetValue('ZZ5_DESCPE') / 100
			nDesconto := oZZ5Detail:GetValue('ZZ5_QTDVEN') * oZZ5Detail:GetValue('ZZ5_VLBASE') - nDesconto 
			oZZ5Detail:LoadValue("ZZ5_VALOR",nDesconto)
		Else 	
			oZZ5Detail:LoadValue("ZZ5_VALOR",nDesconto)
		Endif 

	Else 	
		nDesconto := oZZ5Detail:GetValue('ZZ5_QTDVEN') * oZZ5Detail:GetValue('ZZ5_PRCVEN')
	Endif 

Return(nDesconto)

/*=================================================================
Autor: KAREM RICARTE
Data: 23/02/2022
Consultoria : Prox
Uso: Diefra
Info: Gatilho para preenchimento do nome do cliente
*==================================================================*/
User Function xGatZZ41()

	Local oView      := FwViewActive()
	Local oZZ4Master := oView:GetModel():GetModel("ZZ4MASTER")
	Local cNome      := AllTrim(Posicione("SA1",1,xFilial("SA1")+oZZ4Master:GetValue('ZZ4_CLIENT')+oZZ4Master:GetValue('ZZ4_LOJA'),'A1_NOME'))

	//Atualizo o campo da grid com a descrição do grupo de produtos
	oZZ4Master:LoadValue("ZZ4_NOMCLI",cNome)

Return(cNome)

/*=================================================================
Autor: KAREM RICARTE
Data: 06/02/2020
Consultoria : Prox
Uso: Diefra
Info: Legendas
*==================================================================*/
User Function xLegendaZZ4()

	Local aLegenda := {}


	aAdd(aLegenda,{"BR_VERMELHO","Inventário Desativado"})
	aAdd(aLegenda,{"BR_VERDE","Inventário Ativado"})

	BrwLegenda("Legendas do status do Inventário","Legenda",aLegenda)

Return 

/*=================================================================
Autor: KAREM RICARTE
Data: 11/05/2022
Consultoria : Prox
Uso: Diefra
Info: Estorno do Financeiro - Contas a Receber
*==================================================================*/
User Function xEstFin()

	Local nOpc    := 5
	Local aIncFin := {}
	Local cChave  := ZZ4->ZZ4_FILIAL+ZZ4->ZZ4_NUMERO
	Local lErro   := .F.

	Private lMsErroAuto := .F. 
	
	DbSelectArea("SE1")
	
	SE1->(DbGoTop())
	SE1->(DbOrderNickName("ORCAMENTO"))
	SE1->(DbSeek(cChave)) 

	Begin Transaction 
	
		While SE1->(!Eof()) .And. (SE1->E1_FILIAL + SE1->E1_XORCAME == cChave)
			
				aIncFin := {;
							{"E1_FILIAL"    , SE1->E1_FILIAL  	              ,Nil},;
							{"E1_PREFIXO" 	, SE1->E1_PREFIXO  	              ,Nil},;    
							{"E1_TIPO"    	, SE1->E1_TIPO 		              ,Nil},;
							{"E1_PARCELA"  	, SE1->E1_PARCELA                 ,Nil},;
							{"E1_NATUREZ" 	, SE1->E1_NATUREZ 	              ,Nil},;
							{"E1_CLIENTE" 	, SE1->E1_CLIENTE  	              ,Nil},;
							{"E1_LOJA"    	, SE1->E1_LOJA		              ,Nil},;		           
							{"E1_EMISSAO" 	, SE1->E1_EMISSAO                 ,Nil},;
							{"E1_VENCTO" 	, SE1->E1_VENCTO                  ,Nil},;
							{"E1_VENCREA" 	, SE1->E1_VENCREA                 ,Nil},;
							{"E1_VALOR"   	, SE1->E1_VALOR  	              ,Nil},;
							{"E1_XORCAME"   , SE1->E1_XORCAME                 ,Nil};
						}
			
				MsExecAuto({|x,y| FINA040(x,y)},aIncFin,nOpc)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
				
				If lMsErroAuto

					lErro := .T.	
					
					MostraErro()

					DisarmTransaction()

					Exit 
					
				Endif 

			SE1->(DbSkip())

		EndDo	
		
	End Transaction	

	If !lErro

		RecLock("ZZ4",.F.)
		ZZ4->ZZ4_STATUS := "1" //Status em Aberto
		ZZ4->(MsUnlock())

		MsgInfo("Titulo(s) estornado(s) com sucesso!","Atenção")

	Endif 

Return 
