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
        'Fechado Ganho/Desistência'
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

}