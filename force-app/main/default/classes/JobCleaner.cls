public class JobCleaner {
    public static void deleteAllScheduledJobs() {
        // Consulta todos os jobs agendados
        List<CronTrigger> jobs = [SELECT Id FROM CronTrigger];
        
        // Verifica se há jobs agendados
        if (!jobs.isEmpty()) {
            // Loop para deletar todos os jobs agendados
            for (CronTrigger job : jobs) {
                System.abortJob(job.Id);
            }
            System.debug(jobs.size() + ' jobs agendados foram deletados.');
        } else {
            System.debug('Nenhum job agendado encontrado.');
        }
    }
}