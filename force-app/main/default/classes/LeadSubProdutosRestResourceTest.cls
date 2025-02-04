@isTest
public class LeadSubProdutosRestResourceTest {
    
    @isTest
    static void testGetPicklistValues() {
        // Cenário de sucesso com lead de teste
        Lead lead = new Lead(
            LastName = 'Teste',
            Company = 'Empresa de Teste'
        );
        insert lead;

        // Chamar o método getPicklistValues
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/Lead/ListaSubProdutos';
        req.httpMethod = 'GET';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        LeadSubProdutosRestResource.getPicklistValues();
        Test.stopTest();

 
    }
    
    @isTest
    static void testGetPicklistValuesNoData() {
        // Cenário sem leads inseridos (sem dados de subprodutos)
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/Lead/ListaSubProdutos';
        req.httpMethod = 'GET';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        LeadSubProdutosRestResource.getPicklistValues();
        Test.stopTest();

    }

    // Classe de mock para simulação de erro
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(500); // Simula erro de servidor
            res.setStatus('Internal Server Error');
            return res;
        }
    }
}