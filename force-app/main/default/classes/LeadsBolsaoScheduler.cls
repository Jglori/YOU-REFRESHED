public class LeadsBolsaoScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        List<RoletaLeads__c> listaRoletas = [SELECT Id, HoraInicio__c FROM RoletaLeads__c WHERE Ativa__c = true];
        
        Time horaInicio = System.now().time(); 
        RoletaLeadsHelper.LeadsBolsaoHorarioAgendado(listaRoletas, horaInicio);
    }

    public static void scheduleDailyJobs() {
        String[] jobNames = new String[]{
            'DailyLeadsBolsaoJob_0915','DailyLeadsBolsaoJob_1500',
            'DailyLeadsBolsaoJob_1800'
        };

        String[] cronExpressions = new String[]{
            '0 15 9 * * ?','0 0 15 * * ?',
            '0 0 18 * * ?'
        };

        for (Integer i = 0; i < jobNames.size(); i++) {
            List<CronTrigger> existingJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobNames[i]];

            if (existingJobs.isEmpty()) {
                try {
                    System.schedule(jobNames[i], cronExpressions[i], new LeadsBolsaoScheduler());
                } catch (Exception e) {
                    System.debug('Erro ao agendar o job: ' + jobNames[i] + ' - ' + e.getMessage());
                }
            }
        }

        String cleanUpJobName = 'DailyRoletaCleanUpJob';
        String cleanUpCronExpression = '0 55 23 * * ?';

        List<CronTrigger> existingCleanUpJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :cleanUpJobName];
        if (existingCleanUpJobs.isEmpty()) {
            try {
                System.schedule(cleanUpJobName, cleanUpCronExpression, new RoletaCleanUpScheduler());
            } catch (Exception e) {
                System.debug('Erro ao agendar o job de limpeza: ' + e.getMessage());
            }
        }
    }
}