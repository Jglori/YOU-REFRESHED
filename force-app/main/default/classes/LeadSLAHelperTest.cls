@isTest
public class LeadSLAHelperTest {
    
    @testSetup
    static void setup() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Group testGroup = new Group(Name='rock', Type='Queue');
            insert testGroup;
            insert new QueueSObject(QueueID = testGroup.id, SObjectType = 'Lead');
        }
        
        List<ConfiguracoesDeNegocio__c> configs = new List<ConfiguracoesDeNegocio__c> {
            new ConfiguracoesDeNegocio__c(
                TempoDeSla__c = 1440,  // 1440 minutos (1 dia)
                Fase__c = 'Novo',
                FaseParaRedirecionamentoDoLead__c = 'Novo',
                FilaParaRedirecionamentoDoLead__c = 'rock'
            ),
            new ConfiguracoesDeNegocio__c(
                TempoDeSla__c = 720,  // 720 minutos (12 horas)
                Fase__c = 'Tentativa de contato',
                FaseParaRedirecionamentoDoLead__c = 'Tentativa de contato',
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

        Task task = new Task(
            Subject = 'Whatsapp',
            WhoId = lead.Id
        );
        insert task;

        Event event = new Event(
            Subject = 'Meeting',
            WhoId = lead.Id,
            StartDateTime = DateTime.now().addDays(1),
            EndDateTime = DateTime.now().addDays(2)
        );
        insert event;
    }

    @isTest
    static void testLeadVencidoSchedule() {
        List<Lead> lstLead = [SELECT Id, Status, ConfiguracaoDeSLA__c FROM Lead];
        Test.startTest();
        LeadSLAHelper.verifyLeadControlSLA(lstLead, null);
        Test.stopTest();
        
        // Verifica se a DataHoraVencimento__c foi atualizada corretamente
        Lead updatedLead = [SELECT DataHoraVencimento__c FROM Lead LIMIT 1];
        System.assertNotEquals(null, updatedLead.DataHoraVencimento__c, 'DataHoraVencimento__c should not be null');
    }
    
    @isTest
    static void testValidateTaskDate() {
        List<Task> tasks = [SELECT Id, WhoId, ActivityDate FROM Task];
        Test.startTest();
        LeadSLAHelper.validateTaskDate(tasks);
        Test.stopTest();

        Lead lead = [SELECT DataHoraVencimento__c FROM Lead LIMIT 1];
        System.assertNotEquals(null, lead.DataHoraVencimento__c, 'DataHoraVencimento__c should not be null after task validation');
    }

    @isTest
    static void testValidateEventDate() {
        List<Event> events = [SELECT Id, WhoId, EndDateTime FROM Event];
        Test.startTest();
        LeadSLAHelper.validateEventDate(events);
        Test.stopTest();

        Lead lead = [SELECT DataHoraVencimento__c FROM Lead LIMIT 1];
        System.assertNotEquals(null, lead.DataHoraVencimento__c, 'DataHoraVencimento__c should not be null after event validation');
    }
}