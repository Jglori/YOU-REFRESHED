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

}