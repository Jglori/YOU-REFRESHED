public with sharing class ContractSelector {
    public static Contract getContract(String oppId) {
        List<Contract> contratos = [
        SELECT Id, Status, StartDate, Account.Name, 
               CustomerSignedDate, DataEnvioAssinatura__c 
        FROM Contract 
        WHERE Id IN (SELECT ContractId FROM Opportunity WHERE Id = :oppId)
        LIMIT 1
    ];
        
        return contratos.isEmpty() ? new Contract() : contratos[0];
    }
    
    public static List<OpportunityContactRole> getRolesContatoOpp(String oppId) {
        return [SELECT Id, ContactId, OpportunityId, Contact.Name, Contact.Email, Role FROM OpportunityContactRole WHERE OpportunityId = :oppId AND Role != null];
    }
}