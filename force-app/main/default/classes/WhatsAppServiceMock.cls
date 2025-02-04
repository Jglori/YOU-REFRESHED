@isTest
public class WhatsAppServiceMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success","message":"Mensagem enviada com sucesso"}');
        res.setStatusCode(200);
        return res;
    }
}