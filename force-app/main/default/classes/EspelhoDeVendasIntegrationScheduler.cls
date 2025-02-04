global class EspelhoDeVendasIntegrationScheduler implements Schedulable {
    global void execute(SchedulableContext context) {
        ListaEspelhoDeVendasService.processIntegration();
    }
}