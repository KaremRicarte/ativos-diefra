#Include 'Protheus.ch'


User function DIAPI002()

  //  FwCallApp("ativos-diefra")

    ativo.api.diefra.u_listaLote('id', '11', 'id', 1, 10 )  

return 


/*
Static function  JsToAdvpl(oWebChannel,cType,cContent) 


Local _aRetorno := {}
   
    Do Case
        // Se a intera��o que recebi for igual a mensagemJavascript
        Case cType == 'mensagemJavascript'
            // Imprimo a informa��o que recebi para trabalhar      
      
            oWebChannel:AdvPLToJS('enviar para a camada do Angular comandos JS')

        // Se a intera��o que recebi for igual a receberProtheus
        Case cType == 'receberProtheus'
            conout(cContent)
            _aRetorno := ativo.api.diefra.u_listaAtivos('id', '11', 'id', 1, 10 )  
    End
 
return  */
