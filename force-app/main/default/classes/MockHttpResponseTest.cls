@isTest
private class MockHttpResponseTest {

    @isTest
    static void testHttpResponse() {
        // Define os dados de entrada que seriam passados na requisição
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('https://api.exemplo.com');
        req.setMethod('GET');
        
        // Instancia a classe MockHttpResponse
        MockHttpResponse mockResponse = new MockHttpResponse();
        
        // Realiza o mock da chamada HTTP
        Test.setMock(HttpCalloutMock.class, mockResponse);
        
        // Executa o callout
        HTTPResponse res = mockResponse.respond(req);
        
        // Verifica se o código de status da resposta é 200
        System.assertEquals(200, res.getStatusCode(), 'O status code deve ser 200.');
        
        // Verifica se a resposta tem o conteúdo esperado
        String responseBody = res.getBody();
        System.assert(responseBody.contains('"status":"success"'), 'A resposta deve conter o status de sucesso.');
        System.assert(responseBody.contains('"message":"Mensagem simulada"'), 'A resposta deve conter a mensagem simulada.');
    }
}