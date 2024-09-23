public with sharing class EventDA {
    public static List<Event> getAllEventByLead(Set<Id> leadIds) {
        return [SELECT Id, Type, Subject, WhoId, Status_do_Compromisso__c  FROM Event WHERE WhoId IN :leadIds AND Subject = 'Visita' AND Status_do_Compromisso__c = 'Realizada com Sucesso'];
    }
}