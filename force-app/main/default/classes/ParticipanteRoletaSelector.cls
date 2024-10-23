public without sharing class ParticipanteRoletaSelector {
    public static List<ParticipanteRoleta__c> obterParticipantesPorIdsMembros(Set<Id> idsMembros) {
        return [
            SELECT 
                MembroEquipe__c, 
                MembroEquipe__r.Usuario__r.Situacao__c,
                RegistroIndisponibilidade__c,
                RoletaLeads__c 
            FROM ParticipanteRoleta__c 
            WHERE 
                RoletaLeads__r.Ativa__c = true AND 
                RoletaLeads__r.DentroHorarioFuncionamento__c = true AND 
                MembroEquipe__c IN :idsMembros
        ];
    }

    public static List<ParticipanteRoleta__c> obterParticipantesPorIdsRoleta(Set<Id> idsRoletas) {
        return [SELECT  RoletaLeads__c, Posicao__c, MembroEquipe__c FROM ParticipanteRoleta__c WHERE RoletaLeads__c IN :idsRoletas];
    }

    public static List<ParticipanteRoleta__c> obterParticipantesPorIds(Set<Id> idsParticipantes) {
        return [
            SELECT 
                MembroEquipe__c, 
                MembroEquipe__r.ExigeValidacaoCoordenador__c, 
                MembroEquipe__r.Usuario__r.CanaisAtendimento__c, 
                Situacao__c, 
                MembroEquipe__r.Usuario__c,
                MembroEquipe__r.Usuario__r.ContactId,
                CargaRestante__c, 
                PausarDistribuicao__c, 
                PresencaValidada__c, 
                RoletaLeads__c 
            FROM ParticipanteRoleta__c 
            WHERE Id IN :idsParticipantes
        ];
    }

    public static List<ParticipanteRoleta__c> obterParticipantesPorUserID(Id userId) {
        return [SELECT  RoletaLeads__c, Posicao__c, MembroEquipe__c,MembroEquipe__r.Usuario__c FROM ParticipanteRoleta__c WHERE MembroEquipe__r.Usuario__c =: userId];
    }
}