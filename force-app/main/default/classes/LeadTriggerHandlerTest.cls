@IsTest
public class LeadTriggerHandlerTest {
    
    @TestSetup
    static void makeData() {
        // Criar Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste empreendimento',
            CNPJEmpreendimento__c = '07135796000139'
        );
        insert empreendimento;
        
        // Criar Leads com Status "Novo"
        Lead lead1 = new Lead(
            LastName = 'Will',
            Company = 'Elera',
            Email = 'Willdantas@gmail.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11960387699',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert lead1;

        Lead lead2 = new Lead(
            LastName = 'Eduardo Verri',
            Company = 'São Paulo Tech School',
            Email = 'eduardoverry@gmail.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11987563201',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert lead2;
    }

    @IsTest
    static void testBeforeUpdate_AdvancingFromAttemptToContact() {
        // Recuperar um Lead com Status "Novo"
        Lead testLead = [SELECT Id, Status FROM Lead WHERE Status = 'Novo' LIMIT 1];
        
        // Atualizar o status para "Tentativa de Contato"
        testLead.Status = 'Tentativa de Contato';
        update testLead;

        // Criar e concluir uma tarefa para permitir a atualização
        Task task = new Task(
            Subject = 'Chamada',
            Status = 'Completed', // Tarefa concluída
            WhoId = testLead.Id
        );
        insert task;

        // Atualizar o status para "Contato Realizado"
        testLead.Status = 'Contato Realizado';
        Test.startTest();
        update testLead;
        Test.stopTest();

        Lead updatedLead = [SELECT Status FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('Contato Realizado', updatedLead.Status, 'O status do Lead deveria ser "Contato Realizado"');
    }

    @IsTest
    static void testBeforeUpdate_AdvancingFromContactMade() {
        // Recuperar um Lead com Status "Novo"
        Lead testLead = [SELECT Id, Status FROM Lead WHERE Status = 'Novo' LIMIT 1];
        
        // Atualizar o status para "Tentativa de Contato"
        testLead.Status = 'Tentativa de Contato';
        update testLead;

        // Criar e concluir uma tarefa para permitir a atualização
        Task task = new Task(
            Subject = 'Chamada',
            Status = 'Completed', // Tarefa concluída
            WhoId = testLead.Id
        );
        insert task;

        // Atualizar o status para "Contato Realizado"
        testLead.Status = 'Contato Realizado';
        Test.startTest();
        update testLead;
        Test.stopTest();

        Lead updatedLead = [SELECT Status FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('Contato Realizado', updatedLead.Status, 'O status do Lead deveria ser "Contato Realizado"');
    }

    @IsTest
    static void testBeforeUpdate_NotAdvancing() {
        // Recuperar um Lead com Status "Novo"
        Lead testLead = [SELECT Id, Status FROM Lead WHERE Status = 'Novo' LIMIT 1];
        
        // Atualizar o status para "Tentativa de Contato"
        testLead.Status = 'Tentativa de Contato';
        update testLead;

        // Criar uma tarefa, mas não concluí-la
        Task task = new Task(
            Subject = 'Chamada',
            Status = 'Open', // Tarefa aberta
            WhoId = testLead.Id
        );
        insert task;

        // Tentar atualizar para um status inválido sem seguir as regras
        testLead.Status = 'Contato Realizado';
        Test.startTest();
        try {
            update testLead;
            System.assert(false, 'A atualização para "Contato Realizado" deveria falhar sem tarefa concluída');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Deveria ocorrer uma exceção de validação customizada');
        }
        Test.stopTest();
    }

    @IsTest
    static void testarCenarioErroCath() {
        // Criar um Lead com Status "Novo"
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
            // Tentar atualizar o Lead para "Contato Realizado" sem seguir as regras
            newLead.Status = 'Contato Realizado'; 
            update newLead;
        } catch (DmlException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'A exceção DmlException deveria ter sido lançada');
    }

    @IsTest
    static void isTaskCreatedAndOpenForAttemptToContactTest() {
        // Criar um Lead com Status "Novo"
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

        // Atualizar o status para "Tentativa de Contato"
        testLead.Status = 'Tentativa de Contato';
        update testLead;

        // Criar e não concluir uma tarefa
        Task task = new Task(
            Subject = 'Chamada',
            Status = 'Open', // Tarefa aberta
            WhoId = testLead.Id
        );
        insert task;

        // Atualizar o status para "Contato Realizado"
        testLead.Status = 'Contato Realizado';
        Test.startTest();
        try {
            update testLead;
            System.assert(false, 'A atualização para "Contato Realizado" deveria falhar sem tarefa concluída');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Deveria ocorrer uma exceção de validação customizada');
        }
        Test.stopTest();

        // Verificar se existe uma tarefa aberta associada ao Lead
        List<Task> tasks = [SELECT Id, WhoId, Subject, Status FROM Task WHERE WhoId = :testLead.Id AND Status = 'Open' LIMIT 1];
        System.assert(!tasks.isEmpty(), 'Deveria haver pelo menos uma tarefa com status Open associada ao Lead');
    }
    
    @IsTest
    static void beforeUpdateTest() {
        // Criar um Lead com Status "Novo"
        Lead lead = new Lead(
            LastName = 'silencio',
            Company = 'Elera',
            Email = 'elera@gmail.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11960387699',
            Status = 'Novo'
            // Adicione outros campos obrigatórios ou relevantes conforme necessário
        );
        insert lead;
    
        // Atualizar o Lead para "Tentativa de Contato"
        lead.Status = 'Tentativa de Contato';
        update lead;
        
        // Criar uma tarefa com o status "Completed"
        Task task = new Task(
            Subject = 'Chamada',
            Status = 'Completed', // Tarefa concluída
            WhoId = lead.Id
        );
        insert task;
    
        // Atualizar o Lead para "Contato Realizado"
        lead.Status = 'Contato Realizado';
        Test.startTest();
        update lead;
        Test.stopTest();
    
        // Recuperar o Lead atualizado
        lead = [SELECT Status FROM Lead WHERE Id = :lead.Id];
        System.assertEquals('Contato Realizado', lead.Status, 'O status do Lead deveria ser "Contato Realizado" após a atualização');
    }
}