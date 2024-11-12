@isTest
public class SortearParticipantesServiceTest {

    private static final String ALIAS_USUARIO_1 = 'standt';
    private static final String ALIAS_USUARIO_2 = 'teste';
    private static final String EMAIL_USUARIO_1 = 'standarduser@testorg.com';
    private static final String EMAIL_USUARIO_2 = 'teste@testorg.com';
    private static final String LAST_NAME_USUARIO_1 = 'Testing';
    private static final String LAST_NAME_USUARIO_2 = 'Testing1';
    private static final String USERNAME_USUARIO_1 = 'ksaoidsjadosajoidasjiokdaso@rsis.com';
    private static final String USERNAME_USUARIO_2 = 'a28301@rsis.com';


    @TestSetup
    static void setup() {
        
        Id perfilAdministradorSistema = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator'].id;
		
        
        Contact ctt = new Contact(
            LastName = 'jorge',
            DatadeVencimento__c = Date.Today(),
            CPF__c = '46457652050' 
        );
        insert ctt;
        
        update ctt;
        
        List<User> usuarios = new List<User>{
            new User(
                Alias = ALIAS_USUARIO_1,
                Email = EMAIL_USUARIO_1,
                EmailEncodingKey = 'UTF-8',
                LastName = LAST_NAME_USUARIO_1,
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = USERNAME_USUARIO_1,
                ProfileId = perfilAdministradorSistema,
                Situacao__c = 'Online'
            ),
            new User(
                Alias = ALIAS_USUARIO_2,
                Email = EMAIL_USUARIO_2,
                EmailEncodingKey = 'UTF-8',
                LastName = LAST_NAME_USUARIO_2,
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = USERNAME_USUARIO_2,
                ProfileId = perfilAdministradorSistema,
                Situacao__c = 'Online'
            )
        };
        insert usuarios;

        Equipe__c equipe = new Equipe__c();
        insert equipe;

        List<MembroEquipe__c> membrosEquipes = new List<MembroEquipe__c>{
            new MembroEquipe__c(
                Equipe__c = equipe.Id,
                Usuario__c = usuarios.get(0).Id
            ),
            new MembroEquipe__c(
                Equipe__c = equipe.Id,
                Usuario__c = usuarios.get(1).Id
            )
        };
        insert membrosEquipes;

        RoletaLeads__c roletaLeads = new RoletaLeads__c(
            Name = 'Roleta - Equipe 0',
            Ativa__c = true,
            HoraInicio__c = Datetime.now().time(),
            CanaisAtendimento__c = 'WhatsApp',
            Equipe__c = equipe.Id,
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );
        insert roletaLeads;

        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            Entrada__c = System.now(),
            MembroEquipe__c = membrosEquipes.get(0).Id,
            RoletaLeads__c = roletaLeads.Id
        );

        Lead lead = new Lead(
            OwnerId = usuarios.get(1).Id,
            LastName = 'Raposo',
            Company = 'porao',
            Status = 'Novo',
            CanalAtendimento__c = 'Whatsapp',
            Email = 'e@gmail.com'
        );
        insert lead;

        List<ParticipanteRoleta__c> participantes = new List<ParticipanteRoleta__c>{participante};
        insert participantes;
    }

    @isTest
    static void testSortearNoCasoSemSorteiosAtivos() {
        
        Test.startTest();
        SortearParticipantesService.sortear();
        Test.stopTest();

        
    }

    @isTest
    static void testEmbaralharParticipantes() {
        
        List<ParticipanteRoleta__c> participantes =[Select Name, Id, Entrada__c, MembroEquipe__c, RoletaLeads__c from ParticipanteRoleta__c];

        Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoleta = new Map<Id, List<ParticipanteRoleta__c>>();
        Id roletaId = Id.valueOf('001000000000001'); 
        participantesPorIdRoleta.put(roletaId, participantes);

        Test.startTest();
      
        SortearParticipantesService.embaralharParticipantes(participantesPorIdRoleta);
        Test.stopTest();

        
    }

    @isTest
    static void sortearTest(){
        RoletaLeads__c roleta1 = [select id from RoletaLeads__c limit 1];
        Sorteio__c sorteio1 = new Sorteio__c(RoletaLeads__c = roleta1.Id);
        insert sorteio1;

        SortearParticipantesService.sortear(new List<Sorteio__c>{sorteio1});
    }
}