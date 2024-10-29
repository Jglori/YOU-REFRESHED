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
    }

}