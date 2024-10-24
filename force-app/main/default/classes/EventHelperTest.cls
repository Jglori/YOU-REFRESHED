@isTest
public class EventHelperTest {
    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData(){
        Empreendimento__c empreendimento = new Empreendimento__c();
        empreendimento.Name = 'Empreendimento de Teste';
        empreendimento.CNPJEmpreendimento__c = '36658601000133';
        insert empreendimento;

        List<Lead> leads = new List<Lead>{
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

        leads[0].Status = 'Tentativa de Contato';
        update leads[0];

        Task task1 = new Task(
            Subject = 'WhatsApp',
            WhoId = leads[0].Id,
            ActivityDate = Date.today().addDays(5),
            Status = 'Completed'
        );

        Task task2 = new Task(
            Subject = 'Chamada',
            WhoId = leads[1].Id,
            ActivityDate = Date.today().addDays(-5),
            Status = 'Completed'
        );

        insert new List<Task>{task1, task2};
    }

    @isTest
    public static void validateLeadStatusTest(){
        List<Lead> leads = [SELECT Id, Status FROM Lead];
        System.debug('leads: ' + leads);

        List<Event> events = new List<Event>{
            new Event(
                Subject = 'Teste01',
                Type = 'Visita',
                ActivityDate = Date.today(),
                DurationInMinutes = 60,
                ActivityDateTime = Datetime.now(),
                idLead__c = leads[0].Id,
                Status_do_Compromisso__c = 'Realizada com Sucesso',
                Location = 'teste'
            ),
            new Event(
                Subject = 'Teste02',
                Type = 'Visita',
                ActivityDate = Date.today(),
                DurationInMinutes = 60,
                ActivityDateTime = Datetime.now(),
                idLead__c = leads[1].Id,
                Status_do_Compromisso__c = 'Não Realizada',
                Motivo_da_visita_n_o_realizada__c = 'Fora da cidade',
                Location = 'teste'
            )
        };

        insert events;

        Test.startTest();
        EventHelper.validate(events);
        Test.stopTest();

        events = [SELECT Subject, WhoId, Type, DurationInMinutes, Status_do_Compromisso__c, ActivityDate, Motivo_da_visita_n_o_realizada__c, EndDateTime, Location FROM Event];
        System.debug('lista ev: ' + events);

        for (Event ev : events) {
            System.assert(!ev.hasErrors(), 'O evento possui erros: ' + ev);
        }
    }
}