public with sharing class TemplateSelector {
    public static List<TemplateDocumento__c> getTemplatesByEmpId(String empId) {
        return [SELECT Id, Name, TipoTemplate__c, ConteudoTemplate__c, Empreendimento__c FROM TemplateDocumento__c WHERE Ativo__c = true AND Empreendimento__c = :empId];
    }

    public static TemplateDocumento__c getTemplateById(String id) {
        return [SELECT Id, Name, TipoTemplate__c, ConteudoTemplate__c, Empreendimento__c FROM TemplateDocumento__c WHERE Ativo__c = true AND Id =:id];
    }
}