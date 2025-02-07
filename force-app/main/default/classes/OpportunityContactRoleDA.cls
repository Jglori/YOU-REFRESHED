public with sharing class OpportunityContactRoleDA {
    public static List<OpportunityContactRole> getOpportunityContactRolesPercent(Set<Id> opportunityIds) {
        return [
            SELECT Id, OpportunityId, PorcentagemParticipacao__c
            FROM OpportunityContactRole
            WHERE OpportunityId IN :opportunityIds
        ];
    }
}
