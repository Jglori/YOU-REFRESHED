public with sharing class TemplateDocumentoDA { 
    public static List<TemplateDocumento__c> getTemplatesByEmpId(String empId) {
        return [SELECT Id, Name, TipoTemplate__c, ConteudoTemplate__c, Empreendimento__c FROM TemplateDocumento__c WHERE Ativo__c = true AND Empreendimento__c = :empId];
    }

    public static TemplateDocumento__c getById(Id id) {
        if (id == null) return null;
        return [SELECT Id, Name, TipoTemplate__c, ConteudoTemplate__c, Empreendimento__c FROM TemplateDocumento__c WHERE Ativo__c = true AND Id =:id];
    }

    public static List<TemplateDocumento__c> getByOpportunityId(Id opportunityId) {
        if (opportunityId == null) return null;

        List<Empreendimento__c> emps = [
            SELECT Id 
            FROM Empreendimento__c 
            WHERE Id IN (
                SELECT Empreendimento__c
                FROM Opportunity
                WHERE Id = :opportunityId
            ) 
        ];
        if (emps == null || emps.isEmpty()) return null;
        
        Set<Id> empsId = new Set<Id>();
        for (Empreendimento__c emp : emps) {
            empsId.add(emp.Id);
        }
        
        return [
            SELECT Id, Name
            FROM TemplateDocumento__c
            WHERE Empreendimento__c IN :empsId
        ];
    }
}