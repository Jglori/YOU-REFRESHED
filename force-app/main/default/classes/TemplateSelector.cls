public with sharing class TemplateSelector {

    public static List<TemplateDocumento__c> getTemplates() {
        return [SELECT Id, Name, TipoTemplate__c, ConteudoTemplate__c, Empreendimento__c FROM TemplateDocumento__c WHERE Ativo__c = true];
    }

}