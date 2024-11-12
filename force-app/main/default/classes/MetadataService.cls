public class MetadataService {
    public class CustomMetadata {
        public String fullName;
        public String label;
        public Map<String, Object> values;
    }

    @Future(callout=true)
    @AuraEnabled
    public static void createCustomMetadata(String developerName, String label, String documentName, Boolean isMandatory, String role) {
        // Monta o corpo da solicitação SOAP
        String body = '<?xml version="1.0" encoding="utf-8"?>' +
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">' +
            '  <soapenv:Header>' +
            '    <met:CallOptions>' +
            '      <met:client>Insert Metadata</met:client>' +
            '    </met:CallOptions>' +
            '    <met:SessionHeader>' +
            '      <met:sessionId>' + UserInfo.getSessionId() + '</met:sessionId>' +
            '    </met:SessionHeader>' +
            '  </soapenv:Header>' +
            '  <soapenv:Body>' +
            '    <met:createMetadata>' +
            '      <met:metadata xsi:type="met:CustomMetadata">' +
            '        <met:fullName>' + developerName + '.' + label + '</met:fullName>' +
            '        <met:label>' + label + '</met:label>' +
            '        <met:values>' +
            '          <met:field>Nome_do_Documento__c</met:field>' +
            '          <met:value>' + documentName + '</met:value>' +
            '        </met:values>' +
            '        <met:values>' +
            '          <met:field>Obrigatorio__c</met:field>' +
            '          <met:value>' + isMandatory + '</met:value>' +
            '        </met:values>' +
            '        <met:values>' +
            '          <met:field>Papel__c</met:field>' +
            '          <met:value>' + role + '</met:value>' +
            '        </met:values>' +
            '      </met:metadata>' +
            '    </met:createMetadata>' +
            '  </soapenv:Body>' +
            '</soapenv:Envelope>';

        // Configura a solicitação HTTP
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://youinc--developer.sandbox.lightning.force.com/services/Soap/m/57.0'); // Substitua 'yourInstance' pelo nome da sua instância
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('SOAPAction', 'create');
        req.setBody(body);

        // Envia a solicitação
        Http http = new Http();
        HttpResponse res = http.send(req);

        // Verifica a resposta
        if (res.getStatusCode() != 200) {
            System.debug('Erro ao criar Custom Metadata: ' + res.getBody());
        } else {
            System.debug('Custom Metadata criado com sucesso: ' + res.getBody());
        }
    }
}