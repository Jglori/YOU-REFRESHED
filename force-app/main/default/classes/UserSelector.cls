public without sharing class UserSelector {
    public static List<User> obterUsuariosPorIds(Set<Id> idsUsuarios) {
        return [SELECT Situacao__c,ContactId, CanaisAtendimento__c FROM User WHERE Id IN :idsUsuarios];
    }
    public static User obterUsuariosPorContactIds(Id contactId) {
        return [SELECT Id,Situacao__c, CanaisAtendimento__c FROM User WHERE ContactId =: contactId];
    }

    public static List<User> getUserPorIds(List<Id> userIds){
        return [Select Id, Reportase__c from User where id In: userIds];
    }
}