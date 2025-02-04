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
            LastName = 'Lead silva',
            FirstName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'leadsilvana332@gmail.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Fale conosco',
            MobilePhone = '5519987654109',
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
        // Configuração de dados de teste
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste empreendimento',
            CNPJEmpreendimento__c = '91529585000197'
        );
        insert empreendimento;
    
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
    
        Contact corretor1 = new Contact(
            FirstName = 'Gustavo',
            LastName = 'Da Silva',
            CPF__c = '84057287248'
        );
        insert corretor1;
    
        User usuarioCorretor = new User(
            LastName = 'LIVESTONG',
            FirstName = 'JASONL',
            Username = 'jason' + System.currentTimeMillis() + '@gmail.com',
            Alias = 'jlivb',
            Email = 'john@acmes.com',
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            Situacao__c = 'Online'
        );
        insert usuarioCorretor;
    
        RoletaLeads__c roleta1 = new RoletaLeads__c(
            Name = 'Roleta Teste',
            CanaisAtendimento__c = 'Fale conosco;Chat',
            DiasSemana__c = 'Segunda-feira;Terça-feira'
        );
        insert roleta1;
    
        Equipe__c equipe = new Equipe__c(
            Name = 'Equipe Teste',
            CargaMaxima__c = 5.0
        );
        insert equipe;
    
        MembroEquipe__c membroEquipe = new MembroEquipe__c(
            Name = 'Membro Teste',
            Equipe__c = equipe.Id,
            Usuario__c = usuarioCorretor.Id
        );
        insert membroEquipe;
    
        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            MembroEquipe__c = membroEquipe.Id,
            RoletaLeads__c = roleta1.Id,
            Posicao__c = 1
        );
        insert participante;
    
        Lead testLead = new Lead(
            LastName = 'Ferreira',
            FirstName = 'Da Silva',
            Company = 'Empresa Teste',
            Email = 'silva@teste.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Fale conosco',
            MobilePhone = '5511987654323',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id,
            RoletaLeads__c = roleta1.Id,
            OwnerId = usuarioCorretor.Id,
            Corretor__c = participante.Id
        );
        insert testLead;
    
        Test.startTest();
        String result = OmnichannelService.rejeitarLead(testLead.Id);
        Test.stopTest();
    
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo.');
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
    // Criar um contato de teste
    Contact testContact = new Contact(
        FirstName = 'Contato',
        LastName = 'Teste',
        Email = 'contato.teste@example.com'
    );
    insert testContact;
    
    // Criação de um perfil
    Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

    // Criar um usuário de teste
    User testUser = new User(
        FirstName = 'Gabriel',
        LastName = 'Lima',
        Alias = 'gab',
        Email = 'gab@example.com',
        Username = 'gab@test.com' + System.currentTimeMillis(),
        ProfileId = adminProfile.Id,
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        TimeZoneSidKey = 'America/New_York',
        LanguageLocaleKey = 'pt_BR',
        Situacao__c = 'Online'
    );
    insert testUser;

    // Criar um único Lead de teste
    Lead testLead = new Lead(
        FirstName = 'Lead1',
        LastName = 'Teste',
        Company = 'Empresa 1',
        Email = 'lead1@empresa.com',
        Phone = '1234567890',
        MobilePhone = '9876543210',
        Status = 'Novo',
        CanalAtendimento__c = 'Fale conosco',
        CorretorContato__c = testContact.Id,
        OwnerId = UserInfo.getUserId()
    );
    insert testLead;

    // Rodar como o usuário de teste
    System.runAs(testUser) {
        Test.startTest();
        String result = OmnichannelService.obterLeadsEmNovo();
        Test.stopTest();

        // Validar o resultado
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo.');
        List<LeadDTO> leadsDTO = (List<LeadDTO>) JSON.deserialize(result, List<LeadDTO>.class);
    }
}

    @IsTest
    static void testObterUsuario() {
        
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator' LIMIT 1];
        
        User testUser = new User(
            FirstName = 'Gabriel',
            LastName = 'Lima',
            Alias = 'gab',
            Email = 'gab@example.com',
            Username = 'gab@test.com' + System.currentTimeMillis(), // Para garantir unicidade
            ProfileId = adminProfile.Id, // Usar o ProfileId do Administrador do sistema
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/New_York',
            LanguageLocaleKey = 'pt_BR',
            Situacao__c = ' '
        );
        insert testUser;
        
        System.runAs(testUser) {
            String result = OmnichannelService.obterUsuario();
            System.assertNotEquals(null, result, 'A obtenção do usuário não retornou um resultado válido.');
        }
    }

    @IsTest
    static void testObterSituacoes() {
        Map<String, String> result = OmnichannelService.obterSituacoes();
        System.assertNotEquals(null, result, 'A obtenção das situações não retornou um resultado válido.');
        System.assert(!result.isEmpty(), 'As situações obtidas estão vazias.');
    }

    @IsTest
    static void testDefinirStatusInicial() {
                Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator' LIMIT 1];
        
        User testUser = new User(
            FirstName = 'Gabriel',
            LastName = 'Lima',
            Alias = 'gab',
            Email = 'gab@example.com',
            Username = 'gab@test.com' + System.currentTimeMillis(), // Para garantir unicidade
            ProfileId = adminProfile.Id, // Usar o ProfileId do Administrador do sistema
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/New_York',
            LanguageLocaleKey = 'pt_BR',
            Situacao__c = null
        );
        insert testUser;
        
        System.runAs(testUser) {
         	String result = OmnichannelService.definirStatusInicial();
        	System.assertNotEquals(null, result, 'A definição de status inicial não retornou um resultado válido.');   
        }
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
    static void testAceitarLeadNull() {
        // Criação do Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste empreendimento',
            CNPJEmpreendimento__c = '91529585000197' // CNPJ válido
        );
        insert empreendimento;
    
        // Criação de um perfil de administrador
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator' LIMIT 1];        
    
        // Criação de um corretor (usuário)
        Contact corretor1 = new Contact(
            FirstName = 'Gustavo', 
            LastName = 'Da Silva',
            CPF__c = '84057287248'
        );
        insert corretor1;
    
        User usuarioCorretor = new User(
            LastName = 'LIVESTONG',
            FirstName = 'JASONL',
            Username = 'japon43@gmail.com',
            Alias = 'jlivb',
            Email = 'john@acmes.com',
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert usuarioCorretor;
    
        // Criação de uma roleta de leads
        RoletaLeads__c roleta1 = new RoletaLeads__c(
            Name = 'Roleta You - Corretores novos',
            CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone;Loja;Stand',
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira'
        );
        insert roleta1;
    
        // Criação de uma equipe
        Equipe__c eq = new Equipe__c(Name = 'eq', CargaMaxima__c = 3.00);
        insert eq;
    
        // Criação de um membro da equipe
        MembroEquipe__c membro = new MembroEquipe__c(
            Name = 'Membro Teste',
            Equipe__c = eq.Id,
            Usuario__c = usuarioCorretor.Id
        );
        insert membro;
    
        // Criação de um participante da roleta
        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            MembroEquipe__c = membro.Id,
            RoletaLeads__c = roleta1.Id, 
            Posicao__c = 1,
            UsuarioCorretor__c = corretor1.Id
        );
        insert participante;
    
        // Criação de um lead com corretor nulo
        Lead testLeadNull = new Lead(
            LastName = 'Ferreira',
            FirstName = 'Da Silva',
            Company = 'Empresa WXYZ',
            Email = 'silva@wxyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Fale conosco',
            MobilePhone = '5511987654323',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id,
            RoletaLeads__c = roleta1.Id,
            OwnerId = usuarioCorretor.Id,
            corretorContato__c = corretor1.Id,
            Corretor__c = null
        );
        insert testLeadNull;
    
        // Teste de aceitação do lead
        System.runAs(usuarioCorretor) {
            Test.startTest();
            String result = OmnichannelService.aceitarLead(testLeadNull.Id);
            Test.stopTest();
        
            // Validações
            Lead updatedLead = [SELECT Corretor__c, OwnerId FROM Lead WHERE Id = :testLeadNull.Id];
            System.assertEquals(usuarioCorretor.Id, updatedLead.OwnerId, 'O OwnerId deve ser atualizado para o usuário corretor.');
        }
    }
    
    @isTest
    static void testAceitarChat() {
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator' LIMIT 1];
    
        Contact corretor1 = new Contact(
            FirstName = 'Pereira Lucas', 
            LastName = 'Silva',
            CPF__c = '10695957058'
        );
        insert corretor1;
    
        User testUser = new User(
            LastName = 'pejrkd',
            FirstName = 'sjajsas',
            Username = 'shajsas@gmail.com',
            Alias = 'lupi',
            Email = 'jdhsj@acme.com',
            ProfileId = adminProfile.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert testUser;
    
        // Criação de uma roleta de leads
        RoletaLeads__c roleta1 = new RoletaLeads__c(
            Name = 'Roleta You - Corretores novo',
            CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone;Loja;Stand',
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira'
        );
        insert roleta1;
    
        // Criação de uma equipe
        Equipe__c eq = new Equipe__c(Name = 'lucas', CargaMaxima__c = 10.00);
        insert eq;
    
        // Criação de um membro da equipe
        MembroEquipe__c membro = new MembroEquipe__c(Name = 'Membro Pleno', Equipe__c = eq.Id , Usuario__c = testUser.Id);
        insert membro;
    
        // Criação de um participante da roleta
        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            MembroEquipe__c = membro.Id,
            RoletaLeads__c = roleta1.Id,
            Posicao__c = 1,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert participante;
    
        // Criação de um empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste empreendimento',
            CNPJEmpreendimento__c = '91529585000197' // CNPJ válido
        );
        insert empreendimento;
    
        // Criação de um lead
        Lead leadNovo = new Lead(
            LastName = 'DSKJDJKJKSD',
            FirstName = 'DSDJSDSHJ',
            Company = 'Empresa JHDHJ',
            Email = 'POWIOQJFN@xyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11987651286',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id,
            OwnerId = testUser.Id,
            corretorContato__c = corretor1.Id,
            Corretor__c = participante.Id 
        );
        insert leadNovo;
    
        // Teste de aceitação do lead
        String result = OmnichannelService.aceitarLead(leadNovo.Id); 
    }
    
    @IsTest
    static void chatter() {
        Lead testLead = new Lead(
            LastName = 'Silva',
            FirstName = 'Teste',
            Company = 'Empresa XYZ',
            Email = 'test.lead43@yahoo.com',
            Status = 'Novo',
            MobilePhone = '5511989540932'
        );
        insert testLead;
    
        User user = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
    
        // Chama o método a ser testado
        OmnichannelService.notificarPeloChatter(testLead.Id, user.Id);
    }
    
  
}