public with sharing class OpportunityHelper {

    private static Map<String, String> mandatoryFields = new Map<String, String>{
        'Amount' => 'Valor da Oportunidade',
        'AccountId' => 'Conta',
        'Name' => 'Nome da Oportunidade',
        'Probability' => 'Probabilidade',
        'CanalAtendimento__c' => 'Canal de Atendimento',
        'TipoVenda__c' => 'Tipo de Venda'
    };

    private static Set<String> validStagesAfterFichaCadastral = new Set<String>{
        'Pré-análise',
        'Geração de Contrato',
        'Conferência',
        'Pagadoria',
        'Ganho'
    };

    

    public static List<Opportunity> getByIds(Set<Id> ids) {
        if (ids == null) throw new IllegalArgumentException('A lista de ids não deve null.');

        List<Opportunity> opps = OpportunityDA.getAllById(ids);
        
        if (opps == null || opps.isEmpty()) throw new IllegalArgumentException('Nenhum registro de opportunidade encontrado.');
        
        return opps;
    }


    public static void addDaysToCloseDateOnCreation(List<Opportunity> newOpps) {
            for (Opportunity opp : newOpps) {
                opp.CloseDate = Date.today().addDays(5);
            }
        }


        public static void validateTransitionToFichaCadastral(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunitiesMap) {
            for (Opportunity newOpp : newOpportunities) {
                Opportunity oldOpp = oldOpportunitiesMap.get(newOpp.Id);
                
                if (oldOpp.StageName != 'Negociação' || newOpp.StageName != 'Ficha Cadastral') continue;
    
                boolean hasSyncedQuote = OpportunityDA.hasSyncedQuote(newOpp.Id);
                boolean hasProducts = hasProducts(newOpp.Id);
                boolean hasBuyers = hasBuyers(newOpp.Id);
    
                for (String fieldName : mandatoryFields.keySet()) {
                    if (newOpp.get(fieldName) == null || String.isBlank(String.valueOf(newOpp.get(fieldName)))) {
                        newOpp.addError(mandatoryFields.get(fieldName) + ' é um campo obrigatório.');
                    }
                }
    
                if (!hasSyncedQuote || !hasProducts || !hasBuyers) {
                    String errorMessage = 'Não é possível avançar para a Ficha Cadastral:';
                    if (!hasSyncedQuote) {
                        errorMessage += '\n- Favor sincronizar uma cotação com a oportunidade.';
                    }
                    if (!hasProducts) {
                        errorMessage += '\n- Pelo menos um produto da oportunidade deve ser adicionado.';
                    }
                    if (!hasBuyers) {
                        errorMessage += '\n- Pelo menos um comprador (papel de contato) deve ser especificado.';
                    }
                    newOpp.addError(errorMessage);
                }
            }
        }
    
        

    @TestVisible
    private static boolean hasProducts(Id opportunityId) {
        try {
            List<OpportunityLineItem> lineItems = OpportunityDA.getOpportunityLineItems(opportunityId);
            return !lineItems.isEmpty();
        } catch (Exception e) {
            return false;
        }
    }

    @TestVisible
    private static boolean hasBuyers(Id opportunityId) {
        try {
            List<OpportunityContactRole> contactRoles = OpportunityDA.getOpportunityContactRoles(opportunityId);
            return !contactRoles.isEmpty();
        } catch (Exception e) {
            return false;
        }
    }

    public static void handleBeforeUpdate(List<Opportunity> newOpps, Map<Id, Opportunity> oldOpps) {
        for (Opportunity newOpp : newOpps) {
            Opportunity oldOpp = oldOpps.get(newOpp.Id);

            if (!String.isBlank(newOpp.SyncedQuoteId)) {
                Boolean isEmpreendimentoChanged = newOpp.Empreendimento__c != oldOpp.Empreendimento__c;

                if (isEmpreendimentoChanged) {
                    newOpp.addError('Não é possível editar o campo Empreendimento enquanto a oportunidade está sincronizada com uma cotação. Desative a sincronização para editar.');
                }
            }
        }
        
    }
    
    public static void handleStageFichaCadastralChangeFarolColor(
        List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap
    ) {
        if (newOpps == null || newOpps.isEmpty() || oldOppMap == null || oldOppMap.isEmpty()) {
            throw new IllegalArgumentException('A lista de Oportunidades não deve ser nula ou vazia.');
        }

        Set<Id> oppIdsToProcess = new Set<Id>();
        for (Opportunity newOpp : newOpps) {
            Opportunity oldOpp = oldOppMap.get(newOpp.Id);
            if (oldOpp != null && 'Ficha Cadastral'.equals(oldOpp.StageName)) {
                oppIdsToProcess.add(newOpp.Id);
            }
        }
        if (oppIdsToProcess.isEmpty()) return;

        Map<Id, List<String>> oppToRolesMap = new Map<Id, List<String>>();
        for (OpportunityContactRole cr : [
            SELECT OpportunityId, Role FROM OpportunityContactRole 
            WHERE OpportunityId IN :oppIdsToProcess AND Role != null
        ]) {
            if (!oppToRolesMap.containsKey(cr.OpportunityId)) {
                oppToRolesMap.put(cr.OpportunityId, new List<String>());
            }
            oppToRolesMap.get(cr.OpportunityId).add(cr.Role);
        }

        if(oppToRolesMap.isEmpty()) {
            for (Opportunity opp : newOpps) {
                opp.FarolChecklistDocumento__c = 'Vermelho';
            }
        }


        Map<String, List<Documento__mdt>> roleToDocumentsMap = new Map<String, List<Documento__mdt>>();
        for (Documento__mdt doc : [
            SELECT Nome_do_Documento__c, Obrigatorio__c, Papel__c FROM Documento__mdt
        ]) {
            if (!roleToDocumentsMap.containsKey(doc.Papel__c)) {
                roleToDocumentsMap.put(doc.Papel__c, new List<Documento__mdt>());
            }
            roleToDocumentsMap.get(doc.Papel__c).add(doc);
        }

        Map<Id, List<Checklist_de_Documentos__c>> oppToDocumentsMap = new Map<Id, List<Checklist_de_Documentos__c>>();
        for (Checklist_de_Documentos__c checklistDoc : ChecklistDA.getWithDocumentsByOpportunity(oppIdsToProcess)) {
            if (!oppToDocumentsMap.containsKey(checklistDoc.Oportunidade__c)) {
                oppToDocumentsMap.put(checklistDoc.Oportunidade__c, new List<Checklist_de_Documentos__c>());
            }
            oppToDocumentsMap.get(checklistDoc.Oportunidade__c).add(checklistDoc);
        }
    
        for (Opportunity newOpp : newOpps) {
            if (!oppIdsToProcess.contains(newOpp.Id)) continue;
    
            Integer totalMandatoryCount = 0;
            Integer totalOptionalCount = 0;
    
            List<String> roles = oppToRolesMap.get(newOpp.Id);
            if (roles != null) {
                for (String role : roles) {
                    List<Documento__mdt> documents = roleToDocumentsMap.get(role);
                    if (documents != null) {
                        for (Documento__mdt doc : documents) {
                            if (doc.Obrigatorio__c) {
                                totalMandatoryCount++;
                            } else {
                                totalOptionalCount++;
                            }
                        }
                    }
                }
            }
    
            Integer deliveredMandatoryCount = 0;
            Integer deliveredOptionalCount = 0;
    
            List<Checklist_de_Documentos__c> documents = oppToDocumentsMap.get(newOpp.Id);
            if (documents != null) {
                for (Checklist_de_Documentos__c checklistDoc : documents) {
                    Documentacao__c doc = checklistDoc.Documenta_o__r;
                    if (doc != null && doc.Entregue__c) {
                        if (doc.Obrigatorio__c) {
                            deliveredMandatoryCount++;
                        } else {
                            deliveredOptionalCount++;
                        }
                    }
                }
            }
    
            if (deliveredMandatoryCount < totalMandatoryCount) {
                newOpp.FarolChecklistDocumento__c = 'Vermelho';
            } else if (deliveredMandatoryCount == totalMandatoryCount &&
                       deliveredMandatoryCount + deliveredOptionalCount < totalMandatoryCount + totalOptionalCount) {
                newOpp.FarolChecklistDocumento__c = 'Verde';
            } else if (deliveredMandatoryCount + deliveredOptionalCount == totalMandatoryCount + totalOptionalCount) {
                newOpp.FarolChecklistDocumento__c = 'Azul';
            }
        }
    }    

    public static void setDefaultChecklistStatus(List<Opportunity> opportunities) {
        for (Opportunity opp : opportunities) {
            opp.FarolChecklistDocumento__c = 'Vermelho';
        }
    }

    
    public static void handleStageFichaCadastral(List<Opportunity> newOpps) {
        if (newOpps == null || newOpps.isEmpty()) throw new IllegalArgumentException('A lista de Opportunidade não deve ser nula ou vazia.');

        Set<Id> setOppsId = new Set<Id>();
        for (Opportunity opp : newOpps) {
            if (opp.StageName == null ) throw new IllegalArgumentException('Stage de Oportunidade não deve ser null.');
            if (opp.StageName == 'Pré-análise' && opp.FarolChecklistDocumento__c == 'Vermelho') {
                opp.addError('Na fase de Ficha cadastral, precisamos preencher todos os documentos obrigatório no Checklist de documentos!');
            }
        }
    }

    public static List<Opportunity> getByAnaliseCreditoId(Set<Id> analisesCreditoId ) {
        List<Opportunity> opps = OpportunityDA.getAllByAnaliseCreditoId(analisesCreditoId);
        if (opps.isEmpty()) {
            throw new IllegalArgumentException('Nenhuma Oportunidade encontrada! Ids inválidos.');
        }
        return opps;
    }

    public static void handlePreAnalise(List<Opportunity> newOpps, Map<Id, Opportunity> oldOpps) {

        Set<Id> unidadeIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
    
        for (Opportunity newOpp : newOpps) {
            Opportunity oldOpp = oldOpps.get(newOpp.Id);
    
            if (oldOpp != null && oldOpp.StageName != 'Pré-análise' && newOpp.StageName == 'Pré-análise') {
                if (newOpp.Unidade__c != null) {
                    unidadeIds.add(newOpp.Unidade__c);
                }
                opportunityIds.add(newOpp.Id);
            }
        }
    
        List<Product2> oppsUnitys = ProdutoSelector.obterUnidadesPorSetId(unidadeIds);
        List<Checklist_de_Documentos__c> oppDocs = ChecklistDA.getWithDocumentsByOpportunity(opportunityIds);
    
        Map<Id, Product2> unidadeMap = new Map<Id, Product2>();
        for (Product2 unidade : oppsUnitys) {
            unidadeMap.put(unidade.Id, unidade);
        }
    
        Map<Id, List<Checklist_de_Documentos__c>> checklistMap = new Map<Id, List<Checklist_de_Documentos__c>>();
        for (Checklist_de_Documentos__c doc : oppDocs) {
            if (!checklistMap.containsKey(doc.Oportunidade__c)) {
                checklistMap.put(doc.Oportunidade__c, new List<Checklist_de_Documentos__c>());
            }
            checklistMap.get(doc.Oportunidade__c).add(doc);
        }
    
        List<Product2> updatedUnitys = new List<Product2>();
        List<FeedItem> postsChatter = new List<FeedItem>();

        for (Opportunity newOpp : newOpps) {
            Opportunity oldOpp = oldOpps.get(newOpp.Id);
    
            Product2 unity = unidadeMap.get(newOpp.Unidade__c);
    

            if (unity != null) {
                if (unity.Status__c == 'Reservada') {
                    Date dataDeReserva = (unity != null && unity.DataDeReserva__c != null) ? unity.DataDeReserva__c : null;

                    String mensagemChatter; 

                    if(dataDeReserva == null){
                        mensagemChatter = 
                        'A unidade da oportunidade esta reservada. Por favor, analise a situação.';
                    } else {
                        mensagemChatter = 
                        'A unidade permanece reservada até: ' + dataDeReserva.format() + 
                        '. Por favor, avalie a situação.';
                    } 

                    
                    FeedItem post = new FeedItem();
                    post.ParentId = newOpp.Id;
                    post.Body = mensagemChatter;

                    postsChatter.add(post);
                    continue;
                }

                unity.Status__c = 'Reservada';
                updatedUnitys.add(unity);
            }
    
            if (unity != null && unity.Enquadramento__c == 'HIS') {
                List<Checklist_de_Documentos__c> docs = checklistMap.get(newOpp.Id);
    
                if (docs != null && !docs.isEmpty()) {
                    for (Checklist_de_Documentos__c doc : docs) {
                        if (doc.Documenta_o__r.Obrigatorio__c && !doc.Documenta_o__r.Entregue__c) {
                                newOpp.addError('Para prosseguir para a fase de Pré-Análise, é necessário preencher todos os documentos obrigatórios.');
                        }
                    }
                }
            }
        }
 
        if (!postsChatter.isEmpty()) {
            try{
                insert postsChatter;    
            } catch (DmlException e) {
                System.debug('Erro ao inserir mensagem no chatter: ' + e.getMessage());
            }
        }

        
        if (!updatedUnitys.isEmpty()) {
            try {
                update updatedUnitys;
            } catch (DmlException e) {
                System.debug('Erro ao atualizar as unidades: ' + e.getMessage());
                
            }
        }
    }

       /**
 * Este método prepara e envia notificações de cancelamento de oportunidade.
 * As notificações incluem e-mails e mensagens no Chatter para os responsáveis e hierarquias relacionadas
 * quando se move para a fase cancelada na oportunidade.
 */
public static void handleOpportunityCancelation(List<Opportunity> newOpps, Map<Id, Opportunity> oldOpps) {
    List<Opportunity> opportunitiesToNotify = new List<Opportunity>();
    Set<Id> oppIds = new Set<Id>();

    for (Opportunity opp : newOpps) {
        Opportunity oldOpp = oldOpps.get(opp.Id);

        // Verifica se a oportunidade foi movida para a fase de "Cancelado"
        if (opp.StageName == 'Cancelado' && (oldOpp == null || oldOpp.StageName != 'Cancelado')) {
            if (String.isBlank(opp.MotivoCancelamento__c)) {
                opp.addError('O campo Motivo de Cancelamento é obrigatório.');
            } else if (opp.MotivoCancelamento__c == 'Outros' && String.isBlank(opp.Observacao__c)) {
                opp.addError('O campo Observação é obrigatório quando o motivo de cancelamento for "Outros".');
            } else {
                opportunitiesToNotify.add(opp);
                oppIds.add(opp.Id);
            }
        }
    }

    if (!opportunitiesToNotify.isEmpty()) {
        List<Opportunity> oppsWithDetails = [
            SELECT Id, Name, MotivoCancelamento__c, Unidade__c, Unidade__r.Name,
                   Contato__r.Name, Contato__r.Email, Contato__r.OwnerId,
                   Contato__r.UsuarioCorretor__r.Name, Contato__r.UsuarioCorretor__r.Email
             FROM Opportunity
            WHERE Id IN :oppIds
        ];

        Map<Id, Opportunity> oppDetailsMap = new Map<Id, Opportunity>(oppsWithDetails);

        for (Opportunity opp : opportunitiesToNotify) {
            if (oppDetailsMap.containsKey(opp.Id)) {
                Opportunity detailedOpp = oppDetailsMap.get(opp.Id);
                opp.Unidade__c = detailedOpp.Unidade__c;
                opp.Unidade__r = detailedOpp.Unidade__r;
                opp.Contato__r = detailedOpp.Contato__r;
            }
        }

        sendCancelNotification(opportunitiesToNotify);
    }
}




/**
* Este método prepara e envia notificações de cancelamento de oportunidade.
* As notificações incluem e-mails e mensagens no Chatter para os responsáveis e hierarquias relacionadas.
*/

public static void sendCancelNotification(List<Opportunity> opportunitiesToNotify) {
    List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    List<FeedItem> chatterFeedItems = new List<FeedItem>();
    
  
    EmailTemplate emailTemplate = [SELECT Id, Name, HtmlValue 
                                   FROM EmailTemplate 
                                   WHERE Name = 'Template Cancelamento da Oportunidade' LIMIT 1];
    
    for (Opportunity opp : opportunitiesToNotify) {
        String subject = 'Notificação de Cancelamento da Oportunidade: ' + opp.Name;
        
      
        String htmlBody = emailTemplate.HtmlValue;
        if (htmlBody != null) {
            htmlBody = htmlBody.replace('{{{Opportunity.Name}}}', opp.Name != null ? opp.Name : 'N/A');
            htmlBody = htmlBody.replace('{{{Product2.Name}}}', opp.Unidade__r != null ? opp.Unidade__r.Name : 'N/A');
            htmlBody = htmlBody.replace('{{{Opportunity.MotivoCancelamento__c}}}', opp.MotivoCancelamento__c != null ? opp.MotivoCancelamento__c : 'N/A');
            htmlBody = htmlBody.replace('{{{Opportunity.Observacao__c}}}', opp.Observacao__c != null ? opp.Observacao__c : 'N/A');
        }
        
       
        String chatterMessage = 'Oportunidade Cancelada\n\n' +
                                'Oportunidade: ' + opp.Name + '\n' +
                                'Produto: ' + (opp.Unidade__r != null ? opp.Unidade__r.Name : 'N/A') + '\n' +
                                'Motivo do Cancelamento: ' + (opp.MotivoCancelamento__c != null ? opp.MotivoCancelamento__c : 'N/A') + '\n' +
                                'Observação: ' + (opp.Observacao__c != null ? opp.Observacao__c : 'N/A') + '\n\n' +
                                'Infelizmente, a oportunidade foi cancelada devido ao motivo acima.\n\n' +
                                'Atenciosamente,\nEquipe de Vendas';
        
        FeedItem opportunityChatter = new FeedItem();
        opportunityChatter.ParentId = opp.Id; 
        opportunityChatter.Body = chatterMessage;
        chatterFeedItems.add(opportunityChatter);
        
     
        if (opp.Contato__r != null && opp.Contato__r.OwnerId != null) {
            User contactOwner = [SELECT Id, Name, Email, Reportase__c 
                                 FROM User 
                                 WHERE Id = :opp.Contato__r.OwnerId LIMIT 1];
            if (contactOwner != null) {
             
                if (contactOwner.Email != null) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[] {contactOwner.Email});
                    email.setSubject(subject);
                    email.setHtmlBody(htmlBody);
                    emailsToSend.add(email);
                }

    
              
                notifyReportees(contactOwner, opp, subject, htmlBody, chatterFeedItems, emailsToSend);
            }
        }
    }
    
  
    if (!emailsToSend.isEmpty()) {
        try {
            Messaging.sendEmail(emailsToSend);
        } catch (Exception e) {
            System.debug('Erro ao enviar e-mails: ' + e.getMessage());
        }
    }
    
    
    if (!chatterFeedItems.isEmpty()) {
        try {
            insert chatterFeedItems;
        } catch (Exception e) {
            System.debug('Erro ao inserir mensagens no Chatter: ' + e.getMessage());
        }
    }
}



