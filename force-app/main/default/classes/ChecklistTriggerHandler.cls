public class ChecklistTriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        ChecklistHelper.updateOpportunityChecklistStatus(Trigger.new);
    }

    public override void afterUpdate() {
        ChecklistHelper.updateOpportunityChecklistStatus(Trigger.new);
    }
}