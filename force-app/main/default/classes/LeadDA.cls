public with sharing class LeadDA {
    public static List<Lead> getLeadsAgendamentoById(Set<Id> whoIds) {
        System.debug(whoIds);
        return [SELECT Id, Status FROM Lead WHERE Id IN :whoIds AND  Status = 'Agendamento de Visita'];
    }

    
    public static List<Lead> getLeadsByIds(Set<Id> idsLeads) {
        return [SELECT Id, EmpreendimentoInteresse__c, Status FROM Lead WHERE Id IN :idsLeads];
    }

    public static List<Lead> getLeadScheduledById(Set<String> fields, Set<Id> leadsId){
        return Database.query(String.format(
            'SELECT {0} FROM Lead WHERE Id IN :leadsId',
            new String[]{String.join(new List<String>(fields), ',')}
        ));
    }
}