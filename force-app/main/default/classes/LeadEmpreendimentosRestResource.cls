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
            EmpreendimentosDto empreendimentosDto = new EmpreendimentosDto();

            List<Empreendimento__c> empreendimentos = [
                SELECT Id, Name
                FROM Empreendimento__c
            ];

            for (Empreendimento__c emp : empreendimentos) {
                Empreendimentos empreendimentoDto = new Empreendimentos();
                empreendimentoDto.id = emp.Id;
                empreendimentoDto.nome = emp.Name;
                empreendimentosDto.empreendimentos.add(empreendimentoDto);
            }

            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(empreendimentosDto));
        } catch (Exception e) {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('Falha ao buscar empreendimentos: ' + e.getMessage());
        }
    }
}