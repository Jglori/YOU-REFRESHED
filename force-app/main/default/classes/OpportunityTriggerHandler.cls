public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        OpportunityHelper.setDefaultChecklistStatus((List<Opportunity>) Trigger.new);
        OpportunityHelper.addDaysToCloseDateOnCreation((List<Opportunity>) Trigger.new);
    }
    
    public override void beforeUpdate() {
        OpportunityHelper.validateTransitionToFichaCadastral((List<Opportunity>) Trigger.new, (Map<Id, Opportunity>) Trigger.oldMap);
        OpportunityHelper.handleBeforeUpdate((List<Opportunity>) Trigger.new, (Map<Id, Opportunity>) Trigger.oldMap);
       
        OpportunityHelper.handleStageFichaCadastral((List<Opportunity>) Trigger.new);
        // OpportunityHelper.handleOpportunityUpdate((List<Opportunity>) Trigger.new, (Map<Id, Opportunity>) Trigger.oldMap);
        // OpportunityHelper.handleOpportunityUpdate((List<Opportunity>) Trigger.new);
        OpportunityHelper.handleStageFichaCadastralChangeFarolColor((List<Opportunity>)Trigger.new, (Map<Id, Opportunity>)Trigger.oldMap);
        OpportunityHelper.handlePreAnalise((List<Opportunity>) Trigger.new, (Map<Id, Opportunity>) Trigger.oldMap);
    }

/*       public override void afterInsert() {
        OpportunityScheduledJob.scheduleJobsForOpportunities((List<Opportunity>) Trigger.new);
    } */

    
   
}