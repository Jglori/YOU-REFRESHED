@isTest
private class ApplyVersionTest {
    @isTest
    static void testScheduleNewJob() {
        TriggerHandler.bypass('LeadTriggerHandler');
        ConfiguracoesDeNegocio__c config = new ConfiguracoesDeNegocio__c();
        config.FaseParaRedirecionamentoDoLead__c = 'Descartado';
        config.Fase__c = 'Novo';
        config.FilaParaRedirecionamentoDoLead__c = 'Fila Perda Lead 2';
        insert config;

        Group gp =  new Group();
        gp.Name = 'Fila Perda Lead 2';
        insert gp;

        Lead lead = new Lead(
            LastName = 'Raposo',
            Company = 'porao',
            Status = 'Novo',
            ConfiguracaoDeSLA__c = config.Id,
            CanalAtendimento__c = 'Whatsapp',
            Email = 'e@gmail.com',
            DataHoraVencimento__c = DateTime.Now()
        );
        insert lead;

        DateTime limitDate = DateTime.now().addMinutes(30);
        ApplyVersion applyVersion = new ApplyVersion(limitDate);

        Test.startTest();
        String sch = '0 0 0 1 1 ? 2025'; // Schedule for a specific date
        System.schedule('Test ApplyVersion Job', sch, applyVersion);
        Test.stopTest();

        // Verify the job is scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE CronJobDetail.Name = 'Test ApplyVersion Job'];
        System.assertNotEquals(null, ct);
        System.assertEquals(0, ct.TimesTriggered);
    }
}