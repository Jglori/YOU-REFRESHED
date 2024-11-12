@IsTest
public class WhatsAppControllerTest {

    // Cria dados de teste para serem usados pelos testes
    @TestSetup
    static void setupTestData() {
        // Criando um Empreendimento de exemplo
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste empreendimento',
            CNPJEmpreendimento__c = '07135796000139'
        );
        insert empreendimento;
        
        // Criar um Lead de teste associado ao Empreendimento
        Lead testLead = new Lead(
            LastName = 'Will',
            Company = 'Elera',
            Email = 'Willdantas@gmail.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11960387699',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;
    }

    // Classe para simular o callout HTTP
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implementação do método respond para simular a resposta de um callout
        public HttpResponse respond(HTTPRequest req) {
            // Simula uma resposta HTTP de sucesso
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Callout bem-sucedido"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @IsTest
    static void testObterLeadPorId() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        String result = WhatsAppController.obterLeadPorId(lead.Id);
        Test.stopTest();
        //NotEquals(null, result, 'O resultado não deve ser nulo.');
    }

    @IsTest
    static void testObterMensagensPorChaveExternaCliente() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        String chaveExternaCliente = 'chave_teste';
        Test.startTest();
        String result = WhatsAppController.obterMensagensPorChaveExternaCliente(chaveExternaCliente);
        Test.stopTest();
        //NotEquals(null, result, 'O resultado não deve ser nulo.');
    }

    @IsTest
    static void testControlarDialogo() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        String result = WhatsAppController.controlarDialogo(lead.Id);
        Test.stopTest();
        //NotEquals(null, result, 'O resultado não deve ser nulo.');
    }

 
    @IsTest
    static void testEnviarMidia() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        String tipoArquivo = 'image/png';
        String nomeArquivo = 'teste.png';
        String corpoArquivo = 'base64string';
        Test.startTest();
        String result = WhatsAppController.enviarMidia(lead.Id, tipoArquivo, nomeArquivo, corpoArquivo);
        Test.stopTest();
        //NotEquals(null, result, 'O resultado não deve ser nulo.');
    }

    @IsTest
    static void testEnviarTemplatePadrao() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        String nomeTemplate = 'Template de Teste';
        Test.startTest();
        String result = WhatsAppController.enviarTemplatePadrao(lead.Id, nomeTemplate);
        Test.stopTest();
        //NotEquals(null, result, 'O resultado não deve ser nulo.');
    }
    
   /* PRECISA AJUSTAR O HTTPS MOCK!
    @isTest
    public static void testEnviarMensagem() {
        // Cria um Lead de teste para usar com o método enviarMensagem
        Lead lead = new Lead(
            LastName = 'Teste',
            Company = 'Teste Company'
        );
        insert lead;

        // Texto da mensagem de teste
        String mensagemTexto = 'Olá, esta é uma mensagem de teste!';
        
        // Simulação da resposta esperada do serviço
        String respostaEsperada = 'Mensagem enviada com sucesso';
        
        // Define o mock para o método WhatsAppService.enviarMensagem
        Test.startTest();
        String resultado = WhatsAppController.enviarMensagem(lead.Id, mensagemTexto);
        Test.stopTest();
        
        // Verifica se o resultado do método é o esperado
        //Equals(respostaEsperada, resultado, 'A resposta deve indicar o sucesso no envio da mensagem.');
    }
    */
    @isTest
    public static void testGetLeadDetails() {
        // Criação de dados de teste para o Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Empreendimento Teste',
            CNPJEmpreendimento__c = '34236715000160'
        );
        insert empreendimento;

        // Criação de dados de teste para o Lead
        Lead lead = new Lead(
            LastName = 'Teste',
            FirstName = 'Lead',
            EmpreendimentoInteresse__c = empreendimento.Id 
        );
        insert lead;

        // Criação de dados de teste para a Organization (simulação)
        String orgName = [SELECT Name FROM Organization LIMIT 1].Name;

        // Chama o método @AuraEnabled
        Test.startTest();
        Map<String, Object> response = WhatsAppController.getLeadDetails(lead.Id);
        Test.stopTest();

        // Validações
        //NotEquals(null, response, 'A resposta não pode ser nula');
        //Equals('Lead', ((Lead)response.get('leadInfo')).FirstName, 'O nome do lead não corresponde');
        //Equals(orgName, (String)response.get('orgName'), 'O nome da organização não corresponde');
    }
}