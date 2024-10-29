@isTest
private class RoletaSchedulerTest {
    @isTest
    static void testRoletaSchedulerExecution() {
        // Criar um ID fictício de Roleta e hora de fim para o teste
        Id roletaId = 'a0X5g000004G9YjEAK'; // Substituir com um ID válido no teste real
        Datetime horaFim = Datetime.now().addHours(1); // Exemplo de hora de fim

        // Iniciar o teste
        Test.startTest();

        // Instanciar a classe RoletaScheduler e agendar o job
        RoletaScheduler scheduler = new RoletaScheduler(roletaId, horaFim);
        String cronExp = '0 0 0 1 1 ? 2025'; // Cron para agendar o job em uma data futura
        System.schedule('Test Roleta Job', cronExp, scheduler);

        // Finalizar o teste
        Test.stopTest();

        // Verificar se o job foi agendado corretamente
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE CronJobDetail.Name = 'Test Roleta Job'];
        System.assertNotEquals(null, ct, 'O job RoletaScheduler deveria estar agendado.');
        System.assertEquals(0, ct.TimesTriggered, 'O job RoletaScheduler não deveria ter sido executado ainda.');
    }

    @isTest
    static void testRoletaSchedulerNextExecution() {
        // Criar um ID fictício de Roleta e hora de fim para o teste
        Id roletaId = 'a0X5g000004G9YjEAK'; // Substituir com um ID válido no teste real
        Datetime horaFim = Datetime.now().addHours(1); // Exemplo de hora de fim

        // Iniciar o teste
        Test.startTest();

        // Instanciar a classe RoletaScheduler e simular a execução do job
        RoletaScheduler scheduler = new RoletaScheduler(roletaId, horaFim);
        scheduler.execute(null);

        // Finalizar o teste
        Test.stopTest();

        // Verificar se o próximo job foi agendado para o dia seguinte
        Datetime nextExecutionTime = horaFim.addDays(1);
        CronTrigger nextJob = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Limpar Participantes da Roleta%' LIMIT 1];
        System.assertNotEquals(null, nextJob, 'O próximo job RoletaScheduler deveria ter sido agendado.');
    }
}