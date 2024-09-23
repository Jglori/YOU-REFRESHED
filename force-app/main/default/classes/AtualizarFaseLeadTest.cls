@isTest
public class AtualizarFaseLeadTest {

    @testSetup
    static void setup() {
        // Criar um Empreendimento para associar ao Lead
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste Empreendimento', CNPJEmpreendimento__c = '07135796000139');
        insert empreendimento;

        update empreendimento;
        
        // Criar um Lead com Status 'Novo'
        Lead lead = new Lead(
            FirstName = 'Teste',
            LastName = 'Lead',
            Email = 'testelead@example.com',
            MobilePhone = '11987654321',
            LeadSource = 'Internet',
            CanalAtendimento__c = 'Telefone',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert lead;

        // Atualizar o Status do Lead para 'Tentativa de Contato'
        lead.Status = 'Tentativa de Contato';
        update lead;

        // Criar uma Tarefa concluída para o Lead
        Task completedTask = new Task(
            Subject = 'Whatsapp',
            Status = 'Completed',
            WhoId = lead.Id
        );
        insert completedTask;

        // Atualizar o Status do Lead para 'Contato Realizado'
        lead.Status = 'Contato Realizado';
        update lead;

        // Atualizar o Status do Lead para 'Agendamento de Visita'
        lead.Status = 'Agendamento de Visita';
        update lead;

        // Criar um Evento relacionado ao Lead com Status_do_Compromisso__c 'Pendente'
        Event evento = new Event(
            WhoId = lead.Id,
            Subject = 'Visita',
            Status_do_Compromisso__c = 'Agendado',
            StartDateTime = DateTime.now(),
            EndDateTime = DateTime.now().addHours(1)
        );
        insert evento;
    }

    @isTest
    static void testTriggerNaoAtualizaLead() {
        // Obter o Lead criado no setup
        Lead lead = [SELECT Id, Status FROM Lead LIMIT 1];

        // Atualizar o Evento sem mudar o Status_do_Compromisso__c para disparar o trigger
        Event evento = [SELECT Id, Status_do_Compromisso__c FROM Event WHERE WhoId = :lead.Id LIMIT 1];
        evento.Status_do_Compromisso__c = 'Agendado';
        
        Test.startTest();
        update evento;
        Test.stopTest();

        // Verificar que o Status do Lead não foi atualizado
        Lead updatedLead = [SELECT Id, Status FROM Lead WHERE Id = :lead.Id];
        System.assertEquals('Agendamento de Visita', updatedLead.Status, 'O Status do Lead não deveria ser atualizado');
    }

    @isTest
    static void testTriggerAtualizaLead() {
        // Obter o Lead criado no setup
        Lead lead = [SELECT Id, Status FROM Lead LIMIT 1];

        // Atualizar o Evento com Status_do_Compromisso__c 'Realizada com Sucesso' para disparar o trigger
        Event evento = [SELECT Id, Status_do_Compromisso__c FROM Event WHERE WhoId = :lead.Id LIMIT 1];
        evento.Status_do_Compromisso__c = 'Realizada com Sucesso';
        
        Test.startTest();
        update evento;
        Test.stopTest();

        // Verificar que o Status do Lead foi atualizado para 'Qualificação'
        Lead updatedLead = [SELECT Id, Status FROM Lead WHERE Id = :lead.Id];
        System.assertEquals('Qualificação', updatedLead.Status, 'O Status do Lead deveria ter sido atualizado para "Qualificação"');
    }
}