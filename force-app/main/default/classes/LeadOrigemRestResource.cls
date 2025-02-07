@RestResource(urlMapping='/Lead/ListaOrigens')
global with sharing class LeadOrigemRestResource {

    public class LeadOrigemDTO {
        public List<String> origemLead = new List<String>();
    }

    @HttpGet
    global static void getLeadSources() {
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');

        try {
            LeadOrigemDTO resposta = new LeadOrigemDTO();
            Set<String> leadSources = new Set<String>();

            for (Lead lead : [SELECT LeadSource FROM Lead WHERE LeadSource != NULL]) {
                leadSources.add(lead.LeadSource);
            }

            resposta.origemLead.addAll(leadSources);

            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serialize(resposta));
        } catch (Exception e) {
            response.statusCode = 500;
            response.responseBody = Blob.valueOf('Erro ao processar a solicitação: ' + e.getMessage());
        }
    }
}