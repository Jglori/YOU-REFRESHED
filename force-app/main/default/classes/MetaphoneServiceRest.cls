@RestResource(urlMapping='/metaphoneService/*')
global with sharing class MetaphoneServiceRest {



    @HttpGet
    global static List<String> buscarNomesFoneticamenteRest() {
        RestRequest req = RestContext.request;
        String palavra = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        if (String.isBlank(palavra)) {
            throw new IllegalArgumentException('Parâmetro de busca é necessário.');
        }

        try {
            return buscarNomesFoneticamente(palavra);
        } catch (Exception e) {
            throw new CustomRestException('Erro ao processar a solicitação: ' + e.getMessage());
        }
    }

    public static List<String> buscarNomesFoneticamente(String palavra) {
        if (String.isBlank(palavra)) {
            throw new IllegalArgumentException('Parâmetro de busca é necessário.');
        }

        List<Contact> corretores = [SELECT Apelido__c FROM Contact WHERE RecordType.Name = 'Corretor' AND Apelido__c != null];

        MetaphoneService service = new MetaphoneService();

        List<String> apelidos = new List<String>();
        for (Contact corretor : corretores) {
            apelidos.add(corretor.Apelido__c);
        }

        return service.buscaFoneticamente(palavra, apelidos);
    }

    public class CustomRestException extends Exception {}

}