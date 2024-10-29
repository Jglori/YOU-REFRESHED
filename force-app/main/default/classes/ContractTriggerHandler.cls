public class ContractTriggerHandler extends TriggerHandler{
    public override void afterUpdate(){
        ContratoService.atualizarPrazoAssinatura((List<Contract>) Trigger.new);
    }
}