public class MembroEquipeTriggerHandler extends TriggerHandler {
    public override void beforeInsert(){
        MembroEquipeHelper.checkDuplicatedMember(Trigger.new);
    }
}