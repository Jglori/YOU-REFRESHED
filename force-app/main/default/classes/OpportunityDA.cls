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
                Id ,
                Unidade__r.Name, Unidade__r.Status__c, Account.PersonEmail, Account.Id, Unidade__r.Id, Corretor__r.id
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

   public static Boolean getOpportunityWithChecklistAproval(Id opportunityId) {
        if (opportunityId == null) {
            System.debug('OpportunityId is null');
            return false;
        }

        List<ProcessInstance> processInstances = [
            SELECT Id, ProcessDefinitionId, Status
            FROM ProcessInstance
            WHERE TargetObjectId = :opportunityId
            AND Status = 'Approved'
        ];

        Set<Id> processDefinitionIds = new Set<Id>();

        for (ProcessInstance pi : processInstances) {
            processDefinitionIds.add(pi.ProcessDefinitionId);
        }

        List<ProcessDefinition> processDefinitions = [
            SELECT Id, DeveloperName
            FROM ProcessDefinition
            WHERE Id IN :processDefinitionIds
        ];

        for (ProcessDefinition pd : processDefinitions) {
            if (pd.DeveloperName == 'ProcessoAprovacaoChecklist') {
                return true;
            }
        }

        return false;
    }


    public static List<Opportunity> getAllByAnaliseCredito(Set<Id> idsAnalise) {
        if (idsAnalise == null) {
            return new List<Opportunity>();
        }

        return [
            SELECT Id, Name, AccountId, Corretor__c, StageName, Type
            FROM Opportunity
            WHERE Id IN (
                SELECT Opportunity__c
                FROM AnaliseCredito__c
                WHERE Id IN :idsAnalise 
            )
        ];
    }

    public static List<Opportunity> getByAnaliseCredito(Id idAnalise) {
        if (idAnalise == null) {
            return new List<Opportunity>();
        }

        return [
            SELECT Id, Name, AccountId, Corretor__c, StageName, Type
            FROM Opportunity
            WHERE Id IN (
                SELECT Opportunity__c
                FROM AnaliseCredito__c
                WHERE Id = :idAnalise
            )
        ];
    }

    public static List<Opportunity> getAllById(Set<Id> ids) {
        if (ids == null) {
            return new List<Opportunity>();
        }

        return [
            SELECT Id, Name, AccountId, Account.PersonEmail, Corretor__c, Corretor__r.Email, OwnerId, Owner.Email 
            FROM Opportunity
            WHERE Id IN :ids
        ];
    }

}