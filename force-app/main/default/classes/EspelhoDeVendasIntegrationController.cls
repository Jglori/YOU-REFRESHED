public with sharing class EspelhoDeVendasIntegrationController {

    @AuraEnabled
    public static String executeIntegration() {
        try {
            // Chama o serviço para processar a integração
            ListaEspelhoDeVendasService.processIntegration();
            return 'Integração executada com sucesso!';
        } catch (Exception e) {
            // Captura qualquer erro e retorna a mensagem
            System.debug('Erro ao executar a integração: ' + e.getMessage());
            return 'Erro ao executar a integração: ' + e.getMessage();
        }
    }
}