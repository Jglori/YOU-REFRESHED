public class ParticipantesRoletasTriggerHandler extends TriggerHandler {

    // Método executado após a atualização de registros
    public override void afterUpdate() {
        BolsaoLeadService.distribuirLeads((List<ParticipanteRoleta__c>) Trigger.new);
    }

    // Método executado após a inserção de registros
    public override void afterInsert() {
        BolsaoLeadService.distribuirLeads((List<ParticipanteRoleta__c>) Trigger.new);
    }
}