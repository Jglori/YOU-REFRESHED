public without sharing class MembroEquipeSelector {
    public static List<MembroEquipe__c> obterMembrosPorIdsUsuarios(Set<Id> idsUsuarios) {
        return [SELECT Usuario__r.Name, Equipe__c, Usuario__c, Usuario__r.Situacao__c FROM MembroEquipe__c WHERE Usuario__c IN :idsUsuarios];
    }
    public static List<MembroEquipe__c> obterMembrosPorId(Set<Id> idsMembros) {
        return [SELECT Usuario__r.Name, Equipe__c, Usuario__c, Usuario__r.Situacao__c,Usuario__r.ContactId FROM MembroEquipe__c WHERE ID IN :idsMembros];
    }
}