trigger QuoteLineItemTrigger on QuoteLineItem  (before insert) {
    new QuoteLineItemTriggerHandler().run();
}