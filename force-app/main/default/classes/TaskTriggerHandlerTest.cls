@isTest
public class TaskTriggerHandlerTest {

    @TestSetup
    static void setup(){


        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento', CNPJEmpreendimento__c ='07135796000139');
        insert empreendimento;

        // Criação do Lead associado ao empreendimento
        ConfiguracoesDeNegocio__c conf =   new ConfiguracoesDeNegocio__c(name = 'teste', TempoDeSLA__c = 10);
        insert conf;
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
            // ConfiguracaoDeSLA__c =conf,
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

    @isTest
    static void testBeforeInsert() {
        // // Criação do Empreendimento
        // Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento', CNPJEmpreendimento__c ='07135796000139');
        // insert empreendimento;

        // // Criação do Lead associado ao empreendimento
        // Lead lead = new Lead(
        //     LastName = 'Paulo',
        //     Company = 'Elera',
        //     Email = 'pauloelera123@gmail.com',
        //     LeadSource = 'Telefone',
        //     CanalAtendimento__c = 'Chat',
        //     MobilePhone = '11960387699',
        //     Status = 'Novo',
        //     EmpreendimentoInteresse__c = empreendimento.Id
        // );
        // insert lead;

        // // Atualização de status do lead
        // lead.Status = 'Tentativa de contato';
        // update lead;

        // // Criação da Task
        // Task task = new Task(
        //     WhoId = lead.Id,
        //     Subject = 'Chamada',
        //     Status = 'Not Started',
        //     ActivityDate = Date.today().addDays(5)
        // );

        // Test.startTest();
        // insert task;
        // Test.stopTest();

        // // Verifica se a Task foi inserida com a data correta
        // Task insertedTask = [SELECT Id, ActivityDate FROM Task WHERE Id = :task.Id];
        // System.assertEquals(Date.today().addDays(5), insertedTask.ActivityDate);
    }

    @isTest
    static void testBeforeUpdate() {

        Task task = [SELECT Id,WhoId, Subject, Status, ActivityDate FROM Task LIMIT 1];
        // Atualização da data da Task
        Lead lead = [SELECT Id, Status FROM Lead where id = : task.WhoId LIMIT 1];
System.debug('Lead: ' + lead);
task.ActivityDate = Date.today().addDays(4);
update task;

        // Verifica se a Task foi atualizada com a nova data correta
        Task updatedTask = [SELECT Id,WhoId,  ActivityDate FROM Task WHERE Id = :task.Id];
        // System.assertEquals(Date.today().addDays(10), updatedTask.ActivityDate);
        // TaskTriggerHandler t = new TaskTriggerHandler();
        // t.beforeUpdate();
    }

    @isTest
    static void testAfterUpdate() {
        // Criação do Empreendimento
        // Test.startTest();

        // Task task = [SELECT Id, WhoId, Status FROM Task LIMIT 1];
        // // Atualiza a Task para um status de concluída
        // task.Status = 'Completed';

        // update task;
        // Test.stopTest();

        // // Verifica se o status do Lead foi atualizado após a conclusão da Task
        // Lead updatedLead = [SELECT Id, Status FROM Lead WHERE Id = :task.WhoId];
        
        // Suponha que o status do Lead seja atualizado para 'Concluído' quando a Task for concluída
         // Ajuste o valor de 'Concluído' conforme a lógica de negócios
    }
}