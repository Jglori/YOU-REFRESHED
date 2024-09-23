@isTest
public class LeadSLAHelperTest {
    
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
                TempoDeSla__c = 1440,
                Fase__c = 'Novo',
                FaseParaRedirecionamentoDoLead__c = 'Novo',
                FilaParaRedirecionamentoDoLead__c = 'rock'
            )
        };
        insert configs;

        DateTime dataHoraVencida = DateTime.now().addDays(-1);

        Lead lead = new Lead(
            LastName = 'Teste',
            Description = 'Teste',
            Email = 'contato@teste.com',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11960387699',
            Status = 'Novo',
            ConfiguracaoDeSLA__c = configs.get(0).Id
            
        );
        insert lead;

        System.debug(JSON.serialize([SELECT Id, DataHoraVencimento__c, Vencido__c FROM Lead]));

        lead.Status = 'Tentativa de contato';
        update lead;
        
        Task task = new Task(
            Subject = 'Whatsapp',
            WhoId = lead.Id
        );
        insert task;
    }
    
    @isTest
    static void testLeadVencidoSchedule() {
        List<Lead> lstLead = [SELECT Id, Status FROM Lead];
        Test.startTest();
      	LeadSLAHelper.verifyLeadControlSLA(lstLead, null);
        Test.stopTest();

       // System.assertEquals(true, lstLead[0].DataHoraVencimento__c != null);

    }
}