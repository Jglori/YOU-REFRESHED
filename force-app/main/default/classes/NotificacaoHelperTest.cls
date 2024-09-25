@isTest
public class NotificacaoHelperTest {
   @TestSetup
   static void makeData() {
        doCreateData();
   }
   
   private static void doCreateData() {

        Empreendimento__c empreendimento = new Empreendimento__c (Name = 'Teste empreendimento',CNPJEmpreendimento__c ='07135796000139');
        insert empreendimento;

        Profile papel = [SELECT Id, Name FROM Profile WHERE Name = 'Administrador do sistema'];

        User usuarioCorretor2 = new User (
            LastName = 'userCorretorTest2',
            Alias = 'uct',
            Username = 'teste_user12345@email.com',
            Email = 'teste_user12345@email.com',
            CommunityNickname = 'User21478656781456985578',
            Cargo__c = 'CORRETOR ONLINE',
            TimeZoneSidKey = 'America/Sao_Paulo', 
            LocaleSidKey = 'pt_BR', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = papel.id, 
            LanguageLocaleKey = 'pt_BR'
        );
        insert usuarioCorretor2;

        User usuarioCorretor = new User (
            LastName = 'userCorretorTest',
            Alias = 'tcu',
            Username = 'user_teste123@email.com',
            Email = 'user_teste123@email.com',
            CommunityNickname = 'User25478965481243685578', 
            Reportase__c = usuarioCorretor2.id,
            Cargo__c = 'CORRETOR ONLINE',
            TimeZoneSidKey = 'America/Sao_Paulo', 
            LocaleSidKey = 'pt_BR', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = papel.id, 
            LanguageLocaleKey = 'pt_BR'
        );
        insert usuarioCorretor;

        //id idConta = [SELECT Id FROM RecordType WHERE Name = 'Conta'];
        Account contaCorretores = new Account (
            //RecordTypeId = 	idConta,
            Name = 'TesteHouse',
            MidiaDeOrigem__c = 'Radio',
            Type = 'HouseImobiliaria',
            InscricaoEstadual__c = '3',
            InscricaoMunicipal__c = '34',
            TelefoneComercial__c = '1145543126'
        );
        insert contaCorretores;

        // RecordType idCorretor = [SELECT Id, Name FROM RecordType WHERE Name = 'Corretor'];
        Contact corretor = new Contact (
        // RecordTypeId = idCorretor,
        LastName = 'testeCorretor',  
        UsuarioCorretor__c = usuarioCorretor.id,  
        Apelido__c = 'testeCorretor', 
        TipoCorretor__c = 'Corretor Online', 
        TipoCRECI__c = 'Estagiário', 
        email = 'teste@email.com', 
        MobilePhone = '11942354414'
        );


        //RecordType idConta = [SELECT Id, Name FROM RecordType WHERE Name = 'Conta Pessoal'];
        Account contaPessoal = new Account (
        // RecordTypeId = 	idConta,
            LastName = 'testeTrigger',
            MidiaDeOrigem__c = 'Radio',
            Phone = '11912345789',
            PersonEmail = 'teste@email.com'
        );

        insert contaPessoal;

        Bloco__c blocoTeste = new Bloco__c (
            Name = 'BlocoTeste',
            Empreendimento__c = empreendimento.id, 
            TipoBloco__c = 'Ala', 
            QuantidadeAndares__c = 3, 
            TotalUnidades__c = 3, 
            DataLancamento__c = Date.newInstance(2024, 5, 24),
            DataEntrega__c = Date.newInstance(2024, 5, 30)
        );

        insert blocoTeste;

        Product2 produtoTeste = new Product2 (
            Name = 'produtoTeste', 
            NumeroDaUnidade__c = 35, 
            Empreendimento__c = empreendimento.id, 
            Bloco__c = blocoTeste.id, 
            AgenteFinanceiro__c = 'FII', 
            Enquadramento__c = 'HIS', 
            Status__c = 'Disponivel', 
            Andar__c = 10, 
            ValorM2__c = 7000, 
            Coeficiente__c = 100,
            NumeroQuartos__c = 2, 
            NumeroDeSuites__c = 1, 
            NumeroDeVagasIncorporadas__c = 1
        );
        insert produtoTeste;
        
        
        Opportunity oportunidadeTeste = new Opportunity (
            Name = 'OportunidadeTeste', 
            AccountId = contaPessoal.id, 
            Corretor__c = corretor.id, 
            CloseDate =  Date.newInstance(2024, 5, 10),
            StageName = 'Negociação',
            Unidade__c = produtoTeste.id
        );

        insert oportunidadeTeste;

    }

    @IsTest
    static void testNotificacaoEquipeVendas() {
        List<Product2> unidades = [SELECT id, Name, NumeroDaUnidade__c, Empreendimento__c, Bloco__c, AgenteFinanceiro__c, Enquadramento__c, Status__c, Andar__c, ValorM2__c, Coeficiente__c, NumeroQuartos__c, NumeroDeSuites__c, NumeroDeVagasIncorporadas__c FROM Product2 WHERE Name = 'produtoTeste'];
    
        Test.startTest();

        NotificacaoHelper.notificacaoEquipeVendas(unidades);
      
        Test.stopTest();

        System.assert(!unidades.get(0).hasErrors());
    }

