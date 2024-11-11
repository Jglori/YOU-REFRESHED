public with sharing class TemplateController {
    @AuraEnabled(cacheable=true)
    public static List<TemplateDocumento__c> getTemplates(String oppId) {
        Opportunity opp = (Opportunity) QueryHelper.selectAllFields('Opportunity', oppId);
        List<TemplateDocumento__c> templates = TemplateSelector.getTemplatesByEmpId(opp.Empreendimento__c);
        
        return templates.size() > 0 ? templates : new List<TemplateDocumento__c>();
    }
    
}