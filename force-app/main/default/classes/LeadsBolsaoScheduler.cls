public class LeadsBolsaoScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        List<RoletaLeads__c> listaRoletas = [SELECT Id, HoraInicio__c FROM RoletaLeads__c WHERE Ativa__c = true];
        
        Time horaInicio = System.now().time(); 
        RoletaLeadsHelper.LeadsBolsaoHorarioAgendado(listaRoletas, horaInicio);
    }

    public static void scheduleDailyJobs() {
        String[] jobNames = new String[]{
            'DailyLeadsBolsaoJob_0000', 'DailyLeadsBolsaoJob_0100', 'DailyLeadsBolsaoJob_0200', 'DailyLeadsBolsaoJob_0300',
            'DailyLeadsBolsaoJob_0400', 'DailyLeadsBolsaoJob_0500', 'DailyLeadsBolsaoJob_0600', 'DailyLeadsBolsaoJob_0700',
            'DailyLeadsBolsaoJob_0800', 'DailyLeadsBolsaoJob_0900', 'DailyLeadsBolsaoJob_1000', 'DailyLeadsBolsaoJob_1100',
            'DailyLeadsBolsaoJob_1200', 'DailyLeadsBolsaoJob_1300', 'DailyLeadsBolsaoJob_1400', 'DailyLeadsBolsaoJob_1500',
            'DailyLeadsBolsaoJob_1600', 'DailyLeadsBolsaoJob_1700', 'DailyLeadsBolsaoJob_1800', 'DailyLeadsBolsaoJob_1900',
            'DailyLeadsBolsaoJob_2000', 'DailyLeadsBolsaoJob_2100', 'DailyLeadsBolsaoJob_2200', 'DailyLeadsBolsaoJob_2300'
        };
    
        String[] cronExpressions = new String[]{
            '0 0 0 * * ?', '0 0 1 * * ?', '0 0 2 * * ?', '0 0 3 * * ?',
            '0 0 4 * * ?', '0 0 5 * * ?', '0 0 6 * * ?', '0 0 7 * * ?',
            '0 0 8 * * ?', '0 0 9 * * ?', '0 0 10 * * ?', '0 0 11 * * ?',
            '0 0 12 * * ?', '0 0 13 * * ?', '0 0 14 * * ?', '0 0 15 * * ?',
            '0 0 16 * * ?', '0 0 17 * * ?', '0 0 18 * * ?', '0 0 19 * * ?',
            '0 0 20 * * ?', '0 0 21 * * ?', '0 0 22 * * ?', '0 0 23 * * ?'
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