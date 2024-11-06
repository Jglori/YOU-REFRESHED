@RestResource(urlMapping = '/whatsapp/webhook')
global class WhatsAppWebhook {
    /**
     * Método responsável pela validação de legitimidade do webhook a partir de
     * verificação de token e challenge.
     */
    @HttpGet
    global static void validarWebhook() {
        WhatsAppService.validarWebhook(RestContext.request, RestContext.response);
    }

    /**
     * Método responsável pela recepção de nova mensagem do WhatsApp e registro
     * em lead relacionado.
     */
    @HttpPost
    global static void cadastrarMensagens() {
        System.debug('Request: ' + RestContext.request.requestBody.toString());
        System.debug('Response: ' + RestContext.response.toString());
        WhatsAppService.cadastrarMensagens(RestContext.request, RestContext.response);
    }
}