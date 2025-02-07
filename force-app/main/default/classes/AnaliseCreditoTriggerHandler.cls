public with sharing class AnaliseCreditoTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
        AnaliseCreditoHelper.handleOpportunityFase(Trigger.new);
        AnaliseCreditoHelper.handleStatusForOpportunity(Trigger.new);
        AnaliseCreditoHelper.handleDataVencimento(Trigger.new);
    }
    
    public override void beforeUpdate() {
        AnaliseCreditoHelper.handleOpportunityFase(Trigger.new);
        AnaliseCreditoHelper.handleStatusForOpportunity(Trigger.new);
        AnaliseCreditoHelper.handleDataVencimento(Trigger.new);
        AnaliseCreditoHelper.handleDocumentVerification(Trigger.new);
    }
    
    public override void afterInsert() {
        AnaliseCreditoHelper.handleNotification(Trigger.new);
    }
    
    public override void afterUpdate() {
        AnaliseCreditoHelper.handleNotification(Trigger.new);
    }

}