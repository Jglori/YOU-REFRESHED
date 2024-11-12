public inherited sharing class LeadSLAHelper {

    public static void verifyLeadControlSLA(List<Lead> leadList, Map<Id, Lead> oldLeads) {
        Map<String, ConfiguracoesDeNegocio__c> mapConfiguracaoSLA = getMapConfiguracaoSLA(leadList);
        List<Lead> leadToschedule = new List<Lead>();

        for (Lead lead : leadList) {
            if (oldLeads == null || lead.Status != oldLeads.get(lead.Id).Status) {
                lead.ConfiguracaoDeSLA__c = null;
                lead.DataHoraVencimento__c = null;

                if (mapConfiguracaoSLA.containsKey(lead.Status)) {
                    ConfiguracoesDeNegocio__c configuracao = mapConfiguracaoSLA.get(lead.Status);
                    lead.DataHoraVencimento__c = Datetime.now().addMinutes(Integer.valueOf(configuracao.TempoDeSLA__c));
                    lead.ConfiguracaoDeSLA__c = configuracao.Id;
                    lead.DataEntradaFase__c = Datetime.now();
                    leadToschedule.add(lead);
                } 
            }
        }
    }

    public static void validateEventDate(List<Event> events) {
        Set<Id> whoIds = new Set<Id>();
        for (Event iEvent : events) {
            if (iEvent.WhoId != null) {
                whoIds.add(iEvent.WhoId);
            }
        }

        // Evitar consultas duplicadas
        Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id, ConfiguracaoDeSLA__r.TempoDeSLA__c FROM Lead WHERE Id IN :whoIds]);

        for (Event iEvent : events) {
            if (iEvent.EndDateTime > Datetime.now()) {
                Lead leadRecord = leadMap.get(iEvent.WhoId);
                if (leadRecord != null && leadRecord.ConfiguracaoDeSLA__r != null && leadRecord.ConfiguracaoDeSLA__r.TempoDeSLA__c != null) {
                    leadRecord.DataHoraVencimento__c = DateTime.newInstance(iEvent.EndDateTime.year(), iEvent.EndDateTime.month(), iEvent.EndDateTime.day()).addMinutes(Integer.valueOf(leadRecord.ConfiguracaoDeSLA__r.TempoDeSLA__c));
                }
            }
        }
    }

    public static void validateTaskDate(List<Task> tasks) {
        System.debug('Tasks que chegaram no leadSLAHelper: ' + tasks);
        Set<Id> whoIds = new Set<Id>();
        
        for (Task iTask : tasks) {
            if (iTask.WhoId != null) {
                whoIds.add(iTask.WhoId);
            }
        }
        
        // Consolidar a consulta para obter os Leads
        Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id, ConfiguracaoDeSLA__r.TempoDeSLA__c, DataHoraVencimento__c FROM Lead WHERE Id IN :whoIds]);
        System.debug('Mapa de leads: ' + leadMap);

        for (Task iTask : tasks) {
            System.debug('Task que chegou no leadSLAHelper: ' + iTask);
            if (iTask.ActivityDate > Date.today()) {
                Lead leadRecord = leadMap.get(iTask.WhoId);
                if (leadRecord != null && leadRecord.ConfiguracaoDeSLA__r != null && leadRecord.ConfiguracaoDeSLA__r.TempoDeSLA__c != null) {
                    leadRecord.DataHoraVencimento__c = DateTime.newInstance(iTask.ActivityDate.year(), iTask.ActivityDate.month(), iTask.ActivityDate.day()).addMinutes(Integer.valueOf(leadRecord.ConfiguracaoDeSLA__r.TempoDeSLA__c));
                    System.debug('DataHoraVencimento do lead: ' + leadRecord.DataHoraVencimento__c);
                }
            }
        }
    }

    private static Map<String, ConfiguracoesDeNegocio__c> getMapConfiguracaoSLA(List<Lead> pLstLead) {
        Set<String> setStatus = new Set<String>();
        for (Lead lead : pLstLead) {
            setStatus.add(lead.Status);
        }
        return getMapConfiguracaoSLA(setStatus);
    }

    private static Map<String, ConfiguracoesDeNegocio__c> getMapConfiguracaoSLA(Set<String> pSetStatus) {
        Map<String, ConfiguracoesDeNegocio__c> result = new Map<String, ConfiguracoesDeNegocio__c>();
        List<ConfiguracoesDeNegocio__c> lstResult = [
            SELECT Id, Fase__c, TempoDeSLA__c
            FROM ConfiguracoesDeNegocio__c
            WHERE Fase__c IN :pSetStatus AND RecordType.DeveloperName = 'ControleSLA'
        ];
        for (ConfiguracoesDeNegocio__c iResult : lstResult) {
            result.put(iResult.Fase__c, iResult);
        }
        return result;
    }
}