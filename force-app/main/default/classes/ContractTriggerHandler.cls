public class ContractTriggerHandler extends TriggerHandler{
    public override void afterUpdate(){
        ContratoService.atualizarPrazoAssinatura((List<Contract>) Trigger.new);
    }

    public override void beforeUpdate(){
        ContratoService.evitarGeracaoMultipla((List<Contract>) Trigger.new);
    }
}