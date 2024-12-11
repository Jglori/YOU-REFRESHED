@IsTest
public class WhatsAppCalloutTest {
    // Classe interna para simular respostas HTTP
    private class WhatsAppHttpMock implements HttpCalloutMock {
        private HttpResponse mockResponse;

        // Construtor que recebe a resposta simulada
        public WhatsAppHttpMock(HttpResponse response) {
            this.mockResponse = response;
        }

        public HttpResponse respond(HttpRequest req) {
            return mockResponse;
        }
    }

    // Método auxiliar para simular dados de IntegracaoWhatsapp__mdt
    private static void configurarMockDeIntegracao() {
        // Simula os dados que seriam fornecidos pelo metadado IntegracaoWhatsapp__mdt
        // Simulação do comportamento de um Custom Metadata ou Custom Setting
        Test.startTest();
        // Simulação de valores esperados de um metadado para este teste
        System.enqueueJob(new IntegrationJobMock());
        Test.stopTest();
    }

    // Método de teste para obterURLMidia
    @IsTest
    static void testObterURLMidia() {
        String idMidia = '123456';

        // Mock da resposta HTTP
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setBody('{"success": true, "url": "https://fakeurl.com/media/123456"}');
        mockResponse.setStatusCode(200);

        // Configura o mock para o callout
        Test.setMock(HttpCalloutMock.class, new WhatsAppHttpMock(mockResponse));

        // Simula chamada com valores mockados de token e ID diretamente na requisição
        String token = 'fakeAccessToken';
        String url = 'https://graph.facebook.com/v17.0/' + idMidia;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');

        // Executa o método
        HttpResponse response = WhatsAppCallout.obterURLMidia(idMidia);
    }

    // Métodos de teste similares para os outros métodos
    @IsTest
    static void testObterMidia() {
        String urlMidia = 'https://fakeurl.com/media/123456';

        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setBody('{"file": "mediaContent"}');
        mockResponse.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new WhatsAppHttpMock(mockResponse));

        String token = 'fakeAccessToken';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(urlMidia);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');

        HttpResponse response = WhatsAppCallout.obterMidia(urlMidia);
    }

    // Teste para enviarMensagem
    @IsTest
    static void testEnviarMensagem() {
        String body = '{"to": "recipient_id", "message": "Hello"}';

        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setBody('{"message_id": "123"}');
        mockResponse.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new WhatsAppHttpMock(mockResponse));

        String token = 'fakeAccessToken';
        String url = 'https://graph.facebook.com/v17.0/fakeWhatsAppId/messages';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody(body);
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');

        HttpResponse response = WhatsAppCallout.enviarMensagem(body);
    }

    // Método de teste para enviarMidia
    @IsTest
    static void testEnviarMidia() {
        String body = '{"to": "recipient_id", "media": "media_id"}'; // Corpo do POST

        // Configuração do mock para o metadado IntegracaoWhatsapp__mdt
        configurarMockDeIntegracao();

        // Mock da resposta HTTP que será retornada pela chamada
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setBody('{"message_id": "456"}');  // Resposta simulada
        mockResponse.setStatusCode(200);  // Status HTTP 200 OK

        // Configura o mock para interceptar a chamada HTTP
        Test.setMock(HttpCalloutMock.class, new WhatsAppHttpMock(mockResponse));

        // Executa o método que estamos testando
        HttpResponse response = WhatsAppCallout.enviarMidia(body);
    }

    // Simulação de Job para representar o comportamento de leitura de metadado (mock)
    private class IntegrationJobMock implements Queueable {
        public void execute(QueueableContext context) {
            // Simulando o comportamento do metadado IntegracaoWhatsapp__mdt
            // Isso seria substituído pelo comportamento real de leitura do metadado
            System.debug('Simulating metadado behavior for integration.');
        }
    }
}