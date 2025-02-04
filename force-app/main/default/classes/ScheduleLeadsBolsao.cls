public class ScheduleLeadsBolsao implements Schedulable {
    public void execute(SchedulableContext sc) {
        List<RoletaLeads__c> listaRoletas = [SELECT Id, HoraInicio__c FROM RoletaLeads__c WHERE Ativa__c = true];
        Time horaInicio = System.now().time(); 
        RoletaLeadsHelper.LeadsBolsaoHorarioAgendado(listaRoletas, horaInicio);
    }

    public static void scheduleDailyJobs() {
        String[] jobNames = new String[]{
            'DailyLeadsBolsaoJob_0930', 'DailyLeadsBolsaoJob_1000', 'DailyLeadsBolsaoJob_1030', 
            'DailyLeadsBolsaoJob_1100', 'DailyLeadsBolsaoJob_1130', 'DailyLeadsBolsaoJob_1200',
            'DailyLeadsBolsaoJob_1230', 'DailyLeadsBolsaoJob_1300', 'DailyLeadsBolsaoJob_1330',
            'DailyLeadsBolsaoJob_1400', 'DailyLeadsBolsaoJob_1430', 'DailyLeadsBolsaoJob_1500',
            'DailyLeadsBolsaoJob_1530', 'DailyLeadsBolsaoJob_1600', 'DailyLeadsBolsaoJob_1630',
            'DailyLeadsBolsaoJob_1700', 'DailyLeadsBolsaoJob_1730', 'DailyLeadsBolsaoJob_1800',
            'DailyLeadsBolsaoJob_1830', 'DailyLeadsBolsaoJob_1900', 'DailyLeadsBolsaoJob_1930',
            'DailyLeadsBolsaoJob_2000', 'DailyLeadsBolsaoJob_2030', 'DailyLeadsBolsaoJob_2100',
            'DailyLeadsBolsaoJob_2130', 'DailyLeadsBolsaoJob_2200', 'DailyLeadsBolsaoJob_2230',
            'DailyLeadsBolsaoJob_2300', 'DailyLeadsBolsaoJob_2330'
        };

        String[] cronExpressions = new String[]{
            '0 30 9 * * ?', '0 0 10 * * ?', '0 30 10 * * ?', 
            '0 0 11 * * ?', '0 30 11 * * ?', '0 0 12 * * ?',
            '0 30 12 * * ?', '0 0 13 * * ?', '0 30 13 * * ?',
            '0 0 14 * * ?', '0 30 14 * * ?', '0 0 15 * * ?',
            '0 30 15 * * ?', '0 0 16 * * ?', '0 30 16 * * ?',
            '0 0 17 * * ?', '0 30 17 * * ?', '0 0 18 * * ?',
            '0 30 18 * * ?', '0 0 19 * * ?', '0 30 19 * * ?',
            '0 0 20 * * ?', '0 30 20 * * ?', '0 0 21 * * ?',
            '0 30 21 * * ?', '0 0 22 * * ?', '0 30 22 * * ?',
            '0 0 23 * * ?', '0 30 23 * * ?'
        };

        for (Integer i = 0; i < jobNames.size(); i++) {
            List<CronTrigger> existingJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobNames[i]];

            if (existingJobs.isEmpty()) {
                try {
                    System.schedule(jobNames[i], cronExpressions[i], new ScheduleLeadsBolsao());
                } catch (Exception e) {
                    System.debug('Erro ao agendar o job: ' + jobNames[i] + ' - ' + e.getMessage());
                }
            }
        }
    }
}