public with sharing class OpportunityDA {

    public static Map<Id, Opportunity> getOpportunitiesWithQuote(Set<Id> opportunityIds) {
        return new Map<Id, Opportunity>([
            SELECT Id, Pricebook2Id, SyncedQuoteId
            FROM Opportunity
            WHERE Id IN :opportunityIds AND Pricebook2Id != null
        ]);
    }

    public static Boolean hasSyncedQuote(Id opportunityId) {
        Opportunity opp;
        try {
            opp = [
                SELECT SyncedQuoteId
                FROM Opportunity
                WHERE Id = :opportunityId
            ];
        } catch (QueryException e) {
            System.debug('Erro ao consultar oportunidade: ' + e.getMessage());
            return false;
        }

        return !String.isBlank(opp.SyncedQuoteId);
    }

    public static List<OpportunityLineItem> getOpportunityLineItems(Id opportunityId) {
        return [
            SELECT Id, OpportunityId, Product2Id
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId
        ];
    }

    public static List<OpportunityContactRole> getOpportunityContactRoles(Id opportunityId) {
        return [
            SELECT Id, OpportunityId, ContactId
            FROM OpportunityContactRole
            WHERE OpportunityId = :opportunityId
        ];
    }

    public static List<Opportunity> obterOportunidadePorIdProduto(Set<Id> idProduto) {
        return [
            SELECT 
                Id, Corretor__r.Name, Corretor__r.id, Corretor__r.UsuarioCorretor__c, Corretor__r.UsuarioCorretor__r.Email, 
                Corretor__r.UsuarioCorretor__r.Reportase__c, Corretor__r.UsuarioCorretor__r.Reportase__r.Email, 
                Unidade__r.Name, Unidade__r.Status__c, Account.PersonEmail, Account.id, Unidade__r.Id
            FROM 
                Opportunity 
            WHERE 
                Unidade__r.Id = :idProduto
        ];
    }

    
}