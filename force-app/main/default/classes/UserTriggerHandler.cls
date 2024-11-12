public class UserTriggerHandler extends TriggerHandler {
    public override void afterUpdate() {
        ParticipacaoRoletaService.sincronizarParticipantes((List<User>) Trigger.new, (Map<Id, User>) Trigger.oldMap);
    }
}