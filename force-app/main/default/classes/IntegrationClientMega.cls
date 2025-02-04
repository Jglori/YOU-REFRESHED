public class IntegrationClientMega {

    public static String callApi(String action, String body) {
        // Recupera os metadados de integração
        IntegracaoMega__mdt config = IntegracaoMega__mdt.getInstance('Default');
        String endpoint = config.Endpoint__c;
        String login = config.Login__c;
        String senha = config.Senha__c;
        
        System.debug('Endpoint: ' + endpoint);
        System.debug('Login: ' + login);
        System.debug('Senha: ' + senha);

        // Configura e faz a chamada HTTP
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setHeader('Content-Type', 'text/xml; charset=utf-8');
        request.setHeader('SOAPAction', action);
        request.setBody(body);

        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            return response.getBody();
        } else {
            throw new CalloutException('Failed to call API: ' + response.getStatus());
        }
    }
}