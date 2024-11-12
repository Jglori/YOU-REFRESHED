@isTest
public class OmnichannelServiceTest {

    @TestSetup
    static void setupTestData() {
        // Criação de um Empreendimento de exemplo com CNPJ
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste empreendimento',
            CNPJEmpreendimento__c = '91529585000197' // Adicione um CNPJ válido
        );
        insert empreendimento;
    
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator' LIMIT 1];
        

        Contact corretor1 = new Contact(
            FirstName = 'Carlos', 
            LastName = 'Silva',
            CPF__c = '84057287248'
        );
        insert corretor1;


        User usuarioCorretor = new User(
          LastName = 'LIVESTON',
          FirstName='JASON',
          Username = 'jasonl@gmail.com',
          Alias = 'jliv',
          Email = 'john@acme.com',
          ProfileId = adminProfile.Id,
          TimeZoneSidKey = 'GMT',
          LanguageLocaleKey = 'en_US',
          EmailEncodingKey = 'UTF-8',
          LocaleSidKey = 'en_US'
        );
    
        insert usuarioCorretor;

        


    
        // Criação de um Roleta Leads
        RoletaLeads__c roleta1 = new RoletaLeads__c(
            Name = 'Roleta You - Corretores novo',
            CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone;Loja;Stand',
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira'
        );
        insert roleta1;
    
        // Criar uma equipe
        Equipe__c eq = new Equipe__c(Name = 'eq' , CargaMaxima__c = 3.00);
        insert eq;


    
        // Criação de um Membro de Equipe
        MembroEquipe__c membro = new MembroEquipe__c(Name = 'Membro Teste', Equipe__c = eq.Id , Usuario__c = usuarioCorretor.Id);
        insert membro;

        
    
       
    
        // Criação de um Participante Roleta
        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            MembroEquipe__c = membro.Id,
            RoletaLeads__c = roleta1.Id,
            Posicao__c = 1,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert participante;

