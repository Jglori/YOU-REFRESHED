public class TabelaVendaHandler extends TriggerHandler{
    public override void afterInsert(){
        TabelaVendasService.inserirUnidadesTabelas((List<TabelaVendas__c>) Trigger.new);
    }

    public override void afterUpdate(){
        tabelaVendasService.inserirUnidadesTabelas((List<TabelaVendas__c>) Trigger.new);
    }
}