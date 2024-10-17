public class ParticipanteRoletaDomain {
    public static Map<Id, List<ParticipanteRoleta__c>> obterParticipantesPorIdMembro(List<ParticipanteRoleta__c> participantes) {
        Map<Id, List<ParticipanteRoleta__c>> participantesPorIdMembro = new Map<Id, List<ParticipanteRoleta__c>>();
        for(ParticipanteRoleta__c participante : participantes) {
            if(!participantesPorIdMembro.containsKey(participante.MembroEquipe__c)) {
                participantesPorIdMembro.put(participante.MembroEquipe__c, new List<ParticipanteRoleta__c>());
            }

            participantesPorIdMembro.get(participante.MembroEquipe__c).add(participante);
        }

        return participantesPorIdMembro;
    }

    public static Map<Id, List<ParticipanteRoleta__c>> obterParticipantesPorIdRoleta(List<ParticipanteRoleta__c> participantes) {
        Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoleta = new Map<Id, List<ParticipanteRoleta__c>>();
        for(ParticipanteRoleta__c participante : participantes) {            
            if(!participantesPorIdRoleta.containsKey(participante.RoletaLeads__c)) {
                participantesPorIdRoleta.put(participante.RoletaLeads__c, new List<ParticipanteRoleta__c>());
            }

            participantesPorIdRoleta.get(participante.RoletaLeads__c).add(participante);
        }

        return participantesPorIdRoleta;
    }

    public static List<ParticipanteRoleta__c> obterParticipantesPorSorteios(List<Sorteio__c> sorteios) {
        Set<Id> idsRoletas = SorteioDomain.obterIdsRoletas(sorteios);

        return ParticipanteRoletaSelector.obterParticipantesPorIdsRoleta(idsRoletas);
    }
}