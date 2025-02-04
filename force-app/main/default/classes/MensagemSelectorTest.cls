@isTest
public class MensagemSelectorTest {
    
    @testSetup
    static void setup() {
        List<Mensagem__c> mensagens = new List<Mensagem__c>();
        
        for (Integer i = 0; i < 10; i++) {
            mensagens.add(new Mensagem__c(
                Certificado__c = 'Certificado' + i,
                ChaveExterna__c = 'ChaveExterna' + i,
                ChaveExternaMidia__c = 'ChaveExternaMidia' + i,
                ChaveExternaCliente__c = 'ChaveExternaCliente' + i,
                CodigoStatus__c = i, // Campo numérico
                Conteudo__c = 'Conteudo' + i,
                CorpoRequisicao__c = 'CorpoRequisicao' + i,
                DataHora__c = DateTime.now().addDays(i),
                De__c = '123-456-789' + i, // Exemplo de telefone
                NomeArquivo__c = 'NomeArquivo' + i,
                Status__c = 'Status' + i,
                Tipo__c = 'Tipo' + i,
                TipoMidia__c = 'TipoMidia' + i,
                LeadMensagem__c = null, // Assume que não há Leads inicialmente
                URLMidia__c = 'http://example.com/' + i
            ));
        }
        
        insert mensagens;
    }
    
    @isTest
    static void testObterMensagensPorIds() {
        // Obtendo IDs das mensagens inseridas
        List<Mensagem__c> allMensagens = [SELECT Id FROM Mensagem__c];
        Set<Id> idsMensagens = new Set<Id>();
        for (Mensagem__c mensagem : allMensagens) {
            idsMensagens.add(mensagem.Id);
        }
        
        // Chamando o método e validando o resultado
        Test.startTest();
        List<Mensagem__c> result = MensagemSelector.obterMensagensPorIds(idsMensagens);
        Test.stopTest();
        
        System.assertEquals(10, result.size(), 'O número de mensagens retornadas deve ser 10');
    }
    
    @isTest
    static void testObterMensagensPorChavesExternasClientes() {
        // Criando conjunto de chaves externas de clientes
        Set<String> chavesExternasClientes = new Set<String>();
        for (Integer i = 0; i < 5; i++) {
            chavesExternasClientes.add('ChaveExternaCliente' + i);
        }
        
        // Chamando o método e validando o resultado
        Test.startTest();
        List<Mensagem__c> result = MensagemSelector.obterMensagensPorChavesExternasClientes(chavesExternasClientes);
        Test.stopTest();
        
        System.assertEquals(5, result.size(), 'O número de mensagens retornadas deve ser 5');
    }
    
    
}