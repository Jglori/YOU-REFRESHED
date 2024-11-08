trigger QuoteLineItemTrigger on QuoteLineItem (before insert, before update) {
    Set<Id> quoteIds = new Set<Id>();
    
    for (QuoteLineItem qli : Trigger.new) {
        quoteIds.add(qli.QuoteId);
    }

    // Para cada cotação, conta quantos produtos já estão associados
    Map<Id, Integer> quoteItemCounts = new Map<Id, Integer>();

    for (AggregateResult ar : [SELECT QuoteId, COUNT(Id) itemCount FROM QuoteLineItem WHERE QuoteId IN :quoteIds GROUP BY QuoteId]) {
        quoteItemCounts.put((Id)ar.get('QuoteId'), (Integer)ar.get('itemCount'));
    }

    // Verifica se já existe mais de um produto para uma cotação
    for (QuoteLineItem qli : Trigger.new) {
        Integer itemCount = quoteItemCounts.get(qli.QuoteId);
        
        // Se já existir um item e está tentando adicionar outro, lança exceção
        if (itemCount != null && itemCount >= 1) {
            qli.addError('Não é permitido adicionar mais de um produto à cotação.');
        }
    }
}