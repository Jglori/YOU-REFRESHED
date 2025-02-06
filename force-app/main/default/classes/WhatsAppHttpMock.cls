@isTest
public class WhatsAppHttpMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        // Cria uma resposta HTTP simulada
        HTTPResponse res = new HTTPResponse();
        
        // Verifica o método HTTP e o endpoint, se necessário
        System.debug('Endpoint chamado: ' + req.getEndpoint());
        System.debug('Método: ' + req.getMethod());
        System.debug('Body da requisição: ' + req.getBody());  // Verifica o corpo da requisição

        // Cria um corpo de resposta simulado
        Map<String, Object> responseBody = new Map<String, Object>();
        responseBody.put('status', 'sucesso');  // Simula um status de sucesso
        responseBody.put('mensagemId', '12345');  // ID fictício da mensagem enviada
        responseBody.put('leadId', req.getBody());  // Adiciona o body da requisição no leadId

        // Serializa a resposta simulada para o formato JSON
        res.setBody(JSON.serialize(responseBody));
        res.setStatusCode(200);  // Simula uma resposta de sucesso HTTP

        return res;
    }
}