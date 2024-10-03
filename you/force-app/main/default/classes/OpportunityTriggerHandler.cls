public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        OpportunityHelper.setDefaultChecklistStatus((List<Opportunity>) Trigger.new);
        OpportunityHelper.addDaysToCloseDateOnCreation((List<Opportunity>) Trigger.new);
    }

    public override void beforeUpdate() {
        OpportunityHelper.validateTransitionToFichaCadastral((List<Opportunity>) Trigger.new, (Map<Id, Opportunity>) Trigger.oldMap);
        OpportunityHelper.handleBeforeUpdate((List<Opportunity>) Trigger.new, (Map<Id, Opportunity>) Trigger.oldMap);
    }
}