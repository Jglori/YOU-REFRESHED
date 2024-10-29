public with sharing class AnaliseCreditoHelper {

    public static void handleOpportunityFase(List<AnaliseCredito__c> analises) {
        Set<Id> opportunityIds = new Set<Id>();
        for (AnaliseCredito__c analise : analises) {
            if (analise.Opportunity__c != null) {
                opportunityIds.add(analise.Opportunity__c);
            }
        }

        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(
            [SELECT Id, Name, StageName FROM Opportunity WHERE Id IN :opportunityIds]
        );

        for (AnaliseCredito__c analise : analises) {
            Opportunity opp = opportunityMap.get(analise.Opportunity__c);
            if (opp.StageName != 'Pré-análise') {
                analise.addError('Análise de Crédito pode ser criada somente na fase de Pré-análise da Oportunidade');
            }
        }
    }

    public static void handleStatusForOpportunity(List<AnaliseCredito__c> analises) {
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id, Integer> analisesAprovadas = new Map<Id, Integer>();

        for (AnaliseCredito__c analise : analises) {
            if (analise.Status__c == 'Aprovada' && analise.Opportunity__c != null) {
                opportunityIds.add(analise.Opportunity__c);
            
                if (!analisesAprovadas.containsKey(analise.Opportunity__c)) {
                    analisesAprovadas.put(analise.Opportunity__c, 1);
                } else {
                    analisesAprovadas.put(analise.Opportunity__c, analisesAprovadas.get(analise.Opportunity__c) + 1);
                }
                
                if (analisesAprovadas.get(analise.Opportunity__c) > 1) {
                    analise.addError('Não é permitido ter duas análises de crédito com status aprovada em uma oportunidade');
                }
            }
        }
        
        Map<Id, Integer> opportunityComAnalisesAprovada = new Map<Id, Integer>();
        if (!opportunityIds.isEmpty()) {
            List<AggregateResult> aggregateResults = [
                SELECT COUNT(Id) quantidade, Opportunity__c 
                FROM AnaliseCredito__c
                WHERE Status__c = 'Aprovada' AND Opportunity__c IN :opportunityIds
                GROUP BY Opportunity__c
            ];

            for (AggregateResult ar : aggregateResults) {
                Id opportunityId = (Id) ar.get('Opportunity__c');
                Integer count = (Integer) ar.get('quantidade');
                opportunityComAnalisesAprovada.put(opportunityId, count); 
            }
        }

        for (AnaliseCredito__c analise : analises) {
            if (analise.Status__c == 'Aprovada' && analise.Opportunity__c != null) {
                Integer quantidade = opportunityComAnalisesAprovada.get(analise.Opportunity__c);

                if (quantidade != null && quantidade > 0) {
                    analise.addError('Não é permitido ter duas análises de crédito com status aprovada em uma oportunidade');
                }
            }
        }   
    }

    public static void handleDataVencimento(List<AnaliseCredito__c> analises) {
        Date hoje = Date.today();
        for(AnaliseCredito__c analise : analises) {
            if (hoje > analise.DataVencimento__c) {
                analise.Status__c = 'Vencida';
            }
        }
    }
}