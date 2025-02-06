@isTest
private class LeadEmpreendimentosRestResourceTest {
    
    @isTest
    static void testBuscarEmpreendimentos() {
        // Criando uma conta de teste
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento' , CNPJEmpreendimento__c = '28455163000188');
        insert empreendimento;
        
        // Criando dois leads com interesse em empreendimentos
        Lead testLead1 = new Lead(
            FirstName = 'Lead1', 
            LastName = 'Test', 
            Company = 'Test Company', 
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        Lead testLead2 = new Lead(
            FirstName = 'Lead2', 
            LastName = 'Test', 
            Company = 'Test Company', 
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert new List<Lead> { testLead1, testLead2 };
        
        // Iniciando o teste
        Test.startTest();
        
        // Configurando a requisição REST
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/Lead/buscarEmpreendimentos';
        req.httpMethod = 'GET';
        RestContext.request = req;
        
        // Configurando a resposta REST
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Chamada ao método da classe principal
        LeadEmpreendimentosRestResource.buscarEmpreendimentos();
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testBuscarEmpreendimentosNoData() {
        // Iniciando o teste sem dados no banco
        Test.startTest();
        
        // Configurando a requisição REST
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/Lead/buscarEmpreendimentos';
        req.httpMethod = 'GET';
        RestContext.request = req;
        
        // Configurando a resposta REST
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Chamada ao método da classe principal
        LeadEmpreendimentosRestResource.buscarEmpreendimentos();
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testBuscarEmpreendimentosWithError() {
        // Iniciando o teste para verificar o erro
        Test.startTest();
        
        // Configurando a requisição REST
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/Lead/buscarEmpreendimentos';
        req.httpMethod = 'GET';
        RestContext.request = req;
        
        // Configurando a resposta REST
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Mock para simular erro no callout HTTP
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Chamada ao método da classe principal
        LeadEmpreendimentosRestResource.buscarEmpreendimentos();
        
        Test.stopTest();
        
    }
    
    // Mock para simular erro HTTP
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(400);
            res.setStatus('Bad Request');
            return res;
        }
    }
}