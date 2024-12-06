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
        try {
            // Envia o template
            WhatsAppService.enviarTemplatePadrao(idLead, nomeTemplate);
    
            // Atualiza o remetente
            WhatsAppService.atualizarRemetenteWhatsApp(idLead);
    
            return 'Template enviado com sucesso';
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao enviar template: ' + e.getMessage());
        }
    }    

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getLeadDetails(String leadId) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            // Obtenha as informações do Lead
            Lead leadInfo = LeadSelector.obterInfosTemplatePadrao(leadId);
            if (leadInfo == null) {
                throw new AuraHandledException('Lead não encontrado para o ID fornecido: ' + leadId);
            }
            response.put('leadInfo', leadInfo);
    
            // Obtenha o nome da Organização
            Organization orgName =  OrganizationSelector.obterNomeOrganizacao();
            if (orgName == null) {
                throw new AuraHandledException('Organização não encontrada.');
            }
            response.put('orgName', orgName.Name);
    
            // Obtenha o nome do Empreendimento
            Empreendimento__c nomeEmpreendimento = EmpreendimentoSelector.obterNomeEmpreendimentoById(leadInfo.EmpreendimentoInteresse__c);
            if (nomeEmpreendimento == null) {
                throw new AuraHandledException('Empreendimento não encontrado para o ID: ' + leadInfo.EmpreendimentoInteresse__c);
            }
            response.put('nomeEmpreendimento', nomeEmpreendimento.Name);
    
        } catch (Exception e) {
            // Tratar erros e lançar uma exceção personalizada
            throw new AuraHandledException('Erro ao buscar os detalhes do Lead: ' + e.getMessage());
        }

        System.debug('response para tempalte: ' + response);
        return response;
    }
    
}