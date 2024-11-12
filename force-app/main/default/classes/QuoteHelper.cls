public with sharing class QuoteHelper {
    
    public static void updateOpportunitiesFromQuotes(List<Quote> newQuotes, Map<Id, Quote> oldMap) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        Set<Id> quoteIdsToSync = new Set<Id>();
        Set<Id> oppIdsToUnsync = new Set<Id>();
        
        // Verifica cotações que foram aprovadas e precisam ser sincronizadas
        for (Quote newQuote : newQuotes) {
            Quote oldQuote = oldMap.get(newQuote.Id);
            
            // Sincronizar se entrou em "Aprovada"
            if (newQuote.Status == 'Aprovada' && oldQuote.Status != 'Aprovada') {
                quoteIdsToSync.add(newQuote.Id);
                
                // Envia notificação ao usuário da sessão
                String mensagem = 'A cotação ' + newQuote.Name + ' foi aprovada!';
                enviarNotificacao(mensagem, newQuote.OpportunityId);
            }
            // Desincronizar se saiu de "Aprovada"
            else if (oldQuote.Status == 'Aprovada' && newQuote.Status != 'Aprovada') {
                oppIdsToUnsync.add(newQuote.OpportunityId);
            }
        }
        
        // Sincronizar cotações aprovadas
        if (!quoteIdsToSync.isEmpty()) {
            Map<Id, Quote> quotesMap = QuoteDA.getQuotesMapByIds(new List<Id>(quoteIdsToSync));
            
            for (Quote newQuote : newQuotes) {
                if (quotesMap.containsKey(newQuote.Id)) {
                    Quote quoteFromMap = quotesMap.get(newQuote.Id);
                    Product2 firstProduct = QuoteDA.getProductByQuoteId(newQuote.Id);
                    
                    if (firstProduct != null) {
                        Opportunity opp = new Opportunity(
                            Id = newQuote.OpportunityId,
                        Amount = newQuote.GrandTotal,  // Valor total da cotação
                        Empreendimento__c = firstProduct.Empreendimento__c, // Atualiza o Empreendimento__c
                        Bloco__c = firstProduct.Bloco__c, // Atualiza o Bloco__c
                        CotacaoSincronizada__c = newQuote.Id // Sincroniza a cotação
                            );
                        
                        opp.Unidade__c = firstProduct.Id; // Atualiza o campo Unidade__c (se aplicável)
                        opportunitiesToUpdate.add(opp);
                    }
                }
            }
        }
        
        // Desincronizar cotações que saíram de "Aprovada"
        if (!oppIdsToUnsync.isEmpty()) {
            for (Id oppId : oppIdsToUnsync) {
                Decimal valorZerado = 0.0;
                
                // Cria a oportunidade para atualização
                Opportunity opp = new Opportunity(
                    Id = oppId,
                Amount = 0, // Define o valor de Amount como 0.00
                Empreendimento__c = null, // Remove o empreendimento
                Bloco__c = null, // Remove o bloco
                CotacaoSincronizada__c = null, // Remove a sincronização
                Unidade__c = null // Remove a unidade
                    );
                
                System.debug('Zerando Amount para a Oportunidade: ' + opp);
                opportunitiesToUpdate.add(opp);
            }
        }
        
        // Atualiza as oportunidades com os novos valores
        if (!opportunitiesToUpdate.isEmpty()) {
            try {
                System.debug('Oportunidades a serem atualizadas: ' + opportunitiesToUpdate);
                update opportunitiesToUpdate;
                System.debug('Oportunidades atualizadas com sucesso.');
            } catch (DmlException e) {
                System.debug('Erro ao atualizar oportunidades: ' + e.getMessage());
                System.debug('Oportunidades que falharam: ' + opportunitiesToUpdate);
                throw new AuraHandledException('Erro ao atualizar oportunidades: ' + e.getMessage());
            }
        }
        
        // Adiciona produtos da cotação à oportunidade (caso tenha havido sincronização)
        if (!quoteIdsToSync.isEmpty()) {
            addQuoteProductsToOpportunities(new List<Id>(quoteIdsToSync));
        }
    }
    
    // Função para adicionar produtos da cotação à oportunidade
    public static void addQuoteProductsToOpportunities(List<Id> quoteIds) {
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        
        for (Id quoteId : quoteIds) {
            List<QuoteLineItem> quoteLineItems = QuoteDA.getQuoteLineItemsByQuoteId(quoteId);
            
            for (QuoteLineItem qli : quoteLineItems) {
                OpportunityLineItem oli = new OpportunityLineItem(
                    OpportunityId = qli.Quote.OpportunityId,
                PricebookEntryId = QuoteDA.getOrCreatePricebookEntryId(qli.Product2Id, qli.PricebookEntryId),
                Quantity = qli.Quantity,
                UnitPrice = qli.UnitPrice
                    );
                oppLineItems.add(oli);
            }
        }
        
        if (!oppLineItems.isEmpty()) {
            try {
                insert oppLineItems;
                System.debug('Itens de Oportunidade inseridos: ' + oppLineItems);
            } catch (DmlException e) {
                System.debug('Erro ao inserir itens de Oportunidade: ' + e.getMessage());
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Id> getSalesTeamUserIds() {
        List<Id> teamMemberIds = new List<Id>();
        
        // Obtém o usuário logado
        Id loggedUserId = UserInfo.getUserId();
        
        // Query para obter o usuário logado
        User loggedUser = [SELECT Id, Reportase__c FROM User WHERE Id = :loggedUserId LIMIT 1];
        
        if (loggedUser != null) {
            // Adiciona o usuário logado à lista
            teamMemberIds.add(loggedUser.Id);
            
            // Adiciona membros da equipe acima
            addSalesTeamMembersAbove(loggedUser, teamMemberIds);
            
            // Adiciona membros da equipe abaixo
            addSalesTeamMembersBelow(loggedUser, teamMemberIds);
        }
        
        return teamMemberIds;
    }
    
    private static void addSalesTeamMembersAbove(User user, List<Id> teamMemberIds) {
        if (user.Reportase__c != null) {
            User nextUser = [SELECT Id, Reportase__c FROM User WHERE Id = :user.Reportase__c LIMIT 1];
            if (nextUser != null && !teamMemberIds.contains(nextUser.Id)) {
                teamMemberIds.add(nextUser.Id);
                addSalesTeamMembersAbove(nextUser, teamMemberIds);
            }
        }
    }
    
    private static void addSalesTeamMembersBelow(User user, List<Id> teamMemberIds) {
        List<User> subordinates = [SELECT Id FROM User WHERE Reportase__c = :user.Id];
        for (User subordinate : subordinates) {
            if (!teamMemberIds.contains(subordinate.Id)) {
                teamMemberIds.add(subordinate.Id);
                addSalesTeamMembersBelow(subordinate, teamMemberIds);
            }
        }
    }
    
    public static void enviarNotificacao(String mensagem, Id opportunityId) {
        System.debug('Método enviarNotificacao foi chamado.');
    
        // Consulta o tipo de notificação personalizada
        List<CustomNotificationType> notificacoesPersonalizadas = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'NotificacaoPersonalizada'];
     
        if (!notificacoesPersonalizadas.isEmpty()) {
            System.debug('Tipo de notificação personalizada encontrado.');
            // Busca a equipe de vendas relacionada à oportunidade
            List<SalesTeamController.SalesTeamMember> equipeDeVendas = SalesTeamController.getSalesTeamMembers(opportunityId);
     
            // Prepara a notificação personalizada
            Messaging.CustomNotification notificacao = new Messaging.CustomNotification();
            notificacao.setTitle('Atualização da Cotação');
            notificacao.setBody(mensagem);
            notificacao.setNotificationTypeId(notificacoesPersonalizadas[0].Id); // Define o ID da notificação personalizada
             
            // Verificar se o opportunityId é válido
            if (opportunityId != null) {
                notificacao.setTargetId(opportunityId); // Define o ID de destino da notificação como o ID da oportunidade
                System.debug('Notificação será enviada para a oportunidade: ' + opportunityId);
            } else {
                System.debug('Erro: O ID da Oportunidade está nulo.');
                return;
            }
     
            // Conjunto para armazenar os IDs dos usuários que receberão a notificação
            Set<String> usuariosNotificados = new Set<String>();
     
            // Adiciona o usuário da sessão (usuário logado) ao conjunto de notificação
            usuariosNotificados.add(UserInfo.getUserId());
            System.debug('Usuário logado adicionado para notificação: ' + UserInfo.getUserId());
             
            // Adiciona todos os membros da equipe de vendas ao conjunto
            for (SalesTeamController.SalesTeamMember membro : equipeDeVendas) {
                if (membro.userId != null) {
                    usuariosNotificados.add(membro.userId);
                    System.debug('Adicionando membro da equipe: ' + membro.userName + ' (ID: ' + membro.userId + ')');
                } else {
                    System.debug('Erro: Membro da equipe sem ID de usuário.');
                }
            }
     
            // Verificar se há usuários no conjunto
            if (usuariosNotificados.isEmpty()) {
                System.debug('Nenhum usuário para notificação.');
                return;
            }
     
            // Envia a notificação para toda a equipe de vendas
            try {
                notificacao.send(usuariosNotificados);
                System.debug('Notificações enviadas para os seguintes usuários: ' + usuariosNotificados);
            } catch (Exception e) {
                System.debug('Erro ao enviar notificações: ' + e.getMessage());
            }
        } else {
            System.debug('Nenhum tipo de notificação personalizada encontrado.');
        }
    }
    
}