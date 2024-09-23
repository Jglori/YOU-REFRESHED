@isTest
public class EventTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        doCreateData();
    }

    private static void doCreateData(){
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento',CNPJEmpreendimento__c ='07135796000139');
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

        testLead.Status = 'Tentativa de Contato';
        update testLead;

        Task taskOpen = new Task(
            Subject = 'Chamada',
            Status = 'Open',
            WhoId = testLead.Id
        );
        insert taskOpen;

        taskOpen.Status = 'Completed';
        update taskOpen;
     
        testLead.Status = 'Contato Realizado';
        update testLead;
        testLead.Status = 'Agendamento de Visita';
        update testLead;
        
             
        Event testEvent = new Event(
            WhoId = testLead.Id,
            Subject = 'Email',
            ActivityDate = Date.today().addDays(5),
            DurationInMinutes = 8,
            Status_do_Compromisso__c = 'Realizada com Sucesso',
            ActivityDateTime = Datetime.now()
        );
        insert testEvent;
    }

    @IsTest
    static void testBeforeUpdate() {
       Event testEvent = [SELECT whoId, Subject, DurationInMinutes FROM Event];

        Test.startTest();
        testEvent.Subject = 'Visita';
        update testEvent; 
        Test.stopTest();
    }

  
}