    @isTest
    static void testBuscarEquipeVendas() {
        Product2 unidade = [SELECT id, Name, NumeroDaUnidade__c, Empreendimento__c, Bloco__c, AgenteFinanceiro__c, Enquadramento__c, Status__c, Andar__c, ValorM2__c, Coeficiente__c, NumeroQuartos__c, NumeroDeSuites__c, NumeroDeVagasIncorporadas__c FROM Product2 WHERE Name = 'produtoTeste'];
        List<Opportunity> listaOportunidades = [SELECT id, Name, AccountId, Corretor__c, Corretor__r.UsuarioCorretor__c, CloseDate, StageName, Unidade__r.Id, Unidade__r.Name, Unidade__r.Status__c  FROM Opportunity WHERE Unidade__r.id = :unidade.id];

        System.debug(unidade);
        System.debug(listaOportunidades);



        Test.startTest();

        NotificacaoHelper.buscarEquipeVendas(listaOportunidades);

        Test.stopTest();

        System.assert(!listaOportunidades.get(0).hasErrors());
    }

    @isTest
    static void testBuscarSupervisores() {
        Product2 unidade = [SELECT id, Name, NumeroDaUnidade__c, Empreendimento__c, Bloco__c, AgenteFinanceiro__c, Enquadramento__c, Status__c, Andar__c, ValorM2__c, Coeficiente__c, NumeroQuartos__c, NumeroDeSuites__c, NumeroDeVagasIncorporadas__c FROM Product2 WHERE Name = 'produtoTeste'];
        List<Opportunity> listaOportunidades = [SELECT id, Name, AccountId, Corretor__c, Corretor__r.UsuarioCorretor__c, CloseDate, StageName, Unidade__r.Id, Unidade__r.Name, Unidade__r.Status__c  FROM Opportunity WHERE Unidade__r.id = :unidade.id];
        User usuario1 = [SELECT LastName, Alias, Username, Email, Reportase__c, Reportase__r.Email, Cargo__c FROM User WHERE Alias = 'tcu' ];
        Set<Id> supervisoresProcessados = new Set<Id>();
        Set<String> emailsEquipeVendas = new Set<String>();

        User user = usuario1;
        Id idReporte = usuario1.Reportase__c;

        Test.startTest();

        NotificacaoHelper.buscarSupervisores(idReporte, user, emailsEquipeVendas, listaOportunidades, supervisoresProcessados);

        Test.stopTest();

        System.assert(!usuario1.hasErrors());
    }

    @isTest
    static void testMandarEmailEquipeVendas() {
        List<User> usuarios = [SELECT LastName, Alias, Username, Email, Reportase__c, Reportase__r.Email, Cargo__c FROM User WHERE Alias = 'tcu'];
        List<String> listaEmailsEquipeVendas = new List<String>(); 

        for (User users : usuarios) {
            listaEmailsEquipeVendas.add(users.Email);
            listaEmailsEquipeVendas.add(users.Reportase__r.Email);
        }
      
        Product2 unidade = [SELECT id, Name, NumeroDaUnidade__c, Empreendimento__c, Bloco__c, AgenteFinanceiro__c, Enquadramento__c, Status__c, Andar__c, ValorM2__c, Coeficiente__c, NumeroQuartos__c, NumeroDeSuites__c, NumeroDeVagasIncorporadas__c FROM Product2 WHERE Name = 'produtoTeste'];
        List<Opportunity> listaOportunidades = [SELECT id, Name, AccountId, Corretor__c, Corretor__r.UsuarioCorretor__c, CloseDate, StageName, Unidade__r.Id, Unidade__r.Name, Unidade__r.Status__c FROM Opportunity WHERE Unidade__r.id = :unidade.id];

        Test.startTest();

        NotificacaoHelper.mandarEmailEquipeVendas(listaEmailsEquipeVendas, listaOportunidades);

        Test.stopTest();

        for (Integer i = 0; i < listaOportunidades.size(); i++) {
            System.assert(!listaOportunidades[i].hasErrors());
        }
    }

    @isTest
    static void testNotificacaoCliente() { 
        List<Product2> unidades = [SELECT id, Name, NumeroDaUnidade__c, Empreendimento__c, Bloco__c, AgenteFinanceiro__c, Enquadramento__c, Status__c, Andar__c, ValorM2__c, Coeficiente__c, NumeroQuartos__c, NumeroDeSuites__c, NumeroDeVagasIncorporadas__c FROM Product2 WHERE Name = 'produtoTeste'];
    
        Test.startTest();

        NotificacaoHelper.notificacaoCliente(unidades);
      
        Test.stopTest();

        System.assert(!unidades.get(0).hasErrors());
    }



}