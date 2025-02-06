public with sharing class QuoteSyncHelper {
    public static void BeforeInsertOrUpdate(List<Quote> newQuotes) {
        Set<Id> opportunityIds = new Set<Id>();

        // Coleta os IDs das oportunidades associadas às cotações que estão sendo processadas
        for (Quote newQuote : newQuotes) {
            if (newQuote.OpportunityId != null) {
                opportunityIds.add(newQuote.OpportunityId);
            }
        }

        // Busca cotações sincronizadas relacionadas às oportunidades em questão
        Map<Id, Quote> syncedQuotesMap = new Map<Id, Quote>(
            [SELECT Id, Name, OpportunityId, IsSyncing, ValorNominalProposta__c  FROM Quote WHERE OpportunityId IN :opportunityIds]
        );

        for (Quote newQuote : newQuotes) {
            // Verifica se já existe uma cotação sincronizada para a mesma oportunidade
            if (newQuote.OpportunityId != null && syncedQuotesMap.containsKey(newQuote.OpportunityId)) { Quote syncedQuote = syncedQuotesMap.get(newQuote.OpportunityId);
                
                // Se a cotação sincronizada for diferente da cotação atual e a nova cotação estiver marcada para sincronizar
                if (newQuote.IsSyncing  && syncedQuote.IsSyncing ) {
                    newQuote.addError('A cotação: ' + syncedQuote.Name + ' já está sincronizada com esta oportunidade. Não é possível sincronizar outra cotação.');
                    return;
                }
            }

            // Atualiza o campo 'IsSyncing ' com base no Status
            // if (newQuote.Status == 'Aprovada') {
            //     newQuote.IsSyncing  = true;
            // } else {
            //     newQuote.IsSyncing  = false;
            // }
        }
    }
}