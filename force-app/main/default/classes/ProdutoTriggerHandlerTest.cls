@isTest
public class ProdutoTriggerHandlerTest {
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

        Opportunity oportunidadeTeste = new Opportunity (
            Name = 'OportunidadeTeste', 
            AccountId = contaPessoal.id, 
            Corretor__c = corretor.id, 
            CloseDate =  Date.newInstance(2024, 5, 10),
            StageName = 'Negociação'
        );

        insert oportunidadeTeste;

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
            ValorM2__c = 700.00, 
            Coeficiente__c = 0,
            NumeroQuartos__c = 2, 
            NumeroDeSuites__c = 1, 
            NumeroDeVagasIncorporadas__c = 1
        );
        insert produtoTeste;
        

    }

    @IsTest
    static void testAfterUpdate() {
        Opportunity oportunidade = [SELECT id, Name, Unidade__c FROM Opportunity LIMIT 1];
        Product2 unidade = [SELECT id, Name, Status__c FROM Product2 LIMIT 1];

        Test.startTest();
        oportunidade.Unidade__c = unidade.id;
        unidade.Status__c = 'Reservada';
        update unidade;
        update oportunidade;
        Test.stopTest();
    }
}