/**
* Este método notifica as hierarquias de usuários relacionadas (como "reportase") em relação ao cancelamento da oportunidade.
* É chamado recursivamente para notificar usuários hierárquicos.
*/
private static void notifyReportees(User currentUser, Opportunity opp, String subject, String htmlBody, 
                                    List<FeedItem> chatterFeedItems, List<Messaging.SingleEmailMessage> emailsToSend) {
  
    if (currentUser.Reportase__c != null) {
        User reportee = [SELECT Id, Name, Email, Reportase__c 
                         FROM User 
                         WHERE Id = :currentUser.Reportase__c LIMIT 1];
        if (reportee != null) {
        
            if (reportee.Email != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {reportee.Email});
                email.setSubject(subject);
                email.setHtmlBody(htmlBody);
                emailsToSend.add(email);
            }

    
          
            notifyReportees(reportee, opp, subject, htmlBody, chatterFeedItems, emailsToSend);
        }
    }
}






    /**
 * Este método prepara e envia notificações de cancelamento de oportunidade.
 * As notificações incluem e-mails e mensagens no Chatter para os responsáveis e hierarquias relacionadas
 * gando a oportunidade é movida para ganho de acordo com a parametrização.
 */

public static void handleOpportunityUpdate(List<Opportunity> updatedOpportunities) {
    List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
    Set<Id> oppIds = new Set<Id>();

    Date today = System.today();

    for (Opportunity opp : updatedOpportunities) {
        
        if (opp.StageName == 'Conferência') {
            if (opp.Data_Assinatura_Contrato__c != null && opp.Dias_Apos_Assinatura__c != null) {
                Date assinaturaData = opp.Data_Assinatura_Contrato__c;
                Integer diasAposAssinatura = Integer.valueOf(opp.Dias_Apos_Assinatura__c);  
                Date dataLimite = assinaturaData.addDays(diasAposAssinatura);

               
                if (dataLimite <= today) {
                    Opportunity oppToUpdate = new Opportunity(Id = opp.Id, StageName = 'Ganho');
                    opportunitiesToUpdate.add(oppToUpdate);
                    oppIds.add(opp.Id);
                }
            }
        }
    }

    
    if (!opportunitiesToUpdate.isEmpty()) {
      
        List<Opportunity> oppsWithDetails = [
            SELECT Id, Name, MotivoCancelamento__c, Unidade__c, Unidade__r.Name,
                Contato__r.Name, Contato__r.Email, Contato__r.OwnerId,
                Contato__r.UsuarioCorretor__r.Name, Contato__r.UsuarioCorretor__r.Email, Observacao__c
            FROM Opportunity
            WHERE Id IN :oppIds
        ];

        
        Map<Id, Opportunity> oppDetailsMap = new Map<Id, Opportunity>(oppsWithDetails);

      
        for (Opportunity opp : opportunitiesToUpdate) {
            if (oppDetailsMap.containsKey(opp.Id)) {
                Opportunity detailedOpp = oppDetailsMap.get(opp.Id);
                opp.Name = detailedOpp.Name;  
                opp.Unidade__c = detailedOpp.Unidade__c;
                opp.Unidade__r = detailedOpp.Unidade__r;
                opp.Contato__r = detailedOpp.Contato__r;
                opp.Observacao__c = detailedOpp.Observacao__c;
                
            }
        }

     
        try {
            update opportunitiesToUpdate;
            System.debug('Oportunidades movidas para "Ganho".');
            sendVictoryNotification(opportunitiesToUpdate);
        } catch (Exception e) {
            System.debug('Erro ao atualizar oportunidades: ' + e.getMessage());
        }
    }
}




