public class ParticipanteRoletaTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        DistribuirLeadsService.distribuirLeads((List<ParticipanteRoleta__c>) Trigger.new);
    }

    public override void afterUpdate() {
        DistribuirLeadsService.distribuirLeads((List<ParticipanteRoleta__c>) Trigger.new);
    }
}