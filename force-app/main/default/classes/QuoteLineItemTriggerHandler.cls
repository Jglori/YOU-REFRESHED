public with sharing class QuoteLineItemTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        List<QuoteLineItem> newQuoteLineItems = (List<QuoteLineItem>) Trigger.new;
        QuoteLineItemHelper.validateQuoteLineItems(newQuoteLineItems);
    }
    // public override void beforeDelete() {
    //     for (OpportunityLineItem oli : (List<OpportunityLineItem>) Trigger.old) {
    //         oli.addError('Não é permitido deletar produtos diretamente da oportunidade.');
    //     }
    
}