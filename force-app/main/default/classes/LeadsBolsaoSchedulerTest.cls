@isTest
public class LeadsBolsaoSchedulerTest {
    
    @testSetup
    static void setup() {
        // Criação de registros fictícios de Equipe__c para garantir que o relacionamento com RoletaLeads__c funcione corretamente
        Equipe__c equipe1 = new Equipe__c(Name = 'Equipe 1', CargaMaxima__c = 100);
        Equipe__c equipe2 = new Equipe__c(Name = 'Equipe 2', CargaMaxima__c = 100);
        insert new List<Equipe__c>{equipe1, equipe2};
        
        // Criação do registro de RoletaLeads__c com o relacionamento para a Equipe
        RoletaLeads__c roleta = new RoletaLeads__c(
            Name = 'Roleta - Equipe 1',
            Ativa__c = true,
            HoraInicio__c = Datetime.now().time(),
            CanaisAtendimento__c = 'WhatsApp',
            Equipe__c = equipe1.Id,  // Relacionando a roleta com a equipe criada
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );
        insert roleta;
    }
    
    @isTest
    static void testScheduleDailyJobs() {
        // Chama o método para agendar os jobs
        Test.startTest();
        LeadsBolsaoScheduler.scheduleDailyJobs();
        Test.stopTest();

        // Verifica se o método de agendamento foi chamado corretamente.
        // O CronTrigger é uma boa maneira de verificar se o job foi agendado
        List<CronTrigger> scheduledJobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'DailyLeadsBolsaoJob%'];


      }

    @isTest
    static void testExecuteMethod() {
        // Cria um mock da lista de RoletaLeads__c ativa com a equipe associada
        Equipe__c equipe1 = new Equipe__c(Name = 'Equipe Teste', CargaMaxima__c = 100);
        insert equipe1;

        RoletaLeads__c roleta = new RoletaLeads__c(
            Ativa__c = true,
            HoraInicio__c = System.now().time(),
            Equipe__c = equipe1.Id
        );
        insert roleta;

        // Mock do helper (sem realmente executar a lógica do helper)
        Test.startTest();
        LeadsBolsaoScheduler scheduler = new LeadsBolsaoScheduler();
        scheduler.execute(null);
        Test.stopTest();
        
    
    }
}