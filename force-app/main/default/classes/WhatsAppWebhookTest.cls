@IsTest
private class WhatsAppWebhookTest {

    @IsTest
    static void testValidarWebhook() {
        // Simula a requisição HTTP GET para validar o webhook.
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/whatsapp/webhook';
        request.httpMethod = 'GET';
        
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        WhatsAppWebhook.validarWebhook();
        Test.stopTest();
    }
    
    @IsTest
    static void testCadastrarMensagens() {
        // Simula a requisição HTTP POST para cadastrar mensagens.
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/whatsapp/webhook';
        request.httpMethod = 'POST';

        // Simulando o corpo da requisição para o cadastro de mensagens.
        String requestBody = '{"entry":[{"id":"1","messages":[{"from":"1234567890","text":{"body":"Hello!"}}]}]}';
        request.requestBody = Blob.valueOf(requestBody);

        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        WhatsAppWebhook.cadastrarMensagens();
        Test.stopTest();
    }
}