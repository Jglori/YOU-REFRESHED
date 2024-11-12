public class QuoteSyncTriggerHandler {
    
    public static void handleBeforeInsertOrUpdate(List<Quote> newQuotes) {
        Set<Id> opportunityIds = new Set<Id>();

        // Coleta os IDs das oportunidades associadas às cotações que estão sendo processadas
        for (Quote newQuote : newQuotes) {
            if (newQuote.OpportunityId != null) {
                opportunityIds.add(newQuote.OpportunityId);
            }
        }

        // Busca cotações sincronizadas relacionadas às oportunidades em questão
        Map<Id, Quote> syncedQuotesMap = new Map<Id, Quote>(
            [SELECT Id, Name, OpportunityId FROM Quote WHERE Sincronizado__c = true AND OpportunityId IN :opportunityIds]
        );

        for (Quote newQuote : newQuotes) {
            // Verifica se já existe uma cotação sincronizada para a mesma oportunidade
            if (newQuote.OpportunityId != null && syncedQuotesMap.containsKey(newQuote.OpportunityId)) {
                Quote syncedQuote = syncedQuotesMap.get(newQuote.OpportunityId);
                
                // Se a cotação sincronizada for diferente da cotação atual e a nova cotação não estiver sincronizada
                if (syncedQuote.Id != newQuote.Id && newQuote.Sincronizado__c) {
                    newQuote.addError('A cotação: ' + syncedQuote.Name + ' já está sincronizada com esta oportunidade. Não é possível sincronizar outra cotação.');
                }
            }

            // Atualiza o campo 'Sincronizado__c' com base no Status
            if (newQuote.Status == 'Aprovada') {
                newQuote.Sincronizado__c = true;
            } else {
                newQuote.Sincronizado__c = false;
            }
        }
    }
}