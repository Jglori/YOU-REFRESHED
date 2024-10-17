public class RoletaLeadsTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        RoletaLeadsHelper.scheduleRoletaCleanUp(Trigger.new);
    }

    public override void afterUpdate() {
        RoletaLeadsHelper.scheduleRoletaCleanUp(Trigger.new);
    }
}