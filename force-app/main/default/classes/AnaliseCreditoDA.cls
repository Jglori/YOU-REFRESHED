public with sharing class AnaliseCreditoDA {

    public static List<AnaliseCredito__c> getById(Set<Id> ids) {
        if (ids == null || ids.isEmpty()) {
            return new List<AnaliseCredito__c>();
        }

        return [
            SELECT Id, Name, NomeComprador__c, Opportunity__c, RecordTypeId, Status__c
            FROM AnaliseCredito__c
            WHERE Id IN :ids
        ];        
    }

    public static List<Opportunity> getOpportunityById(Id id) {
        if (id == null) {
            return new List<Opportunity>();
        }

        return [
            SELECT Id, Name, AccountId, Corretor__c, StageName, Type
            FROM Opportunity
            WHERE Id IN (
                SELECT Opportunity__c
                FROM AnaliseCredito__c
                WHERE Id = :id 
            )
        ];
    }
}