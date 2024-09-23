@isTest
public class TaskTriggerHandlerTest {

    @testSetup
    static void setup() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Group testGroup = new Group(Name = 'rock', Type = 'Queue');
            insert testGroup;
            insert new QueueSObject(QueueID = testGroup.id, SObjectType = 'Lead');
        }
        
        List<ConfiguracoesDeNegocio__c> configs = new List<ConfiguracoesDeNegocio__c>{
            new ConfiguracoesDeNegocio__c(
                TempoDeSla__c = 1440, 
                Fase__c = 'Novo',
                FaseParaRedirecionamentoDoLead__c = 'Novo',
                FilaParaRedirecionamentoDoLead__c = 'rock'
            )
        };
        insert configs;

        Lead lead = new Lead(
            LastName = 'Teste',
            Description = 'Teste',
            Email = 'Willdantasss@gmail.com',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11960387699',
            Status = 'Novo',
            ConfiguracaoDeSLA__c = configs.get(0).Id
        );
        insert lead;
        
        lead.Status = 'Tentativa de contato';
        update lead;

        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento',CNPJEmpreendimento__c = '67205943000121');
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
      
        testLead.Status = 'Tentativa de contato';
        update testLead;
        
        Task task = new Task(
            Subject = 'Chamada',
            Status = 'Completed',
            WhoId = testLead.Id
        );
        insert task;

        Task taskOpen = new Task(
            Subject = 'Chamada',
            Status = 'Open',
            WhoId = testLead.Id
        );
        insert taskOpen;

        Task taskEmail = new Task(
            Subject = 'Email',
            Status = 'Open',
            WhoId = testLead.Id
        );
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
        
        leadSemTask.Status = 'Tentativa de contato';
        update leadSemTask;

        Task taskAbertaLeadSemTask = new Task(
            Subject = 'Chamada',
            Status = 'Completed',
            WhoId = leadSemTask.Id
        );
        insert taskAbertaLeadSemTask;
    }

    @isTest
    static void testBeforeInsert() {
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento',CNPJEmpreendimento__c = '67205943000121');
        insert empreendimento;
        
        Lead lead = new Lead(
            LastName = 'Paulo',
            Company = 'Elera',
            Email = 'pauloelera123@gmail.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11960387699',
            Status = 'Novo', 
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert lead;

        lead.Status = 'Tentativa de contato';
        update lead;
        
        Task task = new Task(
            WhoId = lead.Id,
            Subject = 'Chamada',
            Status = 'Not Started',
            ActivityDate = Date.today().addDays(5)
        );

        Test.startTest();
        insert task;
        Test.stopTest();

        Task updatedTask = [SELECT Id, ActivityDate FROM Task WHERE Id = :task.Id];
        System.assertEquals(Date.today().addDays(5), updatedTask.ActivityDate);
    }

    @isTest
    static void testBeforeUpdate() {
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento',CNPJEmpreendimento__c = '67205943000121');
        insert empreendimento;
        
        Lead lead = new Lead(
            LastName = 'Paulo',
            Company = 'Elera',
            Email = 'pauloelera123@gmail.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11960387699',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert lead;
        
        lead.Status = 'Tentativa de contato';
        update lead;
        
        Task task = new Task(
            WhoId = lead.Id,
            Subject = 'Chamada',
            Status = 'Completed',
            ActivityDate = Date.today().addDays(5)
        );
        insert task;
        
    
        lead.Status = 'Tentativa de contato';
        update lead;

        task.Subject = 'Chamada';
        task.Status = 'Open'; // Allowed status change
        Test.startTest();
        update task;
        Test.stopTest();

        Task updatedTask = [SELECT Id, Status FROM Task WHERE Id = :task.Id];
        System.assertEquals('Open', updatedTask.Status);

       
        task.Subject = 'Email';
       
        try {
            update task;
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Só é permitido criar uma tarefa do tipo'),
                          'Erro de mensagem.');
        }
    

        updatedTask = [SELECT Id, Subject FROM Task WHERE Id = :task.Id];
       
    }

    @isTest
    static void testValidateTaskDate() {
        List<Lead> leadsForSLA = [SELECT Id, ConfiguracaoDeSLA__c FROM Lead WHERE ConfiguracaoDeSLA__c != null LIMIT 1];

        if (!leadsForSLA.isEmpty()) {
            Lead leadForSLA = leadsForSLA[0];
            ConfiguracoesDeNegocio__c config = [SELECT Id, TempoDeSla__c FROM ConfiguracoesDeNegocio__c WHERE Id = :leadForSLA.ConfiguracaoDeSLA__c];

            Task futureTask = new Task(
                WhoId = leadForSLA.Id,
                Subject = 'Chamada',
                Status = 'Completed',
                ActivityDate = Date.today().addDays(1)
            );

            Test.startTest();
            insert futureTask;
            Test.stopTest();

            Lead updatedLead = [SELECT Id, DataHoraVencimento__c FROM Lead WHERE Id = :leadForSLA.Id];

            DateTime expectedDateTime = DateTime.newInstance(futureTask.ActivityDate.year(), futureTask.ActivityDate.month(), futureTask.ActivityDate.day()).addMinutes(Integer.valueOf(config.TempoDeSla__c));

            System.assertEquals(expectedDateTime, updatedLead.DataHoraVencimento__c, 'DataHoraVencimento__c');
        }
    }

    @isTest
    static void testBeforeUpdateTask() {
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento',CNPJEmpreendimento__c = '67205943000121');
        insert empreendimento;
        
        Lead lead = new Lead(
            LastName = 'Paulo',
            Company = 'Elera',
            Email = 'pauloelera123@gmail.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11960387699',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert lead;

        lead.Status = 'Tentativa de contato';
        update lead;
        
        Task task = new Task(
            WhoId = lead.Id,
            Subject = 'Chamada',
            Status = 'Completed',
            ActivityDate = Date.today().addDays(5)
        );
        insert task;

        task.ActivityDate = Date.today().addDays(10);

        Test.startTest();
        update task;
        Test.stopTest();

        Task updatedTask = [SELECT Id, ActivityDate FROM Task WHERE Id = :task.Id];
        System.assertEquals(Date.today().addDays(10), updatedTask.ActivityDate);
    }
    
    

    @isTest
    static void testTaskCreationWithDisallowedStatus() {
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento',CNPJEmpreendimento__c = '67205943000121');
        insert empreendimento;
        
        Lead lead = new Lead(
            LastName = 'Carlos',
            Company = 'Elera',
            Email = 'carloselera@gmail.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11960387699',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert lead;
        
        Task task = new Task(
            WhoId = lead.Id,
            Subject = 'Chamada',
            Status = 'Open',
            ActivityDate = Date.today().addDays(5)
        );

        Test.startTest();
        try {
            insert task;
        } catch (DmlException e) {
        }
        Test.stopTest();
    }
}