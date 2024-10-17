public class ContentVersionTriggerHandler extends TriggerHandler {
    protected override void afterInsert() {
        InicializarArquivosService.distribuirArquivos((List<ContentVersion>) Trigger.new);
    }
}