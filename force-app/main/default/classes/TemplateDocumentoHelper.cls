public with sharing class TemplateDocumentoHelper {

    public static List<TemplateDocumento__c> getByOpportunityId(Id opportunityId){
        try {
            return TemplateDocumentoDA.getByOpportunityId(opportunityId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}