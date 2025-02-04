public class AbortLeadsBolsaoJobs implements Schedulable {
    public void execute(SchedulableContext sc) {
        List<CronTrigger> jobsParaAbortar = [
            SELECT Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name LIKE 'Bolsao de Leads da Roleta%'
        ];

        for (CronTrigger job : jobsParaAbortar) {
            try {
                System.abortJob(job.Id);
                System.debug('Job aborted: ' + job.CronJobDetail.Name);
            } catch (Exception e) {
                System.debug('Erro ao abortar o job ' + job.CronJobDetail.Name + ': ' + e.getMessage());
            }
        }
    }
}