public class RoletaLeadsHelper {
    public static void scheduleRoletaCleanUp(List<RoletaLeads__c> roletaList) {
        Set<Id> roletasAgendadas = new Set<Id>();

        for (RoletaLeads__c roleta : roletaList) {
           
            if (roleta.Ativa__c && roleta.DentroHorarioFuncionamento__c) {
                Time horaFim = roleta.HoraFim__c;
                String uniqueJobName = 'Limpar Participantes da Roleta ' + roleta.Id;

              
                List<CronTrigger> jobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :uniqueJobName];
                
               
                if (jobs.isEmpty()) {
                    String sch = '0 ' + horaFim.minute() + ' ' + horaFim.hour() + ' * * ?'; 

                    try {
                        System.schedule(uniqueJobName, sch, new RoletaScheduler(roleta.Id));
                        roletasAgendadas.add(roleta.Id);
                    } catch (Exception e) {
                       
                        System.debug('Erro ao agendar o job: ' + e.getMessage());
                    }
                }
            }
        }
    }
}