@RestResource(urlMapping='/Lead/buscarEmpreendimentos')
global with sharing class LeadEmpreendimentosRestResource {
    public class EmpreendimentosDto {
        public List<Empreendimentos> empreendimentos;

        public EmpreendimentosDto() {
            empreendimentos = new List<Empreendimentos>();
        }
    }

    public class Empreendimentos {
        public Id id;
        public String nome;

        public Empreendimentos() {
        }
    }

    @HttpGet
    global static void buscarEmpreendimentos() {
        try {
            List<Lead> leads = [
                SELECT EmpreendimentoInteresse__c, EmpreendimentoInteresse__r.Name 
                FROM Lead
            ];

            EmpreendimentosDto empreendimentosDto = new EmpreendimentosDto();
            empreendimentosDto.empreendimentos = new List<Empreendimentos>();

            Set<Id> empreendimentoIds = new Set<Id>();

            for (Lead lead : leads) {
                if (lead.EmpreendimentoInteresse__c != null && lead.EmpreendimentoInteresse__r.Name != null) {
                    if (!empreendimentoIds.contains(lead.EmpreendimentoInteresse__c)) {
                        Empreendimentos emp = new Empreendimentos();
                        emp.id = lead.EmpreendimentoInteresse__c;
                        emp.nome = lead.EmpreendimentoInteresse__r.Name;
                        empreendimentosDto.empreendimentos.add(emp);
                        empreendimentoIds.add(emp.id);
                    }
                }
            }

            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(empreendimentosDto));
        } catch (Exception e) {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('Falha ao buscar empreendimentos: ' + e.getMessage());
        }
    }
}