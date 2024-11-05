public with sharing class OpportunityProductsTriggerHandler extends TriggerHandler {
    public override void beforeDelete() {
        OpportunityProductsHelper.validateOpportunityLineItemsForDelete((Map<Id, OpportunityLineItem>)Trigger.oldMap);
    }
}