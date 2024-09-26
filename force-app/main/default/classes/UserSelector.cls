public without sharing class UserSelector {
    public static List<User> obterUsuariosPorIds(Set<Id> idsUsuarios) {
        return [SELECT Situacao__c, CanaisAtendimento__c FROM User WHERE Id IN :idsUsuarios];
    }

    public static List<User> obterUsuarios(){
        return[
            SELECT 
                Id, Email, Reportase__r.Id, Reportase__r.Email
            FROM 
                User
        ];
    }
    
}