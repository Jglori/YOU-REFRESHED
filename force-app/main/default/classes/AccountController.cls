public with sharing class AccountController {
    
    @AuraEnabled(cacheable=true)
    public static Account getByOpportunityId(Id opportunityId){
        try {
            return AccountHelper.getByOpportunityId(opportunityId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}