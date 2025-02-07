@IsTest
public class LeadTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        Empreendimento__c  empreendimento = TestDataFactory.gerarEmpreendimento();
        insert empreendimento;

        Lead testLead = TestDataFactory.gerarLead(empreendimento);
        insert testLead;
        
        Task task = TestDataFactory.gerarTask(testLead);
        task.Status = 'Completed';
        insert task;

        Task taskOpen = TestDataFactory.gerarTask(testLead);
        taskOpen.Status = 'Open';
        insert taskOpen;

        Task taskWhatsapp = TestDataFactory.gerarTask(testLead);
        taskWhatsapp.Subject = 'WhatsApp';
        taskWhatsapp.Status = 'Open';
        insert taskWhatsapp;

        Task taskEmail = TestDataFactory.gerarTask(testLead);
        taskEmail.Subject = 'Email';
        taskEmail.Status = 'Open';
        insert taskEmail;

        Lead leadSemTask = new Lead(
            LastName = 'Eduardo Verri',
            Company = 'São Paulo Tech School',
            Email = 'eduardoverry@gmail.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11987563201',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );

        insert leadSemTask;

        Task taskAbertaLeadSemTask = new Task(
            Subject = 'Chamada',
            Status = 'Open',
            WhoId = leadSemTask.Id
        );
    
        insert taskAbertaLeadSemTask;

    }

    @IsTest
    static void testBeforeUpdate_AdvancingFromAttemptToContact() {
        Lead testLead = [SELECT Id, Status FROM Lead WHERE Status = 'Novo' LIMIT 1];
        testLead.Status = 'Tentativa de Contato';
        update testLead;
        testLead.Status = 'Agendamento de Visita';
        Test.startTest();
        update testLead;
        Test.stopTest();

        System.assertEquals('Agendamento de Visita', testLead.Status);
    }

    @IsTest
    static void testBeforeUpdate_AdvancingFromContactMade() {
        Lead testLead = [SELECT Id, Status FROM Lead WHERE Status = 'Novo' LIMIT 1];
        testLead.Status = 'Tentativa de Contato';
        update testLead;
        testLead.Status = 'Agendamento de Visita';
        Test.startTest();
        update testLead;
        Test.stopTest();
    }

    @IsTest
    static void testBeforeUpdate_NotAdvancing() {
        Lead testLead = [SELECT Id, Status FROM Lead WHERE Status = 'Novo' LIMIT 1];
        testLead.Status = 'Novo';
        update testLead;
        testLead.Status = 'Agendamento de Visita';
        Test.startTest();
        update testLead;
        Test.stopTest();
        
    }

    

    @IsTest
    static void isTaskCreatedAndOpenForAttemptToContactTest(){
        Lead testLead = new Lead(
            LastName = 'Pedro Francisco',
            Company = 'Bradesco Sa',
            Email = 'pedrofrancisco@gmail.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11847543201',
            Status = 'Tentativa de Contato'
        );

        insert testLead;

        Task task = new Task(
            Subject = 'Chamada',
            Status = 'Open',
            WhoId = testLead.Id
        );
        insert task;
        testLead.Status = 'Contato Realizado';
        update testLead;
        List<Task> tasks = [SELECT Id, WhoId, Subject, Status FROM Task WHERE WhoId = :testLead.Id AND Status = 'Open' LIMIT 1];
        System.assert(!tasks.isEmpty(), 'Deveria haver pelo menos uma tarefa com status Open associada ao Lead');
    }
    
      @isTest
    public static void beforeUpdateTest() {
        Lead lead = [SELECT Id, Status FROM Lead LIMIT 1];

        Task task = new Task(
            Subject = 'Email',
            WhoId = lead.Id
        );
        insert task;
        
        Test.startTest();
        lead.Status = 'Prospecção';
        update lead;
        Test.stopTest();
        
        lead = [SELECT Id, Status FROM Lead WHERE Id = :lead.Id];
        System.assertEquals(false, lead.hasErrors(), 'O lead não deveria ter erros após a atualização');
    }
    
}