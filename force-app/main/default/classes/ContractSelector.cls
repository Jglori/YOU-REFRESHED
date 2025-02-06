public with sharing class ContractSelector {

    public static Contract getById(Id id) {
        if (id == null) return null;

        return [
            SELECT Id, Name
            FROM Contract
            WHERE Id = :id
        ];
    }

    public static Contract getContract(String oppId) {
        if (oppId == null) return null;
        
        List<Contract> ctts = [
            SELECT Id, 
                Status, 
                StartDate, 
                Account.Name, 
                CustomerSignedDate, 
                DataEnvioAssinatura__c, 
                PrazoAssinatura__c 
            FROM Contract 
            WHERE Oportunidade__c = :oppId 
            ORDER BY CreatedDate DESC LIMIT 1
        ];

        return ctts.isEmpty() ? null : ctts[0];
    }

    public static List<Contract> getContractsByOpp(Set<Id> oppsId){
        return [SELECT Id, Status, StartDate, Account.Name, 
            CustomerSignedDate, DataEnvioAssinatura__c, PrazoAssinatura__c 
        FROM Contract 
        WHERE Oportunidade__c IN :oppsId];
    }
    
    public static List<OpportunityContactRole> getRolesContatoOpp(Id oppId) {
        if (oppId == null) return null;

        return [SELECT Id, ContactId, OpportunityId, Contact.Name, Contact.Email, Role FROM OpportunityContactRole WHERE OpportunityId = :oppId AND Role != null];
    }

    public static List<Contract> getByOpportunityId(Id oppId) {
        List<Contract> ctts = [
            SELECT Id, 
                ContractNumber,
                Status, 
                StartDate, 
                Account.Name, 
                CustomerSignedDate, 
                DataEnvioAssinatura__c, 
                DataInicioContrato__c,
                PrazoAssinatura__c,
                Template__c
            FROM Contract 
            WHERE Oportunidade__c = :oppId 
        ];

        return ctts;
    }
}