public without sharing class UserSelector {

    public static List<User> obterUsuariosPorIds(Set<Id> idsUsuarios) {
        return [SELECT Id, Situacao__c, ContactId, CanaisAtendimento__c FROM User WHERE Id IN :idsUsuarios];} public static User obterUsuariosPorContactIds(Id contactId) {return [SELECT Id, Situacao__c, CanaisAtendimento__c FROM User WHERE ContactId = :contactId LIMIT 1];
    }

    public static List<User> getUserPorIds(List<Id> userIds) {
        Set<Id> idsSet = new Set<Id>(userIds);
        return [SELECT Id, Reportase__c FROM User WHERE Id IN :idsSet];
    }
}