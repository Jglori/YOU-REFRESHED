public with sharing class TemplateDocumentoDA {
    public static List<TemplateDocumento__c> getTemplatesByEmpId(String empId) {
        return [SELECT Id, Name, TipoTemplate__c, ConteudoTemplate__c, Empreendimento__c FROM TemplateDocumento__c WHERE Ativo__c = true AND Empreendimento__c = :empId];
    }

    public static TemplateDocumento__c getById(Id id) {
        if (id == null) return null;
        return [SELECT Id, Name, TipoTemplate__c, ConteudoTemplate__c, Empreendimento__c FROM TemplateDocumento__c WHERE Ativo__c = true AND Id =:id];
    }

  public static List<TemplateDocumento__c> getByOpportunityId(Id opportunityId) {
    if (opportunityId == null) {
        // Lança uma exceção personalizada caso o opportunityId seja nulo.
        throw new AuraHandledException('O ID da oportunidade não pode ser nulo.');
    }

    try {
        List<Empreendimento__c> emps = [
            SELECT Id 
            FROM Empreendimento__c 
            WHERE Id IN (
                SELECT Empreendimento__c
                FROM Opportunity
                WHERE Id = :opportunityId
            )
        ];

        if (emps == null || emps.isEmpty()) {
            // Lança uma exceção caso nenhum Empreendimento seja encontrado.
            throw new AuraHandledException('Nenhum Empreendimento associado à oportunidade foi encontrado.');
        }

        Set<Id> empsId = new Set<Id>();
        for (Empreendimento__c emp : emps) {
            empsId.add(emp.Id);
        }

        List<TemplateDocumento__c> templates = [
            SELECT Id, Name
            FROM TemplateDocumento__c
            WHERE Empreendimento__c IN :empsId
        ];

        if (templates == null || templates.isEmpty()) {
            // Lança uma exceção caso não encontre templates relacionados ao Empreendimento.
            throw new AuraHandledException('Nenhum template encontrado para o Empreendimento associado.');
        }

        return templates;
    } catch (QueryException e) {
        // Caso haja erro na execução do SOQL, lança uma exceção.
        throw new AuraHandledException('Erro ao realizar a consulta: ' + e.getMessage());
    }
  }
}