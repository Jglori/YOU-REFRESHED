@isTest
public class TaskHelperTest {
    
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
            Status = 'Novo',
            ConfiguracaoDeSLA__c = configs.get(0).Id
            
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
    static void testValidateTaskDate() {
        List<Task> lstTask = [SELECT Id, WhoId, ActivityDate FROM Task];
        Test.startTest();
      	TaskHelper.validateTaskDate(lstTask);
        Test.stopTest();

        System.assertEquals(true, lstTask[0].Id != null);

    }
}