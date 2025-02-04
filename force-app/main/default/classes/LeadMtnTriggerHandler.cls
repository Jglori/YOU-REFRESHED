public class LeadMtnTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        // Inicia o processamento Queueable com o primeiro Lead_MTN__c
        if (!Trigger.new.isEmpty()) {
            System.enqueueJob(new ProcessLeadMtnQueueable(Trigger.new, 0));
        }
    }
}