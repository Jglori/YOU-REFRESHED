public with sharing class ContractTriggerHandler extends TriggerHandler{
    
    public override void beforeUpdate() {
        ContratoService.evitarGeracaoMultipla((List<Contract>) Trigger.new);
        ContractHelper.sendNotification((List<Contract>) Trigger.new);
    }
}