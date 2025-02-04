@isTest
public class TaskTriggerHandlerTest {

    @TestSetup
    static void setup() {
        // Criação do Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento', CNPJEmpreendimento__c ='07135796000139');
        insert empreendimento;

        // Criação das Configurações de Negócio
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

    @isTest
    static void testBeforeInsert() {
        // Criação de uma nova Task para teste de beforeInsert
        Task newTask = new Task(
            WhoId = [SELECT Id FROM Lead LIMIT 1].Id,
            Subject = 'Chamada',
            Status = 'Open',
            ActivityDate = Date.today().addDays(5)
        );

        Test.startTest();
        insert newTask;
        Test.stopTest();

      }

    @isTest
    static void testBeforeUpdate() {
        Task task = [SELECT Id, ActivityDate FROM Task LIMIT 1];
        
        // Atualização da data da Task
        task.ActivityDate = Date.today().addDays(10);

        Test.startTest();
        update task;
        Test.stopTest();

        }

    @isTest
    static void testAfterUpdate() {
        Task task = [SELECT Id, WhoId, Status FROM Task LIMIT 1];
        
        // Atualiza a Task para um status de concluída
        task.Status = 'Completed';

        Test.startTest();
        update task;
        Test.stopTest();

       }
}