#Include 'Protheus.ch'

user function DIAPI002()
    FwCallApp("ativos-diefra")
return 



Static function  JsToAdvpl(oWebChannel,cType,cContent) 


Local _aRetorno := {}
   
    Do Case
        // Se a interação que recebi for igual a mensagemJavascript
        Case cType == 'mensagemJavascript'
            // Imprimo a informação que recebi para trabalhar      
      
            oWebChannel:AdvPLToJS('enviar para a camada do Angular comandos JS')

        // Se a interação que recebi for igual a receberProtheus
        Case cType == 'receberProtheus'
            conout(cContent)
            ativo.api.diefra.u_lista('id', '11', 'id', 1, 10 )  
    End
 
return