/**
* Este método prepara e envia notificações do vencimento da oportunidade.
* As notificações incluem e-mails e mensagens no Chatter para os responsáveis e hierarquias relacionadas.
*/
public static void sendVictoryNotification(List<Opportunity> opportunitiesToUpdate) {
    List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    List<FeedItem> chatterFeedItems = new List<FeedItem>();

    EmailTemplate emailTemplate = [SELECT Id, Name, HtmlValue 
                                   FROM EmailTemplate 
                                   WHERE Name = 'Template Vitoria da Oportunidade' LIMIT 1];

    for (Opportunity opp : opportunitiesToUpdate) {
        String subject = 'Notificação de Vitória da Oportunidade: ' + opp.Name;

        String htmlBody = emailTemplate.HtmlValue;
        if (htmlBody != null) {
            htmlBody = htmlBody.replace('{{{Opportunity.Name}}}', opp.Name != null ? opp.Name : 'N/A');
            htmlBody = htmlBody.replace('{{{Product2.Name}}}', opp.Unidade__r != null ? opp.Unidade__r.Name : 'N/A');
            htmlBody = htmlBody.replace('{{{Opportunity.Observacao__c}}}', opp.Observacao__c != null ? opp.Observacao__c : 'N/A');
        }

        String chatterMessage = 'Notificação de Vitória da Oportunidade:Parábens! A oportunidade foi ganha.\n\n' +
                                'Oportunidade: ' + opp.Name + '\n' +
                                'Produto: ' + (opp.Unidade__r != null ? opp.Unidade__r.Name : 'N/A') + '\n' +
                                'Observação: ' + (opp.Observacao__c != null ? opp.Observacao__c : 'N/A') + '\n\n' +
                                'Parabéns, a oportunidade foi vencida com sucesso.\n\n' +
                                'Atenciosamente,\nEquipe de Vendas';

        FeedItem opportunityChatter = new FeedItem();
        opportunityChatter.ParentId = opp.Id; 
        opportunityChatter.Body = chatterMessage;
        chatterFeedItems.add(opportunityChatter);

        
        if (opp.Contato__r != null && opp.Contato__r.OwnerId != null) {
            User contactOwner = [SELECT Id, Name, Email, Reportase__c 
                                 FROM User 
                                 WHERE Id = :opp.Contato__r.OwnerId LIMIT 1];
            if (contactOwner != null) {
                if (contactOwner.Email != null) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[] {contactOwner.Email});
                    email.setSubject(subject);
                    email.setHtmlBody(htmlBody);
                    emailsToSend.add(email);
                }
              
                notifyReporteesRecursively(contactOwner, opp, subject, htmlBody, chatterFeedItems, emailsToSend);
            }
        }
    }

    
    if (!emailsToSend.isEmpty()) {
        try {
            Messaging.sendEmail(emailsToSend);
        } catch (Exception e) {
            System.debug('Erro ao enviar e-mails: ' + e.getMessage());
        }
    }

    
    if (!chatterFeedItems.isEmpty()) {
        try {
            insert chatterFeedItems;
        } catch (Exception e) {
            System.debug('Erro ao inserir mensagens no Chatter: ' + e.getMessage());
        }
    }
}







/**
* Este método notifica as hierarquias de usuários relacionadas (como "reportase") em relação a conferencia da oportunidade.
* É chamado recursivamente para notificar usuários hierárquicos quando a oportunidade é ganha.
*/
private static void notifyReporteesRecursively(User currentUser, Opportunity opp, String subject, String htmlBody, 
                                               List<FeedItem> chatterFeedItems, List<Messaging.SingleEmailMessage> emailsToSend) {
    if (currentUser.Reportase__c != null) {
        User reportee = [SELECT Id, Name, Email, Reportase__c 
                         FROM User 
                         WHERE Id = :currentUser.Reportase__c LIMIT 1];
        if (reportee != null) {
            if (reportee.Email != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {reportee.Email});
                email.setSubject(subject);
                email.setHtmlBody(htmlBody);
                emailsToSend.add(email);
            }

            
            notifyReporteesRecursively(reportee, opp, subject, htmlBody, chatterFeedItems, emailsToSend);
        }
    } 
  }
}