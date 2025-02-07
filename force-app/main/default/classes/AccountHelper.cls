public with sharing class AccountHelper {

    public static Account getByOpportunityId(Id opportunityId) {
        Account acc = AccountDA.getByOpportunityId(opportunityId);

        if (acc == null) throw new IllegalArgumentException('Account não encontrada com OpportunityId: '+ opportunityId);
    
        return acc;
    }

}