@IsTest
public class WhatsAppServiceTest {
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
    public class MockHttpResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Simular uma resposta de sucesso
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success","message":"Message sent successfully"}');
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
        String result = WhatsAppService.obterLeadPorId(lead.Id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo.');
    }

    @IsTest
    static void testObterMensagensPorChaveExternaCliente() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        String chaveExternaCliente = 'chave_teste';
        Test.startTest();
        String result = WhatsAppService.obterMensagensPorChaveExternaCliente(chaveExternaCliente);
        Test.stopTest();
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo.');
    }

    @IsTest
    static void testControlarDialogo() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        String result = WhatsAppService.controlarDialogo(lead.Id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo.');
    }

     @IsTest
    static void testControlarDialog() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead1 = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        String result = WhatsAppService.controlarDialogo(lead1.Id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo.');
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
        String result = WhatsAppService.enviarMidia(lead.Id, tipoArquivo, nomeArquivo, corpoArquivo);
        Test.stopTest();
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo.');
    }
    
    
    @isTest
      static void testEnviarMidiaErro() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        String tipoArquivo = 'image/pna';
        String nomeArquivo = 'teste.pna';
        String corpoArquivo = 'base64string';
        Test.startTest();
        String result = WhatsAppService.enviarMidia(lead.Id, tipoArquivo, nomeArquivo, corpoArquivo);
        Test.stopTest();
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo.');
    }
    
     @IsTest
    static void testEnviarMidias() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead leads = [SELECT Id FROM Lead LIMIT 1];
        String tipoArquivo = 'image/png';
        String nomeArquivo = 'teste.png';
        String corpoArquivo = 'base64string';
        Test.startTest();
        String result = WhatsAppService.enviarMidia(leads.Id, tipoArquivo, nomeArquivo, corpoArquivo);
        Test.stopTest();
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo.');
    }

    @IsTest
    static void testEnviarTemplatePadrao() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        String nomeTemplate = 'Template de Teste';
        Test.startTest();
        String result = WhatsAppService.enviarTemplatePadrao(lead.Id, nomeTemplate);
        Test.stopTest();
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo.');
    }

    @IsTest
    static void enviarMensagemComLeadTest() {

    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();

    insert empreendimento;

    Lead lead1 = [SELECT Id FROM Lead LIMIT 1];

    Lead testLead = new Lead(
        LastName = 'Teste',
        Email = 'teste@exemplo.com',
        LeadSource = 'WhatsApp',
        MobilePhone = '11987654321',
        EmpreendimentoInteresse__c = empreendimento.Id,
        Status = 'Novo'
    );

    insert testLead;

    String mensagemTexto = 'Olá, este é um teste de mensagem via WhatsApp!';

    Test.startTest();

    String result = WhatsAppService.enviarMensagem(lead1.Id, mensagemTexto);

    Test.stopTest();

    
    }

    @IsTest
    static void testEnviarMidiaInvalida() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        String tipoArquivo = 'invalid/type';
        String nomeArquivo = 'arquivo_invalido';
        String corpoArquivo = 'base64string_invalido';
        Test.startTest();
        try {
            String result = WhatsAppService.enviarMidia(lead.Id, tipoArquivo, nomeArquivo, corpoArquivo);
            System.assert(false, 'O método deveria ter lançado uma exceção para tipo de arquivo inválido.');
        } catch (Exception e) {
        }
        Test.stopTest();
    }

	@IsTest
    static void testEnviarMidiaComErro() {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        String tipoArquivo = 'image/png';
        String nomeArquivo = 'teste.png';
        String corpoArquivo = 'base65string';
        Test.startTest();
        try {
            String result = WhatsAppService.enviarMidia(lead.Id, tipoArquivo, nomeArquivo, corpoArquivo);
        } catch (Exception e) {
        //    System.assertEquals('Erro ao enviar mídia', e.getMessage(), 'A mensagem de erro não corresponde ao esperado.');
        }
        Test.stopTest();
    }

    
}