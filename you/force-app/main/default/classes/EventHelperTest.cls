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

        Task task = new Task(
            Subject = 'WhatsApp',
            WhoId = leads[0].Id,
            ActivityDate = Date.today().addDays(5),
            Status = 'Completed'
        );

        insert task;

        Task Task2 = new Task(
            Subject = 'Chamada',
            WhoId = leads[1].Id,
            ActivityDate = Date.today().addDays(-5),
            Status = 'Completed'
        );

        insert Task2;
    }
    @isTest
    public static void validateLeadStatusTest(){
        List<Lead> leads = [SELECT Id, Status FROM Lead];
        System.debug('leads: '+leads);
        
        List<Event> events = new List<Event> {
            new Event(
                Subject = 'Teste01',
                Type = 'Visita',
                ActivityDate = Date.today(),
                DurationInMinutes = 60,
                ActivityDateTime = Datetime.now(),
                WhoId = leads.get(0).Id,
                Status_do_Compromisso__c = 'Realizada com Sucesso',
                Location = 'teste'
            ),
            new Event(
                Subject = 'Teste02',
                Type = 'Visita',
                ActivityDate = Date.today(),
                DurationInMinutes = 60,
                ActivityDateTime = Datetime.now(),
                WhoId = leads.get(1).Id,
                Status_do_Compromisso__c = 'Não Realizada',
                Motivo_da_visita_n_o_realizada__c = 'Fora da cidade',
                Location = 'teste'
            )
        };

        
        insert events;
        List<Event> ev = [SELECT Subject,WhoId, Type, DurationInMinutes, Status_do_Compromisso__c, ActivityDate, Motivo_da_visita_n_o_realizada__c, EndDateTime FROM Event];

        System.debug('lista ev: ' + ev);
        Test.startTest();
        
       
        EventHelper.validateEventStatus(ev);
        
        EventHelper.validateEventDate(ev);
        
        Test.stopTest();

        System.assert(!ev.get(0).hasErrors());

    }
    
}