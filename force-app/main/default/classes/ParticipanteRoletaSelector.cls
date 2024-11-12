public without sharing class ParticipanteRoletaSelector {
    public static List<ParticipanteRoleta__c> obterParticipantesPorIdsMembros(Set<Id> idsMembros) {
        return [
            SELECT 
                MembroEquipe__c, 
                MembroEquipe__r.Usuario__r.Situacao__c,
                RegistroIndisponibilidade__c,
                RoletaLeads__c,
                Saida__c 
            FROM ParticipanteRoleta__c 
            WHERE 
                RoletaLeads__r.Ativa__c = true AND 
                RoletaLeads__r.DentroHorarioFuncionamento__c = true AND 
                MembroEquipe__c IN :idsMembros
        ];
    }
    public static List<ParticipanteRoleta__c> obterParticipantesPorIdsRoleta(Set<Id> idsRoletas) {
        if (idsRoletas == null || idsRoletas.isEmpty()) {
            return new List<ParticipanteRoleta__c>(); 
        }
    
        List<ParticipanteRoleta__c> participantes = [
            SELECT RoletaLeads__c, Posicao__c, MembroEquipe__c, Saida__c, RegistroIndisponibilidade__c 
            FROM ParticipanteRoleta__c 
            WHERE RoletaLeads__c IN :idsRoletas
        ];
    
        return participantes;
    }
    
    public static List<ParticipanteRoleta__c> obterParticipantesPorIds(Set<Id> idsParticipantes) {
        if (idsParticipantes == null || idsParticipantes.isEmpty()) {
            return new List<ParticipanteRoleta__c>(); // Retorna uma lista vazia se não houver IDs
        }
    
        List<ParticipanteRoleta__c> participantes = [
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
    
        return participantes;
    }
    

    public static List<ParticipanteRoleta__c> obterParticipantesPorUserID(Id userId) {
        return [SELECT  RoletaLeads__c, Posicao__c, MembroEquipe__c,MembroEquipe__r.Usuario__c FROM ParticipanteRoleta__c WHERE MembroEquipe__r.Usuario__c =: userId];
    }
}