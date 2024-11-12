@isTest
private class LeadEmpreendimentosEspecificoRestTest {
    
    @isTest
    static void testBuscarEmpreendimentosComNome() {
        // Cria dados de teste para Empreendimento e Lead
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Test Empreendimento',
            CNPJEmpreendimento__c = '28455163000188'
        );
        insert empreendimento;

        // Cria Leads associados ao empreendimento
        Lead testLead1 = new Lead(
            FirstName = 'Lead1', 
            LastName = 'Test', 
            Company = 'Test Company', 
            Email = 'lead1@teste.com',
            Status = 'New',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead1;

        Lead testLead2 = new Lead(
            FirstName = 'Lead2', 
            LastName = 'Test', 
            Company = 'Test Company', 
            Email = 'lead2@teste.com',
            Status = 'New',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead2;

        // Simula a chamada HTTP GET com o nome do empreendimento
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/Lead/buscarEmpreendimentos';
        req.httpMethod = 'GET';
        req.addParameter('nome', 'Test Empreendimento');
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        LeadEmpreendimentosEspecificoRest.buscarEmpreendimentos();
        Test.stopTest();

        // Valida a resposta da API
        System.assertEquals(200, RestContext.response.statusCode, 'A chamada deve retornar 200 para leads encontrados.');
        String responseBody = RestContext.response.responseBody.toString();
        System.assert(responseBody.contains('Test Empreendimento'), 'O retorno deve conter o nome do empreendimento.');
        System.assert(responseBody.contains(testLead1.EmpreendimentoInteresse__c), 'O ID do primeiro empreendimento deve estar presente.');
        System.assert(responseBody.contains(testLead2.EmpreendimentoInteresse__c), 'O ID do segundo empreendimento deve estar presente.');
    }
    
    @isTest
    static void testBuscarEmpreendimentosSemNome() {
        // Simula a chamada HTTP GET sem o parâmetro 'nome'
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/Lead/buscarEmpreendimentos';
        req.httpMethod = 'GET';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        LeadEmpreendimentosEspecificoRest.buscarEmpreendimentos();
        Test.stopTest();

        // Valida a resposta da API para erro
        System.assertEquals(400, RestContext.response.statusCode, 'A chamada sem nome deve retornar 400.');
        System.assertEquals('Nome do empreendimento não fornecido na URL.', RestContext.response.responseBody.toString(), 'Deve retornar uma mensagem de erro apropriada.');
    }
    
   
}