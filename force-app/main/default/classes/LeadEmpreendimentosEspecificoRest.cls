@RestResource(urlMapping='/Lead/buscarEmpreendimentos/*')
global with sharing class LeadEmpreendimentosEspecificoRest {
    public class EmpreendimentosDto {
        public List<Empreendimentos> empreendimentos = new List<Empreendimentos>();
    }

    public class Empreendimentos {
        public Id id;
        public String nome;
    }

    @HttpGet
    global static void buscarEmpreendimentos() {
        String nomeEmpreendimento = RestContext.request.params.get('nome');

        if (String.isEmpty(nomeEmpreendimento)) {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('Nome do empreendimento não fornecido na URL.');
            return;
        }

        try {
            EmpreendimentosDto empreendimentosDto = new EmpreendimentosDto();
            Set<String> nomesEmpreendimentos = new Set<String>(); 

            String query = 'SELECT EmpreendimentoInteresse__c, EmpreendimentoInteresse__r.Name ' +
                           'FROM Lead ' +
                           'WHERE EmpreendimentoInteresse__r.Name = :nomeEmpreendimento ' +
                           'AND EmpreendimentoInteresse__c != null';

            List<Lead> leads = Database.query(query);

            for (Lead lead : leads) {
                String nome = lead.EmpreendimentoInteresse__r.Name;
                if (!nomesEmpreendimentos.contains(nome)) {
                    Empreendimentos emp = new Empreendimentos();
                    emp.id = lead.EmpreendimentoInteresse__c;
                    emp.nome = nome;
                    empreendimentosDto.empreendimentos.add(emp);
                    nomesEmpreendimentos.add(nome);
                }
            }

            if (empreendimentosDto.empreendimentos.isEmpty()) {
                RestContext.response.statusCode = 204; 
                return; 
            }

            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(empreendimentosDto));
        } catch (Exception e) {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('Falha ao buscar empreendimentos: ' + e.getMessage());
        }
    }
}