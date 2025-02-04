public class MasterDailyLeadsBolsaoJob implements Schedulable {
    public void execute(SchedulableContext context) {
        List<RoletaLeads__c> listaRoletas = [SELECT Id, HoraInicio__c FROM RoletaLeads__c];

        for (RoletaLeads__c roleta : listaRoletas) {
            Time horaInicio = roleta.HoraInicio__c;
            Datetime startDateTime = Datetime.newInstance(System.today(), horaInicio);

            // Ajusta jobStartTime para 5 minutos após o startDateTime
            Datetime jobStartTime = startDateTime.addMinutes(5);

            String jobName = 'BolsaoDeLeadsRoleta_' + roleta.Id + '_Job';

            // Cancela qualquer job antigo com o mesmo nome base
            List<CronTrigger> oldJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE :jobName + '%'];
            for (CronTrigger oldJob : oldJobs) {
                System.abortJob(oldJob.Id);
            }

            // Define o cron expression para o novo job
            String sch = '0 ' + jobStartTime.minute() + ' ' + jobStartTime.hour() + ' ' + jobStartTime.day() + ' ' + jobStartTime.month() + ' ? ' + jobStartTime.year();

            try {
                System.schedule(jobName, sch, new AtualizarLeadBolsaoJob(roleta.Id));
            } catch (Exception e) {
                System.debug('Erro ao agendar o job: ' + e.getMessage());
            }
        }
    }
}