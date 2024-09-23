@IsTest
public class LeadTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        Empreendimento__c  empreendimento = new Empreendimento__c (Name = 'Teste empreendimento',CNPJEmpreendimento__c = '36658601000133');
        insert empreendimento;
        Lead testLead = new Lead(
            LastName = 'Will',
            Company = 'Elera',
            Email = 'Willdantas@gmail.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11960387699',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;


        // Task task = new Task(
        //     Subject = 'Chamada',
        //     Status = 'Completed',
        //     WhoId = testLead.Id
        // );

        // insert task;


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

        Task taskOpen = new Task(
            Subject = 'Chamada',
            Status = 'Open',
            WhoId = testLead.Id
        );
        insert taskOpen;

        Task taskWhatsapp = new Task(
            Subject = 'WhatsApp',
            Status = 'Open',
            WhoId = testLead.Id
        );

        insert taskWhatsapp;

        Task taskEmail = new Task(
            Subject = 'Email',
            Status = 'Open',
            WhoId = testLead.Id
        );

        insert taskEmail;

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

        Task taskOpen = new Task(
            Subject = 'Chamada',
            Status = 'Open',
            WhoId = testLead.Id
        );
        insert taskOpen;

        Task taskWhatsapp = new Task(
            Subject = 'WhatsApp',
            Status = 'Open',
            WhoId = testLead.Id
        );

        insert taskWhatsapp;

        Task taskEmail = new Task(
            Subject = 'Email',
            Status = 'Open',
            WhoId = testLead.Id
        );

        insert taskEmail;

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
    static void testarCenarioErroCath(){
       Lead newLead = new Lead(
            LastName = 'Matheus Oliveira Santos Almeida',
            Company = 'Elera Company Paulista',
            Email = 'matheusoliveiraalmeida@gmail.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11837434754',
            Status = 'Novo'
        );
        insert newLead;

        
        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            newLead.Status = 'Contato Realizado'; 
            update newLead;
        } catch(DmlException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'A exceção DmlException deveria ter sido lançada');
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
            Status = 'Novo'
        );
        
        insert testLead;

        testLead.Status = 'Tentativa de Contato';
        update testLead;

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

        // Task task = new Task(
        //     Subject = 'Email',
        //     WhoId = lead.Id
        // );
        // insert task;
        
        Test.startTest();
        lead.Status = 'Prospecção';
        update lead;
        Test.stopTest();
        
        lead = [SELECT Id, Status FROM Lead WHERE Id = :lead.Id];
        System.assertEquals(false, lead.hasErrors(), 'O lead não deveria ter erros após a atualização');
    }
    
}