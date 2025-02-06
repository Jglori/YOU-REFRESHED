public class QuoteLineItemHelper {

    public static void validateQuoteLineItems(List<QuoteLineItem> newQuoteLineItems) {
        Set<Id> quoteIds = new Set<Id>();
        
        for (QuoteLineItem qli : newQuoteLineItems) {
            quoteIds.add(qli.QuoteId);
        }

    
        Map<Id, Integer> quoteItemCounts = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT QuoteId, COUNT(Id) itemCount 
            FROM QuoteLineItem 
            WHERE QuoteId IN :quoteIds 
            GROUP BY QuoteId
        ]) {
            quoteItemCounts.put((Id) ar.get('QuoteId'), (Integer) ar.get('itemCount'));
        }

        
        for (QuoteLineItem qli : newQuoteLineItems) {
            Integer itemCount = quoteItemCounts.get(qli.QuoteId);
            if (itemCount == null) {
                itemCount = 0;
            }

          
            if (itemCount >= 1) {
                qli.addError('Não é permitido adicionar mais de um produto à cotação.');
            } else {
                
                quoteItemCounts.put(qli.QuoteId, itemCount + 1);
            }
        }
    }
}