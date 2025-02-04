public class LeadsBolsaoCleanupJob implements Schedulable {
    public void execute(SchedulableContext sc) {
        // Query for completed jobs (CronTrigger records)
        List<CronTrigger> completedJobs = [
            SELECT Id, State 
            FROM CronTrigger 
            WHERE State = 'DELETED'
        ];

        for (CronTrigger job : completedJobs) {
            System.abortJob(job.Id);
        }
    }
}