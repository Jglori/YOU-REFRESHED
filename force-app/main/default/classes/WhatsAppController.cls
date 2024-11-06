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

    // @AuraEnabled
    // public static void invocarEnvioMensagem(String numeroLead, String textoMensagem) {
    //     (new WhatsAppService()).responderConversaTexto(numeroLead, textoMensagem);
    // }

    // @InvocableMethod
    // public static void invocarEnvioMensagemAutomatica(List<Lead> leads) {
    //     WhatsAppService whatsAppService = new WhatsAppService();
    //     for(Lead leadRecord : leads) {
    //         String mensagemTemplate = '';
    //         Integer numeroMsg = (Integer) leadRecord.NumeracaoMensagem__c;
    //         MensagemWebhook__c salesforceMessage = [SELECT Id, TextBody__c, Lead__c FROM MensagemWebhook__c WHERE Lead__c = :leadRecord.Id ORDER By CreatedDate DESC LIMIT 1];
    //         switch on numeroMsg {
    //             when 1 {
    //                 mensagemTemplate = 'Olá, bom dia! Obrigado por entrar em contato conosco. \nPara melhorar seu atendimento, gotariamos de saber se podemos coletar alguns dados para te conhecer melhor. \nPor favor, informe seu apenas primeiro nome.';
    //             }
    //             when 2 {
    //                 leadRecord.FirstName = salesforceMessage.TextBody__c;
    //                 mensagemTemplate = 'Para darmos continuidade, informe apenas seu sobrenome.';
    //             }
    //             when 3 {
    //                 leadRecord.LastName = salesforceMessage.TextBody__c;
    //                 mensagemTemplate = 'Por fim, informe seu e-mail.';
    //             }
    //             when 4 {
    //                 leadRecord.Email = salesforceMessage.TextBody__c;
    //                 mensagemTemplate = 'Agradecemos as informações enviadas! Estamos te transferindo para um atendente.';
    //             }
    //             when else {
    //                 return;
    //             }
    //         }
    //         WhatsAppController.programarMensagem(leadRecord.MobilePhone, mensagemTemplate);
    //         leadRecord.NumeracaoMensagem__c++;
    //     }
    //     Database.update(leads);
    // }
}