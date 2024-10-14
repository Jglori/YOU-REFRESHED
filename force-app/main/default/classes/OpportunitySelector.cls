public with sharing class OpportunitySelector {
    public static Opportunity getOppById(String oppId){
        return [SELECT Id, Name, Empreendimento__c FROM Opportunity WHERE Id = :oppId];
    }
}