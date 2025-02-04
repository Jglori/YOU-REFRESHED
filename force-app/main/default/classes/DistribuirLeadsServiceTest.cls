@isTest
private class DistribuirLeadsServiceTest {
    private static final String ALIAS_USUARIO_1 = 'standt';
    private static final String ALIAS_USUARIO_2 = 'teste';
    private static final String EMAIL_USUARIO_1 = 'standarduser@testorg.com';
    private static final String EMAIL_USUARIO_2 = 'teste@testorg.com';
    private static final String LAST_NAME_USUARIO_1 = 'Testing';
    private static final String LAST_NAME_USUARIO_2 = 'Testing1';
    private static final String USERNAME_USUARIO_1 = 'ksaoidsjadosajoidasjiokdaso@rsis.com';
    private static final String USERNAME_USUARIO_2 = 'a28301@rsis.com';

    @TestSetup
    static void makeData() {
        //TriggerHandler.bypass('LeadTriggerHandler');

        RecordType recordTypeCorretor = [SELECT Id, Name FROM RecordType WHERE Name = 'Corretor' LIMIT 1];

        Id perfilAdministradorSistema = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator'].id;
		
        Contact ctt = new Contact(LastName = 'jorge',DatadeVencimento__c = Date.Today() , Cpf__c = '18875199043' , RecordTypeId = recordTypeCorretor.Id);
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
                Name = 'Equipe a' ,
                Equipe__c = equipe.Id,
                Usuario__c = usuarios.get(0).Id
            ),
            new MembroEquipe__c(
                Name = 'Equipe b' ,
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
        insert participante;

        Lead lead = new Lead(
            OwnerId = usuarios.get(1).Id,
            LastName = 'Raposo',
            Company = 'porao',
            Status = 'Novo',
            CanalAtendimento__c = 'Whatsapp',
            Email = 'e@gmail.com'
        );
        insert lead;
    }

    @isTest
    static void testarDistribuirLeads() {
        Lead lead = [SELECT CanalAtendimento__c, RoletaLeads__c, Corretor__c FROM Lead LIMIT 1];

        DistribuirLeadsService.distribuirLeads(new List<Lead>{ lead });
        
        User usuario = [SELECT Id FROM User WHERE Username = 'ksaoidsjadosajoidasjiokdaso@rsis.com'];
        
        
        List<ParticipanteRoleta__c> participantes = [Select id,Situacao__c,RoletaLeads__c,CargaRestante__c,PausarDistribuicao__c,MembroEquipe__r.ExigeValidacaoCoordenador__c,PresencaValidada__c,MembroEquipe__r.Usuario__r.CanaisAtendimento__c from ParticipanteRoleta__c];
        List<RoletaLeads__c> roleta = [Select id,CanaisAtendimento__c from RoletaLeads__c];
        
        DistribuirLeadsService.obterParticipantesOnline(participantes);
        DistribuirLeadsService.distribuirLeadsAsync(new Set<Id>{lead.Id});
        DistribuirLeadsService.reordenarParticipantesRoletasLeads(participantes);
        DistribuirLeadsService.distribuirLeadsComRoleta(new List<Lead>{lead}, roleta);
        DistribuirLeadsService.distribuirLeads(new List<Lead>{lead}, roleta);
        DistribuirLeadsService.distribuirLeads(participantes);
        DistribuirLeadsService.distribuirLeadEntreParticipantes(lead, roleta[0]);
        DistribuirLeadsService.obterLeadsParaDistribuir(new List<Lead>{lead});

        DistribuirLeadsService.notifyUsers(new Set<String>{usuario.Id}, lead.Id);

        LeadSelector.obterLeadsParaDistribuir(); 
        LeadSelector.obterLeadsPorIdsProprietarios(new Set<Id>{usuario.Id}); 
        LeadSelector.obterLeadsPorIdsUsuarios(new Set<Id>{usuario.Id}); 
        LeadSelector.obterLeadsPorIds(new Set<Id>{lead.Id}); 
        LeadSelector.obterLeadsPorChavesExternasClientes(new Set<String>{'199931148623'});
        LeadSelector.obterLeadsPorInformacoesConcierge('raposo', '', 'e@gmail.com'); 
        LeadSelector.obterLeadsPorInformacoesConcierge('', 'e@gmail.com', false, ''); 
        LeadSelector.obterInfosTemplatePadrao(lead.Id); 
        
        RoletaLeadsSelector.obterRoletasLeadsPorIdsMembros(new Set<Id>{usuario.Id});
        RoletaLeadsSelector.obterRoletasLeadsPorIdsUsuarios(new Set<Id>{usuario.Id});
        RoletaLeadsSelector.obterRoletasLeadsVigentes();
        
        
        ParticipanteRoletaDomain.obterParticipantesPorIdMembro(participantes);
        ParticipanteRoletaDomain.obterParticipantesPorIdRoleta(participantes);
        
        ParticipanteRoletaSelector.obterParticipantesPorIdsMembros(new Set<Id>{usuario.Id});
        ParticipanteRoletaSelector.obterParticipantesPorUserID(usuario.Id);
        ParticipanteRoletaSelector.obterParticipantesPorIdsRoleta(new Set<Id>{roleta[0].Id});
        
        MembroEquipeSelector.obterMembrosPorId(new Set<Id>{lead.Id});

        // Assert.areEqual(lead.Corretor__c, usuario.Id, 'Lead distribuído corretamente');
    }

