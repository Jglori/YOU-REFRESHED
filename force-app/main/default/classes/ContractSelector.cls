public with sharing class ContractSelector {
    public static Contract getContract(String oppId) {
        return [SELECT Id, Status, StartDate, Account.Name, 
        CustomerSignedDate, DataEnvioAssinatura__c 
        FROM Contract WHERE Id IN (SELECT ContractId FROM Opportunity WHERE Id = :oppId)
        LIMIT 1];
    }
}