public class RoletaLeadsHelper {
    public static void scheduleRoletaCleanUp(List<RoletaLeads__c> roletaList) {
        for (RoletaLeads__c roleta : roletaList) {
            if (roleta.HoraFim__c != null) {
                Time horaFim = roleta.HoraFim__c;

                Date hoje = Date.today();
                
                Datetime horaFimDatetime = Datetime.newInstance(
                    hoje.year(), hoje.month(), hoje.day(),
                    horaFim.hour(), horaFim.minute(), horaFim.second()
                );

                if (horaFimDatetime <= Datetime.now()) {
                    RoletaLeadsDA.limparParticipantesRoleta(roleta.Id);
                } else {
                    String sch = horaFim.second() + ' ' + horaFim.minute() + ' ' + horaFim.hour() + ' * * ?';
                    System.debug('Agendando job com expressão cron: ' + sch);
        
                    System.schedule('Limpar Participantes da Roleta ' + roleta.Name + ' ' + DateTime.now().getTime(), sch, new RoletaScheduler(roleta.Id));
                }
            }
        }
    }
}