@IsTest
public class RoletaLeadsSelectorTest {
    @TestSetup
    static void setup() {
        // Setup Users
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

        // Setup Equipes
        Equipe__c equipe1 = new Equipe__c(Name = 'Equipe 1', CargaMaxima__c = 100);
        Equipe__c equipe2 = new Equipe__c(Name = 'Equipe 2', CargaMaxima__c = 100);
        insert new List<Equipe__c>{equipe1, equipe2};

        // Setup MembroEquipe
        MembroEquipe__c membro1 = new MembroEquipe__c(Name = 'Jéssica BM', Equipe__c = equipe1.Id, Usuario__c = user1.Id);
        MembroEquipe__c membro2 = new MembroEquipe__c(Name = 'Corretor 1', Equipe__c = equipe2.Id, Usuario__c = user2.Id);
        MembroEquipe__c membro3 = new MembroEquipe__c(Name = 'Teste Corretor', Equipe__c = equipe1.Id, Usuario__c = user1.Id);
        insert new List<MembroEquipe__c>{membro1, membro2, membro3};

        // Setup RoletaLeads
        RoletaLeads__c roletaLeads = new RoletaLeads__c(
            Name = 'Roleta - Equipe 0',
            Ativa__c = true,
            HoraInicio__c = Datetime.now().time(),
            CanaisAtendimento__c = 'WhatsApp',
            Equipe__c = equipe1.Id,
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );
        insert roletaLeads;

        // Setup Contact
        Contact corretor1 = new Contact(
            FirstName = 'Pereira Lucas', 
            LastName = 'Silva',
            CPF__c = '10695957058'
        );
        insert corretor1;

        // Setup ParticipanteRoleta
        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            Name = 'Lucas',
            MembroEquipe__c = membro1.Id,
            RoletaLeads__c = roletaLeads.Id,
            Posicao__c = 1,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert participante;

        ParticipanteRoleta__c participante2 = new ParticipanteRoleta__c(
            Name = 'Ewerton',
            MembroEquipe__c = membro1.Id,
            RoletaLeads__c = roletaLeads.Id,
            Posicao__c = 5,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert participante2;

        ParticipanteRoleta__c participante3 = new ParticipanteRoleta__c(
            Name = 'Luan',
            MembroEquipe__c = membro2.Id,
            RoletaLeads__c = roletaLeads.Id,
            Posicao__c = 5,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert participante3;
    }
    
    @IsTest
    static void testObterRoletasLeadsVigentes() {
        List<RoletaLeads__c> roletas = RoletaLeadsSelector.obterRoletasLeadsVigentes();
    }

    @IsTest
    static void testObterRoletasLeadsPorIdsMembros() {
        Set<Id> idsMembros = new Set<Id>();
        idsMembros.add([SELECT Id FROM MembroEquipe__c LIMIT 1].Id);
        
        List<RoletaLeads__c> roletas = RoletaLeadsSelector.obterRoletasLeadsPorIdsMembros(idsMembros);
    }

    @IsTest
    static void testObterRoletasLeadsPorIdsUsuarios() {
        Set<Id> idsUsuarios = new Set<Id>();
        idsUsuarios.add([SELECT Id FROM User LIMIT 1].Id);
        
        List<RoletaLeads__c> roletas = RoletaLeadsSelector.obterRoletasLeadsPorIdsUsuarios(idsUsuarios);
    }

    @IsTest
    static void testObterRoletasLeadsPorCanaisAtendimento() {
        String canaisAtendimento = 'WhatsApp';
        
        List<RoletaLeads__c> roletas = RoletaLeadsSelector.obterRoletasLeadsPorCanaisAtendimento(canaisAtendimento);
    }

    @IsTest
    static void testObterRoletasLeadsPorCanaisAtendimentoEmpty() {
        String canaisAtendimento = '';
        
        List<RoletaLeads__c> roletas = RoletaLeadsSelector.obterRoletasLeadsPorCanaisAtendimento(canaisAtendimento);
    }
}