        Lead testLead = new Lead(
            LastName = 'Silva',
            FirstName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'silva@xyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Fale conosco',
            MobilePhone = '5511987654321',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id,
            OwnerId = usuarioCorretor.Id,
            corretorContato__c = corretor1.Id,
            Corretor__c = participante.Id 
        );
        insert testLead;
    }
    

    @IsTest
    static void testSelecionarCanais() {
        List<String> canaisAtendimento = new List<String>{'Fale conosco;Chat;WhatsApp;Telefone;Loja;Stand'};
        String result = OmnichannelService.selecionarCanais(canaisAtendimento);
        System.assertNotEquals(null, result, 'A seleção de canais não retornou um resultado válido.');
    }

    

    @IsTest
    static void testRejeitarLead() {
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        System.debug('Lead: ' + testLead);
        String result = OmnichannelService.rejeitarLead(testLead.Id);
        System.assertNotEquals(null, result, 'A rejeição do lead não retornou um resultado válido.');
    }

    @IsTest
    static void testAlterarSituacao() {
        String novaSituacao = 'Online';
        String result = OmnichannelService.alterarSituacao(novaSituacao);
        System.assertNotEquals(null, result, 'A alteração de situação não retornou um resultado válido.');
    }
    
    @IsTest
    static void testAlterarSituacaog() {
        String novaSituacao = 'Indisponível';
        String result = OmnichannelService.alterarSituacao(novaSituacao);
        System.assertNotEquals(null, result, 'A alteração de situação não retornou um resultado válido.');
    }
    
     @IsTest
    static void testAlterarSituacaoOffline() {
        String novaSituacao = 'Offline';
        String result = OmnichannelService.alterarSituacao(novaSituacao);
        System.assertNotEquals(null, result, 'A alteração de situação não retornou um resultado válido.');
    }
    @isTest
    static void UsuarioOffline(){
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator' LIMIT 1];
        
        User testUser = new User(
            FirstName = 'Dantas',
            LastName = 'Will',
            Alias = 'wdantas',
            Email = 'wdantas@example.com',
            Username = 'wdantas@test.com' + System.currentTimeMillis(), // Para garantir unicidade
            ProfileId = adminProfile.Id, // Usar o ProfileId do Administrador do sistema
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/New_York',
            LanguageLocaleKey = 'pt_BR',
            Situacao__c = '' // Inicialmente em branco
        );
        insert testUser;

        String result = OmnichannelService.alterarSituacao('Offline');
    }

    @IsTest
    static void testObterLeadsEmTrabalho() {
        String result = OmnichannelService.obterLeadsEmTrabalho();
        System.assertNotEquals(null, result, 'A obtenção de leads em trabalho não retornou um resultado válido.');
    }

    @IsTest
    static void testObterLeadsEmNovo() {
        String result = OmnichannelService.obterLeadsEmNovo();
        System.assertNotEquals(null, result, 'A obtenção de leads em novo não retornou um resultado válido.');
    }

    @IsTest
    static void testObterUsuario() {
        String result = OmnichannelService.obterUsuario();
        System.assertNotEquals(null, result, 'A obtenção do usuário não retornou um resultado válido.');
    }

    @IsTest
    static void testObterSituacoes() {
        Map<String, String> result = OmnichannelService.obterSituacoes();
        System.assertNotEquals(null, result, 'A obtenção das situações não retornou um resultado válido.');
        System.assert(!result.isEmpty(), 'As situações obtidas estão vazias.');
    }

    @IsTest
    static void testDefinirStatusInicial() {
        String result = OmnichannelService.definirStatusInicial();
        System.assertNotEquals(null, result, 'A definição de status inicial não retornou um resultado válido.');
    }

    @IsTest
    static void testObterCanaisAtendimento() {
        Map<String, String> result = OmnichannelService.obterCanaisAtendimento();
        Test.startTest();
    }
    @isTest
    static void testAceitarLead() {
        Test.startTest();
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        String result = OmnichannelService.aceitarLead(testLead.Id);  
        Test.stopTest();
        
    }
    @isTest
    static void testAceitarChat(){

        
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator' LIMIT 1];
        
        Contact corretor1 = new Contact(
            FirstName = 'Pereira Lucas', 
            LastName = 'Silva',
            CPF__c = '10695957058'
        );
        insert corretor1;
        
         
        User testUser = new User(
          LastName = 'Luis',
          FirstName='Santos',
          Username = 'lusi@gmail.com',
          Alias = 'lusi',
          Email = 'lusis@acme.com',
          ProfileId = adminProfile.id,
          TimeZoneSidKey = 'GMT',
          LanguageLocaleKey = 'en_US',
          EmailEncodingKey = 'UTF-8',
          LocaleSidKey = 'en_US'
        );

        insert testUser;


          // Criação de um Roleta Leads
          RoletaLeads__c roleta1 = new RoletaLeads__c(
            Name = 'Roleta You - Corretores novo',
            CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone;Loja;Stand',
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira'
        );
        insert roleta1;
    
        // Criar uma equipe
        Equipe__c eq = new Equipe__c(Name = 'lucas' , CargaMaxima__c = 10.00);
        insert eq;


    
        // Criação de um Membro de Equipe
        MembroEquipe__c membro = new MembroEquipe__c(Name = 'Membro Pleno', Equipe__c = eq.Id , Usuario__c = testUser.Id);
        insert membro;

        
    
       
    
        // Criação de um Participante Roleta
        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            MembroEquipe__c = membro.Id,
            RoletaLeads__c = roleta1.Id,
            Posicao__c = 1,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert participante;



        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste empreendimento',
            CNPJEmpreendimento__c = '91529585000197' // Adicione um CNPJ válido
        );
        insert empreendimento;

        Lead leadNovo = new Lead(
            LastName = 'Silva',
            FirstName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'silva@xyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '5511987654321',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id,
            OwnerId = testUser.Id,
            corretorContato__c = corretor1.Id,
            Corretor__c = participante.Id 
        );
        insert leadNovo;

        String result = OmnichannelService.aceitarLead(leadNovo.Id);     
    }
       @IsTest
    static void chatter() {
       Lead testLead = [SELECT Id FROM Lead LIMIT 1];
       User user = [SELECT Id FROM User LIMIT 1];
        OmnichannelService.notificarPeloChatter( testLead.Id , user.Id );
    }
 
    @isTest
    static void testAceitarWhatsapp(){

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator' LIMIT 1];
        
        Contact corretor1 = new Contact(
            FirstName = 'Lucas', 
            LastName = 'Vinicius',
            CPF__c = '19200652026'
        );
        insert corretor1;
        
         
        User testUser = new User(
          LastName = 'luan',
          FirstName='oliver',
          Username = 'luanoliver@gmail.com',
          Alias = 'ldndj',
          Email = 'ljddj@acme.com',
          ProfileId = adminProfile.id,
          TimeZoneSidKey = 'GMT',
          LanguageLocaleKey = 'en_US',
          EmailEncodingKey = 'UTF-8',
          LocaleSidKey = 'en_US'
        );

        insert testUser;


          // Criação de um Roleta Leads
          RoletaLeads__c roleta1 = new RoletaLeads__c(
            Name = 'Roleta You - Corretores novo',
            CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone;Loja;Stand',
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira'
        );
        insert roleta1;
    
        // Criar uma equipe
        Equipe__c eq = new Equipe__c(Name = 'lucas' , CargaMaxima__c = 10.00);
        insert eq;


    
        // Criação de um Membro de Equipe
        MembroEquipe__c membro = new MembroEquipe__c(Name = 'Membro Pleno', Equipe__c = eq.Id , Usuario__c = testUser.Id);
        insert membro;

        
    
       
    
        // Criação de um Participante Roleta
        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            MembroEquipe__c = membro.Id,
            RoletaLeads__c = roleta1.Id,
            Posicao__c = 1,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert participante;

        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste empreendimento',
            CNPJEmpreendimento__c = '91529585000197' // Adicione um CNPJ válido
        );
        insert empreendimento;

        Lead leadNovo = new Lead(
            LastName = 'Silva',
            FirstName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'silva@xyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Whatsapp',
            MobilePhone = '5511987654321',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id,
            OwnerId = testUser.Id,
            corretorContato__c = corretor1.Id,
            Corretor__c = participante.Id 
        );
        insert leadNovo;

        String result = OmnichannelService.aceitarLead(leadNovo.Id);     
    }
    
    @isTest
    static void testAceitarTelefone(){
      
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator' LIMIT 1];
        
        Contact corretor1 = new Contact(
            FirstName = 'Jose', 
            LastName = 'Matheus',
            CPF__c = '90913079006'
        );
        insert corretor1;
        
         
        User testUser = new User(
            FirstName = 'Yasmin',
            LastName = 'Gabrille',
            Alias = 'ygabri',
            Email = 'yasmingabrille@example.com',
            Username = 'ygabrielle@test.com',
            ProfileId = adminProfile.Id,
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/New_York',
            LanguageLocaleKey = 'pt_BR',
            Situacao__c = 'Online',
            CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone;Loja;Stand'
        );


        insert testUser;


          RoletaLeads__c roleta1 = new RoletaLeads__c(
            Name = 'Roleta You - Corretores novo',
            CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone;Loja;Stand',
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira'
        );
        insert roleta1;
    
        Equipe__c eq = new Equipe__c(Name = 'Pedrao' , CargaMaxima__c = 10.00);
        insert eq;


    
        // Criação de um Membro de Equipe
        MembroEquipe__c membro = new MembroEquipe__c(Name = 'Membro senior', Equipe__c = eq.Id , Usuario__c = testUser.Id);
        insert membro;


        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            MembroEquipe__c = membro.Id,
            RoletaLeads__c = roleta1.Id,
            Posicao__c = 1,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert participante;

        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste empreendimento',
            CNPJEmpreendimento__c = '91529585000197' // Adicione um CNPJ válido
        );
        insert empreendimento;

        Lead leadNovo = new Lead(
            LastName = 'Silva',
            FirstName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'silva@xyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '5511987654321',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id,
            OwnerId = testUser.Id,
            corretorContato__c = corretor1.Id,
            Corretor__c = participante.Id 
        );
        insert leadNovo;

        String result = OmnichannelService.aceitarLead(leadNovo.Id);     
    }

    @isTest
    static void testAceitarLoja(){

     
        
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator' LIMIT 1];
        
        Contact corretor1 = new Contact(
            FirstName = 'Jose', 
            LastName = 'Matheus',
            CPF__c = '90913079006'
        );
        insert corretor1;
        
         
        User testUser = new User(
            FirstName = 'Yasmin',
            LastName = 'Gabrille',
            Alias = 'ygabri',
            Email = 'yasmingabrille@example.com',
            Username = 'ygabrielle@test.com',
            ProfileId = adminProfile.Id,
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/New_York',
            LanguageLocaleKey = 'pt_BR',
            Situacao__c = 'Online',
            CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone;Loja;Stand'
        );


        insert testUser;


          RoletaLeads__c roleta1 = new RoletaLeads__c(
            Name = 'Roleta You - Corretores novo',
            CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone;Loja;Stand',
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira'
        );
        insert roleta1;
    
        Equipe__c eq = new Equipe__c(Name = 'Pedrao' , CargaMaxima__c = 10.00);
        insert eq;


    
        // Criação de um Membro de Equipe
        MembroEquipe__c membro = new MembroEquipe__c(Name = 'Membro senior', Equipe__c = eq.Id , Usuario__c = testUser.Id);
        insert membro;


        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            MembroEquipe__c = membro.Id,
            RoletaLeads__c = roleta1.Id,
            Posicao__c = 1,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert participante;

        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste empreendimento',
            CNPJEmpreendimento__c = '91529585000197' // Adicione um CNPJ válido
        );
        insert empreendimento;

        Lead leadNovo = new Lead(
            LastName = 'Silva',
            FirstName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'silva@xyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Loja',
            MobilePhone = '5511987654321',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id,
            OwnerId = testUser.Id,
            corretorContato__c = corretor1.Id,
            Corretor__c = participante.Id 
        );
        insert leadNovo;

        String result = OmnichannelService.aceitarLead(leadNovo.Id);     
    }

    @isTest
    static void testAceitarStand(){

        
        
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator' LIMIT 1];
        
        Contact corretor1 = new Contact(
            FirstName = 'Jose', 
            LastName = 'Matheus',
            CPF__c = '90913079006'
        );
        insert corretor1;
        
         
        User testUser = new User(
            FirstName = 'Yasmin',
            LastName = 'Gabrille',
            Alias = 'ygabri',
            Email = 'yasmingabrille@example.com',
            Username = 'ygabrielle@test.com',
            ProfileId = adminProfile.Id,
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/New_York',
            LanguageLocaleKey = 'pt_BR',
            Situacao__c = 'Online',
            CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone;Loja;Stand'
        );


        insert testUser;


          RoletaLeads__c roleta1 = new RoletaLeads__c(
            Name = 'Roleta You - Corretores novo',
            CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone;Loja;Stand',
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira'
        );
        insert roleta1;
    
        Equipe__c eq = new Equipe__c(Name = 'Pedrao' , CargaMaxima__c = 10.00);
        insert eq;


    
        // Criação de um Membro de Equipe
        MembroEquipe__c membro = new MembroEquipe__c(Name = 'Membro senior', Equipe__c = eq.Id , Usuario__c = testUser.Id);
        insert membro;


        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            MembroEquipe__c = membro.Id,
            RoletaLeads__c = roleta1.Id,
            Posicao__c = 1,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert participante;

        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste empreendimento',
            CNPJEmpreendimento__c = '91529585000197' // Adicione um CNPJ válido
        );
        insert empreendimento;

        Lead leadNovo = new Lead(
            LastName = 'Silva',
            FirstName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'silva@xyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Stand',
            MobilePhone = '5511987654321',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id,
            OwnerId = testUser.Id,
            corretorContato__c = corretor1.Id,
            Corretor__c = participante.Id 
        );
        insert leadNovo;

        String result = OmnichannelService.aceitarLead(leadNovo.Id);     
    }


  
}