public class EventHelper {
    public static void validateLeadStatus(List<Event> eventList) {
        Map<Id, Lead> leadsMappedByEventId = getScheduledLeadsMap(eventList);

        for(Event event: eventList){
            if(event.Subject == 'Visita'){
                Lead ld = leadsMappedByEventId.get(event.Id);
                
                if(ld != null){
                    if(ld.Status == 'Agendamento de Visita'){
                        event.EmpreendimentoInteresse__c = ld.EmpreendimentoInteresse__c;
                    }else{
                        event.addError('O status do lead precisa ser Agendamento de Visita');
                    }
                }
            }                
        }
       
    }
    
    public static void validate(List<Event> listaEvento){
        
        Set<Id> whoIds = new Set<Id>();
        for (Event e : listaEvento) {
            whoIds.add(e.WhoId);
        }

        Map<Id, Lead> leads = new Map<Id, Lead>([SELECT Id, EmpreendimentoInteresse__r.Name FROM Lead WHERE Id IN :whoIds]);
    
        for (Event eventos : listaEvento) {
            system.debug('entrei no for');
            if (eventos.WhoId != null && leads.containsKey(eventos.WhoId)) {
                system.debug('entrei no if');
                eventos.Location = leads.get(eventos.WhoId).EmpreendimentoInteresse__r.Name;
                system.debug('atualizei o evento');
            } else if (eventos.Location == null || String.isBlank(eventos.Location)) {
                eventos.Location = null;
            }
        }
    }

    public static void validateEventStatus(List<Event> events) {
        Set<Id> idLeads = new Set<Id>();
    
        List<Event> eventosVisita = new List<Event>();
    
        for (Event iEvent : events) {       
            if (iEvent.Subject == 'Visita') {
                idLeads.add(iEvent.WhoId);
                eventosVisita.add(iEvent);
            }
        }
        
        Map<Id, Lead> mapLeads = getScheduledLeadsMap(eventosVisita);


        if (!idLeads.isEmpty()) {
            List<Lead> leads = new List<Lead>();

            for (Event event : eventosVisita) {
                Lead lead = mapLeads.get(event.Id);
                if (lead != null) {
                    if(!String.isBlank(event.Motivo_da_visita_n_o_realizada__c) && (event.Status_do_Compromisso__c == 'Realizada com Sucesso' || event.Status_do_Compromisso__c == 'Agendado')){
                        event.addError('Não é necessário informar o Motivo da visita não realizada quando o Status do Compromisso é Realizada com Sucesso ou Agendado');
                    }

                    if (event.Status_do_Compromisso__c == 'Realizada com Sucesso') {
                        lead.Status = 'Qualificação';
                        leads.add(lead);
                    }

                    if (event.Status_do_Compromisso__c == 'Não realizada') { 
                        if (String.isBlank(event.Motivo_da_visita_n_o_realizada__c)) {
                            event.addError('Informar o motivo da visita não realizada. Escolha uma opção na lista, por favor.');
                        } else {
                            lead.Status = 'Contato Realizado';
                            leads.add(lead);
                        }
                    }
                }
            }
            if(!leads.isEmpty()){
                update leads;
            }
        }
    }
    
    public static void validateEventDate(List<Event> events){
        LeadSLAHelper.validateEventDate(events);
    }


    private static Map<Id, Lead> getScheduledLeadsMap(List<Event> events){
        List<Lead> scheduledLeads = LeadDA.getLeadScheduledById(
            new Set<String>{'Id', 'Status', 'EmpreendimentoInteresse__c' },
            ObjectHelper.getLookUpId(events, 'WhoId')
        );

        Map<Id, Lead> scheduledLeadsMap = new Map<Id, Lead>(scheduledLeads);
        Map<Id, Lead> leadsMappedByEventId = new Map<Id, Lead>();
        
        for(Event iEvent : events){
            if(iEvent.WhoId != null && scheduledLeadsMap.containsKey(iEvent.WhoId)) {
                leadsMappedByEventId.put(iEvent.Id, scheduledLeadsMap.get(iEvent.WhoId));
            }
        }
        
        return leadsMappedByEventId;
    }

}