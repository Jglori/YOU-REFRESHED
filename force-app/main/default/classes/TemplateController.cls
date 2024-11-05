public with sharing class TemplateController {
    @AuraEnabled(cacheable=true)
    public static List<TemplateDocumento__c> getTemplates(String oppId) {
        List<TemplateDocumento__c> templatesToReturn = new List<TemplateDocumento__c>();
        
        List<TemplateDocumento__c> templates = TemplateSelector.getTemplates();
        
        if (!templates.isEmpty() && String.isNotBlank(oppId)) {
            Opportunity opp = (Opportunity) QueryHelper.selectAllFields('Opportunity', oppId);
            
            if (opp != null) {
                for (TemplateDocumento__c template : templates) {
                    if (template.Empreendimento__c == opp.Empreendimento__c) {
                        templatesToReturn.add(template);
                    }
                }
            }
        }
        
        return templatesToReturn;
    }
    
}