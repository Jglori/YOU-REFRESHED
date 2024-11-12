@RestResource(urlMapping='/Lead/ListaCanaisAtendimento')
global with sharing class LeadCanaisRestResource {

    public class LeadCanaisDTO {
        public List<String> canaisDeAtendimento = new List<String>();
    }

    @HttpGet
    global static void getCanaisAtendimento() {
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');

        try {
            LeadCanaisDTO resposta = new LeadCanaisDTO();
            
            Set<String> canaisUnicos = new Set<String>();
            for (Lead lead : [SELECT CanalAtendimento__c FROM Lead WHERE CanalAtendimento__c != NULL]) {
                canaisUnicos.add(lead.CanalAtendimento__c);
            }
            
            // Caso não haja canais, adiciona um valor para evitar resposta vazia
            if (canaisUnicos.isEmpty()) {
                resposta.canaisDeAtendimento.add('Nenhum canal encontrado');
            } else {
                resposta.canaisDeAtendimento.addAll(canaisUnicos);
            }

            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serialize(resposta));
        } catch (Exception e) {
            response.statusCode = 500;
            response.responseBody = Blob.valueOf('Erro ao processar a solicitação: ' + e.getMessage());
        }
    }
}