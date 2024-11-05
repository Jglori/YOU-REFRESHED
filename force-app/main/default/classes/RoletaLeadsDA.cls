public class RoletaLeadsDA {
    public static void limparParticipantesRoleta(Id roletaId) {
        try {
            List<ParticipanteRoleta__c> participantes = [SELECT Id FROM ParticipanteRoleta__c WHERE RoletaLeads__c = :roletaId];
            if (!participantes.isEmpty()) {
                delete participantes;
            }
        } catch (Exception e) {
            System.debug('Erro ao limpar participantes da roleta: ' + e.getMessage());
        }
    }
}