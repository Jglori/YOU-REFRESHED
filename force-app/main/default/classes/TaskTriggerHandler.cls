public with sharing class TaskTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        TaskHelper.validateTaskDate(Trigger.new);
        LeadHelper.validateTaskCreation(Trigger.new);
    }

    public override void beforeUpdate() {
        TaskHelper.validateTaskDate(Trigger.new);
        LeadHelper.validateTaskCreation(Trigger.new);
    }
    
    public override void afterUpdate(){
        LeadHelper.updateLeadStatusOnTaskCompletion(Trigger.new, Trigger.oldMap);
    }
}