@isTest
private class JobCleanerTest {

    @isTest
    static void testDeleteAllScheduledJobs() {
        // Agendar alguns jobs de exemplo para teste
        Test.startTest();
        
        String job1 = System.schedule('Test Job 1', '0 0 0 1 1 ?', new DummySchedulable());
        String job2 = System.schedule('Test Job 2', '0 0 0 1 1 ?', new DummySchedulable());
        
        Test.stopTest();
    }
    
    // Classe DummySchedulable para agendar jobs fictícios para teste
    public class DummySchedulable implements Schedulable {
        public void execute(SchedulableContext sc) {
            // Implementação vazia para o teste
        }
    }
}