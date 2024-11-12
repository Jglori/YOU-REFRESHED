@IsTest
public class TaskTriggerTest {

    @TestSetup
    static void setup() {
        // Criação do Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento', CNPJEmpreendimento__c = '07135796000139');
        insert empreendimento;

        // Criação da Configuração de Negócio
        ConfiguracoesDeNegocio__c conf = new ConfiguracoesDeNegocio__c(name = 'teste', TempoDeSLA__c = 10);
        insert conf;

        // Criação do Lead associado ao empreendimento
        Lead lead = new Lead(
            LastName = 'Paulo',
            Company = 'Elera',
            Email = 'pauloelera123@gmail.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11960387699',
            Status = 'Novo',
            cpf__c = '50154031003',
            cnpj__c = '28724715000106',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert lead;

        // Atualização de status do lead
        lead.Status = 'Tentativa de contato';
        update lead;

        // Criação da Task
        Task task = new Task(
            WhoId = lead.Id,
            Subject = 'Chamada',
            Status = 'Not Started',
            ActivityDate = Date.today().addDays(4)
        );
        insert task;
    }

    @IsTest
    static void testBeforeInsert() {
        // Configuração de teste
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Task task = new Task(
            WhoId = lead.Id,
            Subject = 'Email',
            Status = 'Not Started',
            ActivityDate = Date.today().addDays(2)
        );

        Test.startTest();
        insert task;
        Test.stopTest();

        // Verificação se a Task foi inserida corretamente
        Task insertedTask = [SELECT Id, ActivityDate FROM Task WHERE Id = :task.Id];
        System.assertEquals(Date.today().addDays(2), insertedTask.ActivityDate);
    }

    @IsTest
    static void testBeforeUpdate() {
        Task task = [SELECT Id, ActivityDate FROM Task LIMIT 1];
        task.ActivityDate = Date.today().addDays(5);

        Test.startTest();
        update task;
        Test.stopTest();

        // Verificação se a Task foi atualizada corretamente
        Task updatedTask = [SELECT Id, ActivityDate FROM Task WHERE Id = :task.Id];
        System.assertEquals(Date.today().addDays(5), updatedTask.ActivityDate);
    }

    @IsTest
    static void testAfterUpdate() {
        Task task = [SELECT Id, WhoId, Status FROM Task LIMIT 1];
        task.Status = 'Completed';

        Test.startTest();
        update task;
        Test.stopTest();

    }

    @IsTest
    static void testBeforeDelete() {
        Task task = [SELECT Id FROM Task LIMIT 1];

        Test.startTest();
        delete task;
        Test.stopTest();

        // Verificação se a Task foi deletada corretamente
        Integer count = [SELECT COUNT() FROM Task WHERE Id = :task.Id];
        System.assertEquals(0, count);
    }

    @IsTest
    static void testAfterInsert() {
        // Configuração de teste
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Task task = new Task(
            WhoId = lead.Id,
            Subject = 'Reunião',
            Status = 'Not Started',
            ActivityDate = Date.today().addDays(3)
        );

        Test.startTest();
        insert task;
        Test.stopTest();

        // Verificação se a Task foi inserida corretamente
        Task insertedTask = [SELECT Id, ActivityDate FROM Task WHERE Id = :task.Id];
        System.assertEquals(Date.today().addDays(3), insertedTask.ActivityDate);
    }

    @IsTest
    static void testAfterDelete() {
        // Configuração de teste
        Task task = new Task(
            WhoId = [SELECT Id FROM Lead LIMIT 1].Id,
            Subject = 'Reunião',
            Status = 'Not Started',
            ActivityDate = Date.today().addDays(3)
        );
        insert task;

        Test.startTest();
        delete task;
        Test.stopTest();

        // Verificação se a Task foi deletada corretamente
        Integer count = [SELECT COUNT() FROM Task WHERE Id = :task.Id];
        System.assertEquals(0, count);
    }
}