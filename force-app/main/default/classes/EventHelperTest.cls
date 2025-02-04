@isTest
public class EventHelperTest {
    @TestSetup
    static void makeData() {
        doCreateData();
    }

    private static void doCreateData() {
        // Criar e inserir um Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c();
        empreendimento.Name = 'Empreendimento de Teste';
        empreendimento.CNPJEmpreendimento__c = '36658601000133';
        insert empreendimento;

        // Criar e inserir Leads
        List<Lead> leads = new List<Lead> {
            new Lead(
                LastName = 'Paulo',
                Company = 'Elera',
                Email = 'paulo@emaill.com',
                LeadSource = 'Telefone',
                CanalAtendimento__c = 'Chat',
                MobilePhone = '11960387699',
                Status = 'Novo',
                EmpreendimentoInteresse__c = empreendimento.Id 
            ),
            new Lead(
                LastName = 'Igor',
                Company = 'Elera',
                Email = 'igor@email.com',
                LeadSource = 'Telefone',
                CanalAtendimento__c = 'Chat',
                MobilePhone = '11960387699',
                Status = 'Novo',
                EmpreendimentoInteresse__c = empreendimento.Id 
            )
        };
        insert leads;

        // Atualizar o status dos Leads
        leads[0].Status = 'Tentativa de Contato';  // Atualiza para "Tentativa de Contato"
        leads[1].Status = 'Tentativa de Contato';  // Atualiza para "Tentativa de Contato"
        update leads;

        // Criar e inserir uma Task do tipo "WhatsApp" para os Leads
        Task task1 = new Task(
            Subject = 'WhatsApp',
            WhoId = leads[0].Id,
            ActivityDate = Date.today().addDays(5),
            Status = 'Completed'  // Marcar como concluído
        );

        Task task2 = new Task(
            Subject = 'WhatsApp',
            WhoId = leads[1].Id,
            ActivityDate = Date.today().addDays(5),
            Status = 'Completed'  // Marcar como concluído
        );

        insert new List<Task>{task1, task2};

        // Agora que a Task foi criada, vamos atualizar o status dos leads
        leads[0].Status = 'Agendamento de Visita';  // Atualiza para "Agendamento de Visita"
        leads[1].Status = 'Agendamento de Visita';  // Atualiza para "Agendamento de Visita"
        update leads;
    }

    @isTest
    public static void validateLeadStatusTest() {
        // Obter Leads para validar no teste
        List<Lead> leads = [SELECT Id, Status FROM Lead];
        System.debug('leads: ' + leads);

        // Criar e inserir Events
        List<Event> events = new List<Event>{
            new Event(
                Subject = 'Visita',
                Type = 'Visita',
                ActivityDate = Date.today(),
                DurationInMinutes = 60,
                ActivityDateTime = Datetime.now(),
                WhoId = leads[0].Id,
                Status_do_Compromisso__c = 'Realizada com Sucesso',
                Location = 'teste'
            ),
            new Event(
                Subject = 'Visita',
                Type = 'Visita',
                ActivityDate = Date.today(),
                DurationInMinutes = 60,
                ActivityDateTime = Datetime.now(),
                WhoId = leads[1].Id,
                Status_do_Compromisso__c = 'Não Realizada',
                Motivo_da_visita_n_o_realizada__c = 'Fora da cidade',
                Location = 'teste'
            )
        };

        insert events;

        // Iniciar o teste
        Test.startTest();
        EventHelper.validate(events);
        Test.stopTest();

        // Obter e validar Events atualizados
        List<Event> updatedEvents = [SELECT Subject, WhoId, Type, DurationInMinutes, Status_do_Compromisso__c, ActivityDate, Motivo_da_visita_n_o_realizada__c, EndDateTime, Location FROM Event];
        System.debug('lista ev: ' + updatedEvents);

        for (Event ev : updatedEvents) {
            System.assert(!ev.hasErrors(), 'O evento possui erros: ' + ev);
        }

        // Chamar o método obterLeadsPorIds e validar seu funcionamento
        Set<Id> leadIds = new Set<Id>();
        for (Lead lead : leads) {
            leadIds.add(lead.Id);
        }
        
        List<Lead> leadsObtidos = LeadSelector.obterLeadsPorIds(leadIds);
        System.assertEquals(2, leadsObtidos.size(), 'A quantidade de leads obtidos não está correta');
    }
}