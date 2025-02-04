global class EspelhoDeVendasIntegrationAction {
    @InvocableMethod(label='Executar Integração de Espelho de Vendas' description='Executa a integração de empreendimentos, torres e unidades do Mega.')
    global static void executeIntegration(List<String> input) {
        ListaEspelhoDeVendasService.processIntegration();
    }
}