    // @isTest
    // static void canalConfiguradoTest() {
    //     Test.startTest();
    //     Lead lead = [SELECT CanalAtendimento__c FROM Lead WHERE CanalAtendimento__c = 'Whatsapp' LIMIT 1];
    //     ParticipanteRoleta__c participante = [SELECT MembroEquipe__r.Usuario__r.CanaisAtendimento__c FROM ParticipanteRoleta__c LIMIT 1];

    //     Boolean resultado = DistribuirLeadsService.canalConfigurado(lead, participante);
        
       
    //     participante.MembroEquipe__r.Usuario__r.CanaisAtendimento__c = 'Telegram';  // Mudando para outro canal
    //     update participante;
        
    //     resultado = DistribuirLeadsService.canalConfigurado(lead, participante);

    //     Test.stopTest();
        
    //  }
    

     @isTest 
     static void canalBypassTest(){
        Lead lead = [SELECT Id  , CanalAtendimento__c FROM Lead LIMIT 1];

        DistribuirLeadsService.canalBypass(lead);
     }

    //  @isTest 
    //  static void possuiCapacidadeAtendimentoTest(){
    //     Lead lead = [SELECT Id ,CanalAtendimento__c FROM Lead LIMIT 1];
        
    //     ParticipanteRoleta__c participantes = [SELECT Id , CargaRestante__c FROM ParticipanteRoleta__c LIMIT 1];

    //     DistribuirLeadsService.possuiCapacidadeAtendimento(lead , participantes);
    
    //  }

     @isTest
     static void distribuirLeadTest(){
         // Busca o primeiro Lead na base
         Lead lead = [SELECT Id FROM Lead LIMIT 1];
     
         // Busca o primeiro Contact com o RecordType 'Corretor'
         Id corretor = [SELECT Id FROM Contact WHERE RecordType.Name = 'Corretor' LIMIT 1].Id;
     
         // Busca a primeira RoletaLeads__c
         Id listaRoletas = [SELECT Id FROM RoletaLeads__c LIMIT 1].Id;
     
         // Chama o método distribuirLead passando os IDs corretamente
         DistribuirLeadsService.distribuirLead(lead, corretor, listaRoletas);
     }

     //  distribuirLeadEntreParticipantes(Lead lead, RoletaLeads__c roletaLeads)

     @isTest
static void distribuirLeadEntreParticipantesTest() {
    // Obtém um lead de teste
    Lead lead = [SELECT Id , CanalAtendimento__c FROM Lead LIMIT 1];
    
    // Consulta a roleta incluindo os campos necessários do objeto User
    RoletaLeads__c roleta = [
        SELECT Id,
               (SELECT Id, MembroEquipe__r.Id, MembroEquipe__r.Usuario__r.Id, MembroEquipe__r.Usuario__r.CanaisAtendimento__c 
                FROM ParticipantesRoleta__r)
        FROM RoletaLeads__c
        LIMIT 1
    ];

    // Chama o serviço para distribuir o lead entre os participantes
    Map<Id, List<ParticipanteRoleta__c>> result = DistribuirLeadsService.distribuirLeadEntreParticipantes(lead, roleta);
    
}
@isTest 
static void testReordenarParticipantesRoletasLeads() {
    // Realizando consultas para buscar as roletas e participantes já existentes
    List<RoletaLeads__c> roletas = [SELECT Id FROM RoletaLeads__c LIMIT 2];
    List<ParticipanteRoleta__c> participantes = [SELECT Id, RoletaLeads__c FROM ParticipanteRoleta__c WHERE RoletaLeads__c IN :roletas];

    Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoleta = new Map<Id, List<ParticipanteRoleta__c>>();
    
    for (ParticipanteRoleta__c participante : participantes) {
        if (!participantesPorIdRoleta.containsKey(participante.RoletaLeads__c)) {
            participantesPorIdRoleta.put(participante.RoletaLeads__c, new List<ParticipanteRoleta__c>());
        }
        participantesPorIdRoleta.get(participante.RoletaLeads__c).add(participante);
    }

    List<ParticipanteRoleta__c> participantesReordenados = DistribuirLeadsService.reordenarParticipantesRoletasLeads(participantesPorIdRoleta);

  
}

     
     
     
}