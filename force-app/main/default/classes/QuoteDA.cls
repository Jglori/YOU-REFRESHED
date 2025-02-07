public with sharing class QuoteDA { 
    public static Map<Id, Quote> getQuotesMapByIds(List<Id> quoteIds) {
        return new Map<Id, Quote>([SELECT Id, OpportunityId, GrandTotal FROM Quote WHERE Id IN :quoteIds]);
    }

    // Função para obter o primeiro produto da cotação
    public static Product2 getProductByQuoteId(Id quoteId) {
        QuoteLineItem lineItem = getFirstQuoteLineItemByQuoteId(quoteId);
        if (lineItem != null) {
            return [SELECT Id, Bloco__c, Empreendimento__c, Name FROM Product2 WHERE Id = :lineItem.Product2Id];
        }
        return null;
    }

    // Função para obter as linhas de itens da cotação
    public static List<QuoteLineItem> getQuoteLineItemsByQuoteId(Id quoteId) {
        return [SELECT Id, QuoteId, Product2Id, Quantity, UnitPrice, Quote.OpportunityId, PricebookEntryId FROM QuoteLineItem WHERE QuoteId = :quoteId];
    } 

    // Função para obter ou criar uma entrada no catálogo de preços
    public static Id getOrCreatePricebookEntryId(Id productId, Id pricebookEntryId) {
        if (pricebookEntryId != null) {
            return pricebookEntryId;
        }

        System.debug('PricebookId:' + Test.getStandardPricebookId());
        
        PricebookEntry newPBE = new PricebookEntry(
            Product2Id = productId,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 0.0,
            IsActive = true
        );
        
        insert newPBE;
        return newPBE.Id;
    }

    // Função privada para obter o primeiro item da cotação
    private static QuoteLineItem getFirstQuoteLineItemByQuoteId(Id quoteId) {
        List<QuoteLineItem> lineItems = [SELECT Id, Product2Id FROM QuoteLineItem WHERE QuoteId = :quoteId LIMIT 1];
        return lineItems.isEmpty() ? null : lineItems[0];
    }
}