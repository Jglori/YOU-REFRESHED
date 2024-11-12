public class ContractTriggerHandler extends TriggerHandler{
    public override void beforeUpdate(){
        ContratoService.evitarGeracaoMultipla((List<Contract>) Trigger.new);
    }
}