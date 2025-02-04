public class BolsaoLeadService {

    // Método que será chamado pela Trigger Handler para distribuir leads após atualização ou inserção
    public static void distribuirLeads(List<ParticipanteRoleta__c> participantes) {
     
        System.debug('Distribuindo leads para os participantes da Roleta.');
        System.debug('Participantes: ' + participantes);
    }
}