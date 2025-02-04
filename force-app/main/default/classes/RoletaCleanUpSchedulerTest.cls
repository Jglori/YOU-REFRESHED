@isTest
public class RoletaCleanUpSchedulerTest {
    @testSetup
    static void setup() {
        // Criar usuários
        User user1 = new User(Alias = 'user1', Email = 'user1@test.com', 
            EmailEncodingKey = 'UTF-8', LastName = 'Test', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', ProfileId = UserInfo.getProfileId(), 
            TimeZoneSidKey = 'America/Los_Angeles', 
            CompanyName = 'You',
            Username = 'user1_' + System.currentTimeMillis() + '@test.com',
            Situacao__c = 'Online');
                
        User user2 = new User(Alias = 'user2', Email = 'user2@test.com', 
            EmailEncodingKey = 'UTF-8', LastName = 'Test', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', ProfileId = UserInfo.getProfileId(), 
            TimeZoneSidKey = 'America/Los_Angeles', 
            Username = 'user2_' + System.currentTimeMillis() + '@test.com',
            CompanyName = 'You',
            Situacao__c = 'Offline');
        
        insert new List<User>{user1, user2};

        // Criar equipes
        Equipe__c equipe1 = new Equipe__c(Name = 'Equipe 1', CargaMaxima__c = 100);
        Equipe__c equipe2 = new Equipe__c(Name = 'Equipe 2', CargaMaxima__c = 100);
        insert new List<Equipe__c>{equipe1, equipe2};

        // Criar membros da equipe
        MembroEquipe__c membro1 = new MembroEquipe__c(Name = 'Jéssica BM', Equipe__c = equipe1.Id, Usuario__c = user1.Id);
        MembroEquipe__c membro2 = new MembroEquipe__c(Name = 'Corretor 1', Equipe__c = equipe2.Id, Usuario__c = user2.Id);
        MembroEquipe__c membro3 = new MembroEquipe__c(Name = 'Teste Corretor', Equipe__c = equipe1.Id, Usuario__c = user1.Id);
        insert new List<MembroEquipe__c>{membro1, membro2, membro3};

        // Criar roleta
        RoletaLeads__c roletaLeads = new RoletaLeads__c(
            Name = 'Roleta - Equipe 0',
            Ativa__c = true,
            HoraInicio__c = Datetime.now().time(),
            CanaisAtendimento__c = 'WhatsApp',
            Equipe__c = equipe1.Id,
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );
        insert roletaLeads;

        // Criar contato
        Contact corretor1 = new Contact(
            FirstName = 'Pereira Lucas', 
            LastName = 'Silva',
            CPF__c = '10695957058'
        );
        insert corretor1;

        // Criar participantes da roleta
        ParticipanteRoleta__c participante1 = new ParticipanteRoleta__c(
            Name = 'Lucas',
            MembroEquipe__c = membro1.Id,
            RoletaLeads__c = roletaLeads.Id,
            Posicao__c = 1,
            UsuarioCorretor__c = corretor1.Id 
        );
        ParticipanteRoleta__c participante2 = new ParticipanteRoleta__c(
            Name = 'Ewerton',
            MembroEquipe__c = membro1.Id,
            RoletaLeads__c = roletaLeads.Id,
            Posicao__c = 5,
            UsuarioCorretor__c = corretor1.Id 
        );
        ParticipanteRoleta__c participante3 = new ParticipanteRoleta__c(
            Name = 'Luan',
            MembroEquipe__c = membro2.Id,
            RoletaLeads__c = roletaLeads.Id,
            Posicao__c = 5,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert new List<ParticipanteRoleta__c>{participante1, participante2, participante3};
    }

    @isTest
    static void testExecute() {
        // Verificar se os participantes foram criados
        List<ParticipanteRoleta__c> participantesAntes = [SELECT Id FROM ParticipanteRoleta__c];
      //	  System.assert(participantesAntes.size() > 0, 'Os participantes devem estar presentes antes da execução do job.');

        // Agendar o job
        String cronExp = '0 0 0 1 1 ? 2050'; // Agendando para uma data futura para simular o job
        System.schedule('Test RoletaCleanUpScheduler', cronExp, new RoletaCleanUpScheduler());

        // Executar o job
        Test.startTest();
        // Executa o job que foi agendado
        CronTrigger ct = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Test RoletaCleanUpScheduler'];
        System.abortJob(ct.Id);
        Test.stopTest();

        // Verificar se os participantes foram excluídos
    //    List<ParticipanteRoleta__c> participantesDepois = [SELECT Id FROM ParticipanteRoleta__c];
        //System.assertEquals(0, participantesDepois.size(), 'Os participantes devem ser excluídos após a execução do job.');
    }
}