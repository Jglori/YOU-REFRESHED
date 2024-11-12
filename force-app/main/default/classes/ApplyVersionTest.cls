@isTest
private class ApplyVersionTest {
    @testSetup
    static void setupData() {
        // Ignorar o gatilho LeadTrigger
        TriggerHandler.bypass('LeadTriggerHandler');
        
        // Configurações de SLA
        ConfiguracoesDeNegocio__c config = new ConfiguracoesDeNegocio__c(
            FaseParaRedirecionamentoDoLead__c = 'Descartado',
            Fase__c = 'Novo',
            FilaParaRedirecionamentoDoLead__c = 'Fila Perda Lead' // Usando o nome da fila existente
        );
        insert config;

        // Recuperar a fila "Fila Perda Lead"
        Group filaPerdaLead = [SELECT Id FROM Group WHERE Name = 'Fila Perda Lead' LIMIT 1];
        
        // Recuperar a fila "Roteamento Lead"
        Group roteamentoLead = [SELECT Id FROM Group WHERE Name = 'Roteamento Lead' LIMIT 1];

        // Lead expirado (para ser atualizado)
        Lead lead1 = new Lead(
            LastName = 'Raposo',
            Company = 'Test Company',
            Status = 'Novo',
            ConfiguracaoDeSLA__c = config.Id,
            CanalAtendimento__c = 'Whatsapp',
            Email = 'lead1@example.com',
            DataHoraVencimento__c = DateTime.now().addMinutes(-10) // Lead expirado
        );
        insert lead1;

        // Limpar o bypass após a inserção
        TriggerHandler.clearBypass('LeadTriggerHandler');
    }

    @isTest
    static void testExecute() {
        // Definir a data limite para o job
        DateTime limitDate = DateTime.now();

        // Criar a instância do job ApplyVersion
        ApplyVersion applyVersion = new ApplyVersion(limitDate);

        // Iniciar teste
        Test.startTest();

        // Executar o job manualmente
        applyVersion.execute(null);

        // Parar o teste
        Test.stopTest();

        // Verificar se o lead expirado foi atualizado
        Lead updatedLead = [SELECT Id, Status, OwnerId FROM Lead WHERE Email = 'lead1@example.com'];
        Group queue = [SELECT Id FROM Group WHERE Name = 'Fila Perda Lead' LIMIT 1];

        // Verificar se o proprietário do Lead foi alterado para a fila "Fila Perda Lead"
        System.assertEquals(queue.Id, updatedLead.OwnerId, 'O lead deveria ser redirecionado para a fila "Fila Perda Lead".');

        // Verificar se um novo job foi agendado
        List<CronTrigger> scheduledJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'ApplyVersionJob'];
       
    }
}