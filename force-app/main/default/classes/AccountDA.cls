public with sharing class AccountDA {

    public static Account getByOpportunityId(Id opportunityId) {
        if (opportunityId == null) return null;

        List<Account> accs = [
            SELECT Id, Name 
            FROM Account
            WHERE Id IN (
                SELECT AccountId
                FROM Opportunity
                WHERE Id = :opportunityId
            )
        ];

        if (accs.isEmpty()) return null;

        return accs[0];
    }
}