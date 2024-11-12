public with sharing class QuoteTriggerHandler extends TriggerHandler {
    public override void afterUpdate(){
        QuoteHelper.updateOpportunitiesFromQuotes(Trigger.new, (Map<Id, Quote>) Trigger.oldMap);
    }
}