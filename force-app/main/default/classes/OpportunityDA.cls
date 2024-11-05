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
                Id, Corretor__r.Name, Corretor__r.Id, Corretor__r.Email,
                Corretor__r.Reportase__c, Corretor__r.Reportase__r.Email,
                Unidade__r.Name, Unidade__r.Status__c, Account.PersonEmail, Account.Id, Unidade__r.Id
            FROM Opportunity
            WHERE Unidade__r.Id = :idProduto
        ];

    }
    
 // Método para obter o mapa de contagem de análises de crédito por oportunidade
 public static Map<Id, Integer> getAnaliseCreditoCountByOpportunity(Set<Id> opportunityIds) {
    Map<Id, Integer> mapAnalisesRelacionadas = new Map<Id, Integer>();

    List<AggregateResult> aggregateResults = [
        SELECT COUNT(Id) quantidade, Opportunity__c
        FROM AnaliseCredito__c
        WHERE Opportunity__c IN :opportunityIds
        GROUP BY Opportunity__c
    ];

    for (AggregateResult ag : aggregateResults) {
        Id oppId = (Id) ag.get('Opportunity__c');
        Integer quantidade = (Integer) ag.get('quantidade');
        mapAnalisesRelacionadas.put(oppId, quantidade);
    }

    return mapAnalisesRelacionadas;
   }  
}