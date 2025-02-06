public with sharing class TemplateDocumentoController {
    
    @AuraEnabled(cacheable=true)
    public static List<TemplateDocumento__c> getByOpportunityId(Id opportunityId){
        try {
            return TemplateDocumentoHelper.getByOpportunityId(opportunityId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}