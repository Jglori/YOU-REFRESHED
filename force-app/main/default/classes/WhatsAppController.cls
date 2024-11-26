public class WhatsAppController {
    @AuraEnabled
    public static String obterLeadPorId(Id idLead) {
        return WhatsAppService.obterLeadPorId(idLead);
    }

    @AuraEnabled
    public static String obterMensagensPorChaveExternaCliente(String chaveExternaCliente) {
        return WhatsAppService.obterMensagensPorChaveExternaCliente(chaveExternaCliente);
    }

    @AuraEnabled
    public static String controlarDialogo(Id idLead) {
        return WhatsAppService.controlarDialogo(idLead);
    }

    @AuraEnabled
    public static String enviarMensagem(Id idLead, String mensagemTexto) {
        return WhatsAppService.enviarMensagem(idLead, mensagemTexto);
    }

    @AuraEnabled
    public static String enviarMidia(Id idLead, String tipoArquivo, String nomeArquivo, String corpoArquivo) {
        return WhatsAppService.enviarMidia(idLead, tipoArquivo, nomeArquivo, corpoArquivo);
    }

    @AuraEnabled
    public static String enviarTemplatePadrao(Id idLead, String nomeTemplate) {
        return WhatsAppService.enviarTemplatePadrao(idLead, nomeTemplate);
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getLeadDetails(String leadId) {
        Map<String, Object> response = new Map<String, Object>();

        // Obtenha as informações do Lead
        Lead leadInfo = LeadSelector.obterInfosTemplatePadrao(leadId);
        response.put('leadInfo', leadInfo);

        // Obtenha o nome da Organização
        Organization orgName = OrganizationSelector.obterNomeOrganizacao();
        response.put('orgName', orgName.Name);

        // Obtenha o nome do Empreendimento
        Empreendimento__c nomeEmpreendimento = EmpreendimentoSelector.obterNomeEmpreendimentoById(leadInfo.EmpreendimentoInteresse__c);
        response.put('nomeEmpreendimento', nomeEmpreendimento.Name);

        return response;
    }
}