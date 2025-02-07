@isTest
private class CronExpressionDomainTest {
    @isTest
    static void testAgendarProximaExecucao() {
        Test.startTest();
        
        Datetime futureTime = Datetime.now().addMinutes(5); // Schedule 5 minutes in the future
        SortearParticipantesSchedulable schedulable = new SortearParticipantesSchedulable();
        
        String jobId = CronExpressionDomain.agendarProximaExecucao(futureTime, schedulable);
        
        // Verify that a job was scheduled
        List<CronTrigger> jobs = [SELECT Id, CronExpression FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(1, jobs.size(), 'A job should have been scheduled');
        
        // Optionally, verify the cron expression
        String expectedCronExp = futureTime.format('s m H d M ? yyyy');
        System.assertEquals(expectedCronExp, jobs[0].CronExpression, 'The cron expression should match');
        
        Test.stopTest();
    }
}