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

    private static List<Schema.PicklistEntry> stages = Opportunity.StageName.getDescribe().getPicklistValues();

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
                Boolean checklistApproved = OpportunityDA.getOpportunityWithChecklistAproval(newOpp.Id);

                if (newOpp.StageName == 'Pré-análise') {
                     if (!checklistApproved && newOpp.FarolChecklistDocumento__c == 'Vermelho') {
                        newOpp.addError('É necessário preencher todos os documentos obrigatórios no checklist ou solicitar a aprovação do superior.');
                    }
                } else if (validStagesAfterFichaCadastral.contains(newOpp.StageName)) {
                    if (oldOpp.StageName != 'Pré-análise') {
                        newOpp.addError('Não é permitido avançar diretamente para a fase ' + newOpp.StageName + ' sem ter passado pela fase "Pré-análise".');
                    }
                }
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

    public static void handlePreAnaliseForAnaliseCredito(List<Opportunity> newOpps) {
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : newOpps) {
            oppIds.add(opp.Id);
        }
        Map<Id, Integer> mapAnalisesRelacionadas = OpportunityDA.getAnaliseCreditoCountByOpportunity(oppIds);
        System.debug(mapAnalisesRelacionadas);
    
        for (Opportunity newOpp : newOpps) {
            Integer pos = comparePosition('Pré-análise', newOpp.StageName);
            Integer quantidadeAnalises = mapAnalisesRelacionadas.get(newOpp.Id);
            System.debug(quantidadeAnalises);
            
            if (pos < 0 && (quantidadeAnalises == null || quantidadeAnalises == 0)) {
                newOpp.addError('Por favor, associe uma Análise de Crédito para avançar de fase.');
            }
        }
    }
    

    private static Integer comparePosition(String fstPosition, String sndPosition) {
        Integer fstValue = 0;
        Integer sndValue = 0;
        for (Integer i = 0; i < stages.size(); i++) {            
            if (stages.get(i).getValue() == fstPosition) fstValue = i;
            if (stages.get(i).getValue() == sndPosition) sndValue = i;
        }
        if (fstValue > sndValue) return 1;
        else if (fstValue < sndValue) return -1;
        else return 0;
    }
    
    public static void setDefaultChecklistStatus(List<Opportunity> opportunities) {
        for (Opportunity opp : opportunities) {
            opp.FarolChecklistDocumento__c = 'Vermelho';
        }
    }

    public static void verificarProibirConferencia(List<Opportunity> opps){
        Set<Id> oppsForaDoPrazo = new Set<Id>();
        Set<Id> oppsEmConferencia = new Set<Id>();

        for(Opportunity opp : opps){
            if(opp.StageName == 'Conferência'){
                oppsEmConferencia.add(opp.Id);
            }
        }

        List<Contract> ctts = ContractSelector.getContractsByOpp(oppsEmConferencia);

        for(Contract ctt : ctts){
            if(ctt.Status == 'Em Assinatura' && ctt.PrazoAssinatura__c < Date.today()){
                oppsForaDoPrazo.add(ctt.Oportunidade__c);
            }
        }

        if(!oppsForaDoPrazo.isEmpty()){
            for(Opportunity opp : opps){
                if(oppsForaDoPrazo.contains(opp.Id)){
                    opp.addError('Não é possível avançar para a fase de Conferência, pois a assinatura do contrato está atrasada.');
                }
            }
        }
    }
    

}