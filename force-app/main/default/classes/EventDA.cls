public with sharing class EventDA {
    public static List<Event> getAllEventByLead(Id leadId) {
        return [SELECT Id, Type, Subject, idLead__c, WhoId, Status_do_Compromisso__c FROM Event WHERE idLead__c = :leadId AND Subject = 'Visita' AND Status_do_Compromisso__c = 'Realizada com Sucesso'];
    }
}