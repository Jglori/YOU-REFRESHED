public with sharing class OpportunityHelper {

    private static Map<String, String> mandatoryFields = new Map<String, String>{
        'Amount' => 'Valor da Oportunidade',
        'AccountId' => 'Conta',
        'Name' => 'Nome da Oportunidade',
        'Probability' => 'Probabilidade',
        'CanalAtendimento__c' => 'Canal de Atendimento',
        'TipoVenda__c' => 'Tipo de Venda',
        'Corretor__c' => 'Corretor'
    };

    private static Set<String> validStagesAfterFichaCadastral = new Set<String>{
        'Pré-análise',
        'Geração de Contrato',
        'Conferência',
        'Pagadoria',
        'Fechado Ganho/Desistência'
    };

    public static void addDaysToCloseDateOnCreation(List<Opportunity> newOpps) {
            for (Opportunity opp : newOpps) {
                opp.CloseDate = Date.today().addDays(5);
            }
        }
    
    

    public static void validateTransitionToFichaCadastral(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunitiesMap) {
        for (Opportunity newOpp : newOpportunities) {
            Opportunity oldOpp = oldOpportunitiesMap.get(newOpp.Id);

            if (oldOpp != null && oldOpp.StageName == 'Negociação') {
                if (validStagesAfterFichaCadastral.contains(newOpp.StageName)) {
                    newOpp.addError('Não é permitido avançar diretamente para a fase ' + newOpp.StageName + ' sem passar pela fase "Ficha Cadastral".');
                }

                if (newOpp.StageName == 'Ficha Cadastral') {
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

            if (oldOpp != null && oldOpp.StageName == 'Ficha Cadastral') {
                if (newOpp.StageName == 'Pré-análise') {
                    if (newOpp.FarolChecklistDocumento__c == 'Vermelho') {
                        newOpp.addError('Na fase de Ficha Cadastral, precisamos preencher todos os documentos obrigatórios no Checklist de documentos!');
                    }
                } else if (validStagesAfterFichaCadastral.contains(newOpp.StageName)) {
                    if (oldOpp.StageName != 'Pré-análise') {
                        newOpp.addError('Não é permitido avançar diretamente para a fase ' + newOpp.StageName + ' sem ter passado pela fase "Pré-análise".');
                    }
                }
            }
        }
    }

    private static boolean hasProducts(Id opportunityId) {
        try {
            List<OpportunityLineItem> lineItems = OpportunityDA.getOpportunityLineItems(opportunityId);
            return !lineItems.isEmpty();
        } catch (Exception e) {
            return false;
        }
    }

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
    
    public static void setDefaultChecklistStatus(List<Opportunity> opportunities) {
        for (Opportunity opp : opportunities) {
            opp.FarolChecklistDocumento__c = 'Vermelho';
        }
    }
    

}