public with sharing class ReportingContactsController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getReportingContacts(Id contactId) {
        return [SELECT Id, Name, AccountId, account.name, Email, Reporta_se_A__c, MobilePhone 
                FROM Contact 
                WHERE Reporta_se_A__c = :contactId];
    }
}