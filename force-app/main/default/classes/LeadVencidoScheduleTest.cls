@isTest
public class LeadVencidoScheduleTest {
    
    @testSetup
    static void setup() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Group testGroup = new Group(Name='rock', Type='Queue');
        	insert testGroup;
    		insert new QueueSObject(QueueID = testGroup.id, SObjectType = 'Lead');
		}
        
        List<ConfiguracoesDeNegocio__c> configs = new List<ConfiguracoesDeNegocio__c> {
            new ConfiguracoesDeNegocio__c(
                // 1.440 minutos(um dia)
                TempoDeSla__c = -1440,
                Fase__c = 'Novo',
                FaseParaRedirecionamentoDoLead__c = 'Novo',
                FilaParaRedirecionamentoDoLead__c = 'rock'
            )
        };
        insert configs;

        DateTime dataHoraVencida = DateTime.now().addDays(-1);

        Lead lead = new Lead(
            LastName = 'Teste',
            Email = 't@gmail.com',
            Description = 'Teste',
            Status = 'Novo',
            ConfiguracaoDeSLA__c = configs.get(0).Id,
            DataHoraVencimento__c = dataHoraVencida,
            CanalAtendimento__c = 'Whatsapp'
        );
        insert lead;

        System.debug(JSON.serialize([SELECT Id, DataHoraVencimento__c, Vencido__c FROM Lead]));

        Task task = new Task(
            Subject = 'Whatsapp',
            WhoId = lead.Id
        );
        insert task;
    }
    
    @isTest
    static void testLeadVencidoSchedule() {
        Test.startTest();
      	Group grupo = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name = 'rock'].get(0);
        LeadVencidoSchedule.execute(null);
        Test.stopTest();

        //System.assertEquals(true, [SELECT OwnerId FROM Lead].get(0).OwnerId.equals(grupo.Id));

    }
}