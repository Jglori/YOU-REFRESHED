public with sharing class ContractSelector {
    public static Contract getContract(String oppId) {
        Contract contrato = [
        SELECT Id, Status, StartDate, Account.Name, 
            CustomerSignedDate, DataEnvioAssinatura__c, PrazoAssinatura__c 
        FROM Contract 
        WHERE Oportunidade__c = :oppId ORDER BY CreatedDate DESC LIMIT 1
    ];
        
        return contrato;
    }

    public static List<Contract> getContractsByOpp(Set<Id> oppsId){
        return [SELECT Id, Status, StartDate, Account.Name, 
            CustomerSignedDate, DataEnvioAssinatura__c, PrazoAssinatura__c 
        FROM Contract 
        WHERE Oportunidade__c IN :oppsId];
    }
    
    public static List<OpportunityContactRole> getRolesContatoOpp(String oppId) {
        return [SELECT Id, ContactId, OpportunityId, Contact.Name, Contact.Email, Role FROM OpportunityContactRole WHERE OpportunityId = :oppId AND Role != null];
    }
}