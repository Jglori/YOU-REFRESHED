public with sharing class ContatoTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        ContatoHelper.verifyCPF(Trigger.new);
        ContatoHelper.handleStatusCorretor(Trigger.new);
        ContatoHelper.handleCRECIStatus(Trigger.new);
    }
    
    public override void beforeUpdate() {
        ContatoHelper.verifyCPF(Trigger.new);
        ContatoHelper.handleStatusCorretor(Trigger.new);
        ContatoHelper.handleCRECIStatus(Trigger.new);
    }
}