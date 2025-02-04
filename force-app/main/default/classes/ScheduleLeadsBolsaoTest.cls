@isTest
public class ScheduleLeadsBolsaoTest {
    @testSetup
    static void setup() {
        // Cria e insere usuários
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User user1 = new User(Alias = 'user1', Email = 'user1@test.com', 
            EmailEncodingKey = 'UTF-8', LastName = 'Test', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', ProfileId = p.Id, 
            TimeZoneSidKey = 'America/Los_Angeles', 
            CompanyName = 'You',
            Username = 'user1_' + System.currentTimeMillis() + '@test.com',
            Situacao__c = 'Online');
                
        User user2 = new User(Alias = 'user2', Email = 'user2@test.com', 
            EmailEncodingKey = 'UTF-8', LastName = 'Test', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', ProfileId = p.Id, 
            TimeZoneSidKey = 'America/Los_Angeles', 
            Username = 'user2_' + System.currentTimeMillis() + '@test.com',
            CompanyName = 'You',
            Situacao__c = 'Offline');
        
        insert new List<User>{user1, user2};

        // Cria e insere equipes
        Equipe__c equipe1 = new Equipe__c(Name = 'Equipe 1', CargaMaxima__c = 100);
        Equipe__c equipe2 = new Equipe__c(Name = 'Equipe 2', CargaMaxima__c = 100);
        insert new List<Equipe__c>{equipe1, equipe2};

        // Cria e insere membros da equipe
        MembroEquipe__c membro1 = new MembroEquipe__c(Name = 'Jéssica BM', Equipe__c = equipe1.Id, Usuario__c = user1.Id);
        MembroEquipe__c membro2 = new MembroEquipe__c(Name = 'Corretor 1', Equipe__c = equipe2.Id, Usuario__c = user2.Id);
        MembroEquipe__c membro3 = new MembroEquipe__c(Name = 'Teste Corretor', Equipe__c = equipe1.Id, Usuario__c = user1.Id);
        insert new List<MembroEquipe__c>{membro1, membro2, membro3};

        // Cria e insere roleta de leads
        RoletaLeads__c roletaLeads = new RoletaLeads__c(
            Name = 'Roleta - Equipe 1',
            Ativa__c = true,
            HoraInicio__c = Datetime.now().time(),
            CanaisAtendimento__c = 'WhatsApp',
            Equipe__c = equipe1.Id,
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );
        insert roletaLeads;
    }

    @isTest
    static void testExecute() {
        // Simula a execução do método execute do ScheduleLeadsBolsao
        ScheduleLeadsBolsao scheduler = new ScheduleLeadsBolsao();

        Test.startTest();
        scheduler.execute(null);
        Test.stopTest();

        // Verifica se o método LeadsBolsaoHorarioAgendado foi chamado corretamente
        // Para isso, é possível usar um mock ou verificar se os resultados esperados foram produzidos
        // A implementação dependerá dos detalhes de LeadsBolsaoHelper.LeadsBolsaoHorarioAgendado
    }

    @isTest
    static void testScheduleDailyJobs() {
        Test.startTest();
        ScheduleLeadsBolsao.scheduleDailyJobs();
        Test.stopTest();

        // Verifica se os jobs foram agendados corretamente
        List<CronTrigger> scheduledJobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'DailyLeadsBolsaoJob_%'];
        System.assertEquals(30, scheduledJobs.size(), 'Todos os 30 jobs diários devem ser agendados.');
    }
}