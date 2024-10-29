@IsTest
public class ParticipacaoRoletaServiceTest {

    // Método de configuração para criar dados de teste iniciais
    private static void setupTestData() {
        // Cria e insere usuários
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

           Equipe__c equipe1 = new Equipe__c(Name = 'Equipe 1' , CargaMaxima__c = 100);
        Equipe__c equipe2 = new Equipe__c(Name = 'Equipe 2' , CargaMaxima__c = 100);
        insert new List<Equipe__c>{equipe1, equipe2};

        MembroEquipe__c membro1 = new MembroEquipe__c( Name = 'Jéssica BM' , Equipe__c = equipe1.Id , Usuario__c = user1.Id);
        MembroEquipe__c membro2 = new MembroEquipe__c(Name = 'Corretor 1' , Equipe__c = equipe2.Id , Usuario__c = user2.Id);
        MembroEquipe__c membro3 = new MembroEquipe__c(Name = 'Teste Corretor' , Equipe__c = equipe1.Id , Usuario__c = user1.Id);
        insert new List<MembroEquipe__c>{membro1, membro2, membro3};

      RoletaLeads__c roletaLeads = new RoletaLeads__c(
            Name = 'Roleta - Equipe 0',
            Ativa__c = true,
            HoraInicio__c = Datetime.now().time(),
            CanaisAtendimento__c = 'WhatsApp',
            Equipe__c = equipe1.Id,
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );
        insert roletaLeads;

        Contact corretor1 = new Contact(
            FirstName = 'Pereira Lucas', 
            LastName = 'Silva',
            CPF__c = '10695957058'
        );
        insert corretor1;

        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            Name = 'Lucas' ,
            MembroEquipe__c = membro1.Id,
            RoletaLeads__c = roletaLeads.Id,
            Posicao__c = 1,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert participante;

        ParticipanteRoleta__c participante2 = 
        new ParticipanteRoleta__c(
            Name = 'Ewerton' ,
            MembroEquipe__c = membro1.Id,
            RoletaLeads__c = roletaLeads.Id,
            Posicao__c = 5,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert participante2;

        ParticipanteRoleta__c participante3 = 
        new ParticipanteRoleta__c(
            Name = 'Luan' ,
            MembroEquipe__c = membro2.Id,
            RoletaLeads__c = roletaLeads.Id,
            Posicao__c = 5,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert participante3;
    }


    @IsTest
    static void testeAtualizarSituacaoParticipante2() {
        setupTestData();
        Test.startTest();
        ParticipanteRoleta__c participante = [SELECT ID  , RegistroIndisponibilidade__c , RoletaLeads__c FROM ParticipanteRoleta__c  LIMIT 1];
        User usuario = [SELECT ID , Situacao__c FROM USER Where Situacao__c = 'Online' LIMIT 1];
    
        ParticipacaoRoletaService.atualizarSituacaoParticipante(participante, usuario);
    
        Test.stopTest();
    }

    @Istest 
    static void testeatualizarSituacaoParticipanteIndisponivel(){
        User user1 = new User(Alias = 'user1', Email = 'user1@test.com', 
            EmailEncodingKey = 'UTF-8', LastName = 'Test', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', ProfileId = UserInfo.getProfileId(), 
            TimeZoneSidKey = 'America/Los_Angeles', 
            CompanyName = 'You',
            Username = 'user1_' + System.currentTimeMillis() + '@test.com',
            Situacao__c = 'Indisponível');
                
      
        
        insert user1;

        Equipe__c equipe1 = new Equipe__c(Name = 'Equipe 1' , CargaMaxima__c = 100);
        Equipe__c equipe2 = new Equipe__c(Name = 'Equipe 2' , CargaMaxima__c = 100);
        insert new List<Equipe__c>{equipe1, equipe2};

        MembroEquipe__c membro1 = new MembroEquipe__c( Name = 'Jéssica BM' , Equipe__c = equipe1.Id , Usuario__c = user1.Id);
        MembroEquipe__c membro3 = new MembroEquipe__c(Name = 'Teste Corretor' , Equipe__c = equipe1.Id , Usuario__c = user1.Id);
        insert new List<MembroEquipe__c>{membro1, membro3};

      RoletaLeads__c roletaLeads = new RoletaLeads__c(
            Name = 'Roleta - Equipe 0',
            Ativa__c = true,
            HoraInicio__c = Datetime.now().time(),
            CanaisAtendimento__c = 'WhatsApp',
            Equipe__c = equipe1.Id,
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );
        insert roletaLeads;

        Contact corretor1 = new Contact(
            FirstName = 'Pereira Lucas', 
            LastName = 'Silva',
            CPF__c = '10695957058'
        );
        insert corretor1;

        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            Name = 'Lucas' ,
            MembroEquipe__c = membro1.Id,
            RoletaLeads__c = roletaLeads.Id,
            Posicao__c = 1,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert participante;
    }
    

    @IsTest
    static void testAtualizarSituacaoParticipanteOnline() {
        // Configura dados de teste
        setupTestData();
        
        // Consulta ParticipanteRoleta__c incluindo o campo RoletaLeads__c
        ParticipanteRoleta__c participante = [SELECT Id, Entrada__c, Saida__c, TempoIndisponibilidade__c, RegistroIndisponibilidade__c, RoletaLeads__c, MembroEquipe__r.Usuario__c FROM ParticipanteRoleta__c LIMIT 1];
        
        // Consulta o usuário e garante que o relacionamento está completo
        User usuario = [SELECT Id, Situacao__c FROM User LIMIT 1];
        
        // Define a situação como "Online"
        usuario.Situacao__c = 'Online';
        
        Test.startTest();
        // Atualiza a situação do participante
        participante = ParticipacaoRoletaService.atualizarSituacaoParticipante(participante, usuario);
        Test.stopTest();
        
        // Valida se os campos foram atualizados corretamente
        System.assertNotEquals(null, participante.Entrada__c, 'Entrada__c deveria ter sido preenchido.');
        System.assertEquals(null, participante.Saida__c, 'Saida__c deveria ser nulo.');
        System.assertEquals(null, participante.RegistroIndisponibilidade__c, 'RegistroIndisponibilidade__c deveria ser nulo.');
    }
    

    @IsTest
    static void testAtualizarSituacaoParticipanteIndisponivel() {
        setupTestData();
        
        ParticipanteRoleta__c participante = [SELECT Id, Entrada__c, Saida__c, Posicao__c,RoletaLeads__c, RegistroIndisponibilidade__c FROM ParticipanteRoleta__c LIMIT 1];
        User usuario = [SELECT Id, Situacao__c FROM User LIMIT 1];
        
        // Define a situação como "Indisponível"
        usuario.Situacao__c = 'Indisponível';
        
        Test.startTest();
        participante = ParticipacaoRoletaService.atualizarSituacaoParticipante(participante, usuario);
        Test.stopTest();
        
        // Valida os campos para "Indisponível"
        System.assertNotEquals(null, participante.RegistroIndisponibilidade__c, 'RegistroIndisponibilidade__c deveria ser preenchido.');
        System.assertEquals(null, participante.Posicao__c, 'Posicao__c deveria ser nulo.');
    }
    

      
    @IsTest
    static void testAtualizarSituacaoParticipanteOffline() {
        setupTestData();
        
        ParticipanteRoleta__c participante = [SELECT Id, Entrada__c, Saida__c, RegistroIndisponibilidade__c ,RoletaLeads__c , TempoIndisponibilidade__c FROM ParticipanteRoleta__c LIMIT 1];
        User usuario = [SELECT Id , Situacao__c FROM User LIMIT 1];
        
        // Define a situação como "Offline"
        usuario.Situacao__c = 'Offline';
        
        Test.startTest();
        participante = ParticipacaoRoletaService.atualizarSituacaoParticipante(participante, usuario);
        Test.stopTest();
    }

    // @isTest
    // static void testMudarStatusParticipanteRoleta() {
    //     // Configura os dados de teste
    //     setupTestData();
        
    //     // Busca o registro de ParticipanteRoleta criado anteriormente
    //     List<ParticipanteRoleta__c> participantes = [SELECT Id, UsuarioCorretor__c, RoletaLeads__c, RegistroIndisponibilidade__c, 
    //         MembroEquipe__r.Id, MembroEquipe__r.Usuario__r.Id, MembroEquipe__r.Usuario__r.Situacao__c 
    //         FROM ParticipanteRoleta__c LIMIT 1];
        
    //     // Verifica se a lista de participantes não está vazia
    //     System.assert(!participantes.isEmpty(), 'A lista de participantes não deve estar vazia.');
    
    //     // Chama o método para atualizar os participantes
    //     ParticipacaoRoletaService.atualizarParticipantes(participantes);
    
    //     // Verifica se a situação do membro da equipe foi alterada corretamente
    //     User usuarioCorretor = [SELECT Id, Situacao__c FROM User WHERE Id = :participantes[0].UsuarioCorretor__c LIMIT 1];
    //     System.assertEquals('Online', usuarioCorretor.Situacao__c, 'O status do usuário deveria ser Online.');
    // }
    
    

    @IsTest
    static void testSincronizarParticipantes() {
        setupTestData();

        // Obtenha usuários atualizados do banco
        List<User> usuarios = [SELECT Id, Situacao__c FROM User WHERE Situacao__c = 'Online' OR Situacao__c = 'Offline'];
        Map<Id, User> usuariosAntigosPorId = new Map<Id, User>(usuarios);

        Test.startTest();
        ParticipacaoRoletaService.sincronizarParticipantes(usuarios, usuariosAntigosPorId);
        Test.stopTest();

    }

    @IsTest
    static void testSincronizarParticipantesAsync() {
        setupTestData();

        // Obtenha IDs dos usuários para teste assíncrono
        Set<Id> idsUsuarios = new Set<Id>();
        for (User usr : [SELECT Id FROM User WHERE Situacao__c = 'Online']) {
            idsUsuarios.add(usr.Id);
        }

        Test.startTest();
        ParticipacaoRoletaService.sincronizarParticipantesAsync(idsUsuarios);
        Test.stopTest();

    }

    @IsTest
    static void testCriarParticipantes() {
        setupTestData();

        List<MembroEquipe__c> membros = [SELECT Id , Equipe__c FROM MembroEquipe__c];

        Test.startTest();
        ParticipacaoRoletaService.criarParticipantes(membros);
        Test.stopTest();

   }

    @IsTest
    static void testAtualizarParticipantes() {
        setupTestData();

        List<MembroEquipe__c> membros = [SELECT Id FROM MembroEquipe__c];
        List<Equipe__c> equipe = [SELECT Id FROM Equipe__c];
        List<RoletaLeads__c> roletas = [SELECT Id FROM RoletaLeads__c];
        // Cria participantes de teste com referência à equipe
        ParticipanteRoleta__c participante1 = new ParticipanteRoleta__c(
            MembroEquipe__c = membros[0].Id, 
            Posicao__c = 1,
            RoletaLeads__c = roletas[0].Id
        );
        insert participante1;

        Test.startTest();
        ParticipacaoRoletaService.atualizarParticipantes(membros);
        Test.stopTest();

     }
     @isTest
     static void testPegarUltimaPosicaoRoleta(){
        setupTestData();
        Test.startTest();
        
        // Obtém um participante existente
        ParticipanteRoleta__c participante = [SELECT ID, Posicao__c FROM ParticipanteRoleta__c LIMIT 1];
        List<ParticipanteRoleta__c> participantes = new List<ParticipanteRoleta__c>();
        participantes.add(participante);
        
        ParticipacaoRoletaService.PegarUltimaPosicaoRoleta(participantes);
    
        
        Test.stopTest();
     }

     @IsTest
     static void testesincronizarParticipantes() {
        setupTestData();

        // Obtenha IDs dos usuários para teste assíncrono
        Set<Id> idsUsuarios = new Set<Id>();
        for (User usr : [SELECT Id FROM User WHERE Situacao__c = 'Online']) {
            idsUsuarios.add(usr.Id);
        }

        Test.startTest();
         ParticipacaoRoletaService.sincronizarParticipantesAsync(idsUsuarios);
         Test.stopTest();

     }

     @IsTest
     static void testeatualizarSituacaoParticipante() {
            setupTestData();
    User usuarioOnline = [SELECT Id , Situacao__c FROM User WHERE Situacao__c = 'Online' LIMIT 1];
    ParticipanteRoleta__c participante = [SELECT Id , RegistroIndisponibilidade__c , RoletaLeads__c FROM ParticipanteRoleta__c LIMIT 1];

    Test.startTest();
    ParticipanteRoleta__c result = ParticipacaoRoletaService.atualizarSituacaoParticipante(participante, usuarioOnline);
    Test.stopTest();

     }
     @IsTest
     static void testOrdenarParticipantesOffline() {
         setupTestData();
     
         // Consultar participantes offline
         List<ParticipanteRoleta__c> participantesOffline = [SELECT Id, Name, Posicao__c,RoletaLeads__c, MembroEquipe__c, Participante_Vigente__c, 
             CargaRestante__c, Situacao__c, PausarDistribuicao__c, PresencaValidada__c
             FROM ParticipanteRoleta__c
             WHERE MembroEquipe__r.Usuario__r.Situacao__c = 'Offline'];
     
       
         ParticipanteRoleta__c participante = participantesOffline[0]; // Pega o primeiro participante offline
     
         Test.startTest();
         ParticipacaoRoletaService.OrdenarParticipantesOffline(participante);
         Test.stopTest();
     }
     

     @IsTest
     static void testObterTempoIndisponibilidadeEmMinutos() {
         // Configura os dados de teste
         setupTestData();
     
         // Verifique se o usuário offline está disponível
         List<ParticipanteRoleta__c> participantes = [SELECT Id, Posicao__c, RegistroIndisponibilidade__c, UsuarioCorretor__c, MembroEquipe__c, MembroEquipe__r.Equipe__c
             FROM ParticipanteRoleta__c
             WHERE MembroEquipe__r.Usuario__r.Situacao__c = 'Offline'
             LIMIT 1];
     
         // Adicione um debug para verificar a contagem de registros
         System.debug('Contagem de Participantes: ' + participantes.size());
         
        
         // Se um participante foi encontrado, atribua-o
         ParticipanteRoleta__c participante = participantes[0];
         participante.RegistroIndisponibilidade__c = System.now().addMinutes(-10); // Simulando 10 minutos de indisponibilidade
     
         Test.startTest();
         Integer tempoIndisponibilidade = ParticipacaoRoletaService.obterTempoIndisponibilidadeEmMinutos(participante);
         Test.stopTest();
     
         // Verifica se o tempo de indisponibilidade está correto
         System.assertEquals(10, tempoIndisponibilidade, 'O tempo de indisponibilidade deveria ser 10 minutos.');
     }

     @IsTest
     static void testObterTempoIndisponibilidadeEmMinutosComRegistroIndisponibilidade() {
         // Configura os dados de teste
         setupTestData();
     
         // Verifique se o usuário offline está disponível
         List<ParticipanteRoleta__c> participantes = [SELECT Id, Posicao__c, RegistroIndisponibilidade__c, UsuarioCorretor__c, MembroEquipe__c, MembroEquipe__r.Equipe__c
             FROM ParticipanteRoleta__c
             WHERE MembroEquipe__r.Usuario__r.Situacao__c = 'Offline'
             LIMIT 1];
     
         // Adicione um debug para verificar a contagem de registros
         System.debug('Contagem de Participantes: ' + participantes.size());
     
       
         // Se um participante foi encontrado, atribua-o
         ParticipanteRoleta__c participante = participantes[0];
         participante.RegistroIndisponibilidade__c = System.now().addMinutes(-30); // Simulando 30 minutos de indisponibilidade
     
         Test.startTest();
         Integer tempoIndisponibilidade = ParticipacaoRoletaService.obterTempoIndisponibilidadeEmMinutos(participante);
         Test.stopTest();
     
         // Verifica se o tempo de indisponibilidade está correto
         System.assertEquals(30, tempoIndisponibilidade, 'O tempo de indisponibilidade deveria ser 30 minutos.');
     }
     
     @isTest
     static void testordenarPosicoes(){
        setupTestData();
        Test.startTest();
        
        // Obtém um participante existente
        ParticipanteRoleta__c participante = [SELECT ID, Posicao__c FROM ParticipanteRoleta__c LIMIT 1];
        List<ParticipanteRoleta__c> participantes = new List<ParticipanteRoleta__c>();
        participantes.add(participante);
        ParticipacaoRoletaService.ordenarPosicoes(participantes);
        Test.stopTest();    
     }

     @IsTest
static void testeObterNovoParticipante() {
    // Configura os dados de teste
    setupTestData();
    Test.startTest();

    // Obtém um membro da equipe
    MembroEquipe__c membro = [SELECT Id, Usuario__r.Name, Usuario__r.Situacao__c FROM MembroEquipe__c LIMIT 1];
    
    // Obtém uma roleta existente
    RoletaLeads__c roletaLeads = [SELECT Id FROM RoletaLeads__c LIMIT 1];

    // Cria uma lista de participantes existentes
    List<ParticipanteRoleta__c> participantesExistentes = [
        SELECT Id , Posicao__c FROM ParticipanteRoleta__c WHERE RoletaLeads__c = :roletaLeads.Id
    ];

    // Chama o método a ser testado
    ParticipanteRoleta__c novoParticipante = ParticipacaoRoletaService.obterNovoParticipante(membro, roletaLeads.Id, participantesExistentes);

    Test.stopTest();
}
@IsTest
static void testeObterTempoIndisponibilidadeEmMinutos2() {
    Test.startTest();

    // 1. Caso em que RegistroIndisponibilidade__c é null
    ParticipanteRoleta__c participanteSemIndisponibilidade = new ParticipanteRoleta__c();
    Integer tempoIndisponibilidade = ParticipacaoRoletaService.obterTempoIndisponibilidadeEmMinutos(participanteSemIndisponibilidade);
    
    // Verifica que o tempo de indisponibilidade deve ser nulo
    System.assertEquals(null, tempoIndisponibilidade, 'Quando RegistroIndisponibilidade__c é null, o tempo de indisponibilidade deve ser nulo.');

    // 2. Caso em que RegistroIndisponibilidade__c contém um valor
    // Simula um registro de indisponibilidade em um tempo anterior
    DateTime dataIndisponibilidade = System.now().addMinutes(-30); // 30 minutos atrás
    ParticipanteRoleta__c participanteComIndisponibilidade = new ParticipanteRoleta__c(
        RegistroIndisponibilidade__c = dataIndisponibilidade
    );
    
    // Chama o método e verifica o tempo de indisponibilidade
    tempoIndisponibilidade = ParticipacaoRoletaService.obterTempoIndisponibilidadeEmMinutos(participanteComIndisponibilidade);
    
    // Verifica que o tempo de indisponibilidade deve ser de 30 minutos
    System.assertEquals(30, tempoIndisponibilidade, 'O tempo de indisponibilidade deve ser de 30 minutos.');

    Test.stopTest();
}

@isTest
static void testOrdenarPosicoesParticipantesRoletas() {
    // Configurar dados de teste
    setupTestData();

    // Recuperar a roleta que foi criada na configuração de teste
    RoletaLeads__c roleta = [SELECT Id FROM RoletaLeads__c WHERE Name = 'Roleta - Equipe 0' LIMIT 1];

    // Recuperar participantes da roleta
    List<ParticipanteRoleta__c> participantes = [SELECT Id, Posicao__c FROM ParticipanteRoleta__c WHERE RoletaLeads__c = :roleta.Id];

    // Modificar posições para teste
    if (!participantes.isEmpty()) {
        // Atribuir posições desordenadas para verificar a ordenação
        participantes[0].Posicao__c = 3;
        participantes[1].Posicao__c = 1;
        participantes[2].Posicao__c = 2;

        // Atualizar participantes na base
        update participantes;
    }

    // Chamar o método a ser testado
    ParticipacaoRoletaService.ordenarPosicoesParticipantesRoletas(roleta.Id, participantes);

  
}

@isTest
static void testCriarParticipantes2() {
    // Configurar dados de teste
    setupTestData();

    Test.startTest();
    // Obter membros da equipe
    List<MembroEquipe__c> membros = [SELECT Id , Usuario__r.id , Usuario__r.name  , Usuario__r.Situacao__c FROM MembroEquipe__c];

    // Criar um mapa de roletas por membro
    Map<Id, List<RoletaLeads__c>> roletasPorIdMembroParaCriar = new Map<Id, List<RoletaLeads__c>>();
    
    // Supondo que você tenha duas roletas na configuração
    List<RoletaLeads__c> roletas = [SELECT Id FROM RoletaLeads__c];
    
    for (MembroEquipe__c membro : membros) {
        roletasPorIdMembroParaCriar.put(membro.Id, roletas);
    }

    // Chamar o método a ser testado
    ParticipacaoRoletaService.criarParticipantes(membros, roletasPorIdMembroParaCriar);

    Test.stopTest();

    
}

}