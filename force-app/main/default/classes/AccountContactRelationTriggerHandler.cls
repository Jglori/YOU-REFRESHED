public with sharing class AccountContactRelationTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        AccountContactRelationHelper.processBeforeInsert((List<OpportunityContactRole>) Trigger.new);
    }
    
    public override void beforeUpdate() {
        AccountContactRelationHelper.processBeforeUpdate((List<OpportunityContactRole>) Trigger.new, (Map<Id, OpportunityContactRole>) Trigger.oldMap);
    }
}
