@IsTest
public with sharing class AnaliseCreditoHelperTest {

    @TestSetup
    static void setup() {
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE SobjectType = 'Contact' AND Name = 'Corretor'
        ];

        RecordType rtAcc = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'Account' AND Name = 'Conta pessoal'
        ];
        
        Account accTest = new Account();
        accTest.Name = 'Conta de Teste';
        accTest.CNPJ__c = '34138415000148';
        accTest.Type = 'HouseImobiliaria';
        
        Account acc = new Account();
        acc.Type = 'Cliente';
        acc.RecordTypeId = rtAcc.Id;
        acc.FirstName = 'teste';
        acc.LastName = 'teste';
        acc.PersonEmail = 'test.dev@elera.io';
        insert new List<Account> {accTest, acc};
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Teste';
        opp1.Amount = 1000;
        opp1.CanalAtendimento__c = 'WhatsApp';
        opp1.Probability = 20;
        opp1.TipoVenda__c = 'Negócio novo';
        opp1.StageName = 'Pré-análise';
        opp1.CloseDate = System.today().addDays(15);
        opp1.AccountId = acc.Id;

        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Teste';
        opp2.Amount = 1000;
        opp2.CanalAtendimento__c = 'WhatsApp';
        opp2.Probability = 20;
        opp2.TipoVenda__c = 'Negócio novo';
        opp2.CloseDate = System.today().addDays(15);
        opp2.StageName = 'Negociação';
        opp2.AccountId = accTest.Id;
        insert new List<Opportunity> { opp1, opp2 };

        Documentacao__c doc = new Documentacao__c();
        doc.Name = 'Documento test';
        doc.Obrigatorio__c = true;
        doc.Entregue__c = false;
        doc.Validado__c = false;
        insert doc;

        Checklist_de_Documentos__c checklists = new Checklist_de_Documentos__c();
        checklists.Oportunidade__c = opp1.Id;
        checklists.Documenta_o__c = doc.Id;
        insert checklists;
    }

    @IsTest
    static void testHandleOpportunityFase_Valid() {
        Opportunity oppTest = [
            SELECT Id, StageName
            FROM Opportunity
            WHERE StageName = 'Pré-análise'
        ];

        Test.startTest();
        AnaliseCredito__c analise = new AnaliseCredito__c();
        analise.Name = 'Teste';
        analise.Status__c = 'Em Análise';
        analise.Opportunity__c = oppTest.Id;
        analise.DataVencimento__c = Date.today();

        AnaliseCreditoHelper.handleOpportunityFase(new List<AnaliseCredito__c>{ analise });   
        Test.stopTest();

        
        for (AnaliseCredito__c a : new List<AnaliseCredito__c>{ analise }) {
            System.assert(a.getErrors().size() == 0, 'A análise não deveria ter erros.');
        }
    }

    @IsTest
    static void testHandleOpportunityFase_Invalid() {
        Opportunity oppTest = [
            SELECT Id, StageName
            FROM Opportunity
            WHERE StageName = 'Negociação'
        ];
        
        Test.startTest();
        AnaliseCredito__c analise = new AnaliseCredito__c();
        analise.Name = 'Teste';
        analise.Status__c = 'Em Análise';
        analise.Opportunity__c = oppTest.Id;
        analise.DataVencimento__c = Date.today();

        AnaliseCreditoHelper.handleOpportunityFase(new List<AnaliseCredito__c>{ analise });   
        Test.stopTest();

        for (AnaliseCredito__c a : new List<AnaliseCredito__c>{ analise }) {
            if (a.getErrors().size() > 0) {
                for (Database.Error erro : a.getErrors()) {
                    System.assert(
                        erro.getMessage().contains('Análise de Crédito pode ser criada somente na fase de Pré-análise da Oportunidade'), 
                        'A mensagem de erro deveria indicar o problema com a fase da oportunidade.'
                    );
                }
            }
        }

        List<AnaliseCredito__c> analises = [
            SELECT Id, Name, Opportunity__c, Status__c
            FROM AnaliseCredito__c
        ];

        System.assertEquals(0, analises.size(), 'A lista de análise deveria estar vazia.');
    }

    @IsTest
    static void testHandleStatusForOpportunity_Valid() {
        Opportunity oppTest = [
            SELECT Id, StageName
            FROM Opportunity
            WHERE StageName = 'Pré-análise'
        ];
        
        AnaliseCredito__c analise1 = new AnaliseCredito__c();
        analise1.Name = 'Teste';
        analise1.Status__c = 'Em Análise';
        analise1.Opportunity__c = oppTest.Id;
        analise1.DataVencimento__c = Date.today();

        AnaliseCredito__c analise2 = new AnaliseCredito__c();
        analise2.Name = 'Teste';
        analise2.Opportunity__c = oppTest.Id;
        analise2.DataVencimento__c = Date.today();
        analise2.Status__c = 'Aprovada';
        
        List<AnaliseCredito__c> analises = new List<AnaliseCredito__c>{analise1, analise2};
        
        Test.startTest();
        AnaliseCreditoHelper.handleStatusForOpportunity(analises);
        Test.stopTest();

        List<AnaliseCredito__c> analisesTestadas = [
            SELECT Id, Name, Opportunity__c, Status__c
            FROM AnaliseCredito__c
            WHERE Opportunity__c = :oppTest.Id
        ];

        for (AnaliseCredito__c a : analises) {
            System.assert(a.getErrors().size() == 0, 'Análise não deveria ter erros.');
        }
    }

    @IsTest
    static void testHandleStatusForOpportunity_Invalid_firstCondition() {
        Opportunity oppTest = [
            SELECT Id, StageName
            FROM Opportunity
            WHERE StageName = 'Pré-análise'
        ];
        
        List<AnaliseCredito__c> analises = new List<AnaliseCredito__c>();
        for (Integer i = 0; i < 2; i++) {
            AnaliseCredito__c analise = new AnaliseCredito__c();
            analise.Name = 'Teste';
            analise.Opportunity__c = oppTest.Id;
            analise.DataVencimento__c = Date.today();
            analise.Status__c = 'Aprovada';
            analises.add(analise);
        }

        Test.startTest();
        AnaliseCreditoHelper.handleStatusForOpportunity(analises);        
        Test.stopTest();

        for (AnaliseCredito__c a : analises) {
            if (a.getErrors().size() > 0) {
                System.assert(
                    a.getErrors()[0].getMessage().contains('Não é permitido ter duas análises de crédito com status aprovada em uma oportunidade'), 
                    'A mensagem de erro deveria indicar o problema com a quantidade de análises de créditos aprovadas da oportunidade.'
                );
            }
        }

        List<AnaliseCredito__c> analisesTestadas = [
            SELECT Id, Name, Opportunity__c, Status__c
            FROM AnaliseCredito__c
            WHERE Opportunity__c = :oppTest.Id
        ];

        System.assertEquals(0, analisesTestadas.size(), 'A lista de análise deveria ter 0 registro.');
    }

    @IsTest
    static void testHandleStatusForOpportunity_Invalid_secondCondition() {
        Opportunity oppTest = [
            SELECT Id, StageName
            FROM Opportunity
            WHERE StageName = 'Pré-análise'
        ];
        
        AnaliseCredito__c analise1 = new AnaliseCredito__c();
        analise1.Name = 'Teste';
        analise1.Opportunity__c = oppTest.Id;
        analise1.DataVencimento__c = Date.today();
        analise1.Status__c = 'Aprovada';
        insert analise1;

        AnaliseCredito__c analise2 = new AnaliseCredito__c();
        analise2.Name = 'Teste';
        analise2.Opportunity__c = oppTest.Id;
        analise2.DataVencimento__c = Date.today();
        analise2.Status__c = 'Aprovada';
        
        Test.startTest();
        AnaliseCreditoHelper.handleStatusForOpportunity(new List<AnaliseCredito__c>{ analise2 });
        Test.stopTest();

        for (AnaliseCredito__c a : new List<AnaliseCredito__c>{ analise2 }) {
            if (a.getErrors().size() > 0) {
                System.assert(
                    a.getErrors()[0].getMessage().contains('Não é permitido ter duas análises de crédito com status aprovada em uma oportunidade'), 
                    'Deveria lançar um erro devido que a Oportunidade não pode ter duas Análises com Status "Aprovada".'
                );
            }
        }

        List<AnaliseCredito__c> analisesTestadas = [
            SELECT Id, Name, Opportunity__c, Status__c
            FROM AnaliseCredito__c
            WHERE Opportunity__c = :oppTest.Id
        ];

        System.assertEquals(1, analisesTestadas.size(), 'A lista de análise deveria ter 1 registro.');
    }

    @IsTest
    static void testHandleDataVencimentoValid() {
        Opportunity opp = [
            SELECT Id, StageName
            FROM Opportunity
            WHERE StageName = 'Pré-análise'
        ];

        AnaliseCredito__c analise = new AnaliseCredito__c();
        analise.Name = 'Teste';
        analise.Opportunity__c = opp.Id;
        analise.DataVencimento__c = Date.today();
        analise.Status__c = 'Em Análise';
        
        Date data = Date.today();
        data = data.addDays(3);
        analise.DataVencimento__c = data;

        AnaliseCreditoHelper.handleDataVencimento(new List<AnaliseCredito__c>{ analise });

        System.assertNotEquals('Vencida', analise.Status__c, 'Não deveria estar "Vencida" o Status da Analise');
    }

    @IsTest
    static void testHandleDataVencimentoInvalid() {
        Opportunity opp = [
            SELECT Id, StageName
            FROM Opportunity
            WHERE StageName = 'Pré-análise'
        ];

        AnaliseCredito__c analise = new AnaliseCredito__c();
        analise.Name = 'Teste';
        analise.Opportunity__c = opp.Id;
        analise.DataVencimento__c = Date.today();
        analise.Status__c = 'Em Análise';

        Date data = Date.today();
        data = data.addDays(-3);
        analise.DataVencimento__c = data;

        AnaliseCreditoHelper.handleDataVencimento(new List<AnaliseCredito__c>{ analise });

        System.assertEquals('Vencida', analise.Status__c, 'Deveria estar "Vencida" o Status da Analise');
    }

    @IsTest
    static void testHandleDocumentVerification_Valid() {
        Opportunity oppTest = [
            SELECT Id, StageName
            FROM Opportunity
            WHERE StageName = 'Pré-análise'
        ];
        
        AnaliseCredito__c analise = new AnaliseCredito__c();
        analise.Name = 'Teste';
        analise.Opportunity__c = oppTest.Id;
        analise.DataVencimento__c = Date.today();
        analise.Status__c = 'Em Análise';

        insert analise;
        Test.startTest();
        analise.Status__c = 'Aprovada';
        update analise;
        Test.stopTest();

        AnaliseCredito__c resultAnalise = [
            SELECT Id, Status__c
            FROM AnaliseCredito__c
            WHERE Id = :analise.Id
        ];

       // System.assertEquals('Reprovada', resultAnalise.Status__c, 'Status da Análise deveria se "Reprovada".');
    }
 
    @IsTest
    static void testHandleNotification_Valid() {
        Opportunity oppTest = [
            SELECT Id, StageName, Account.PersonEmail
            FROM Opportunity
            WHERE StageName = 'Pré-análise'
        ];
        
        AnaliseCredito__c analise = new AnaliseCredito__c();
        analise.Name = 'Teste';
        analise.Opportunity__c = oppTest.Id;
        analise.DataVencimento__c = Date.today();
        analise.Status__c = 'Aprovada';
        Test.startTest();
        insert analise;
        Test.stopTest();

        List<FeedItem> feeds = [
            SELECT Id, ParentId, Body
            FROM FeedItem
            WHERE ParentId =: oppTest.AccountId
        ];
        System.debug(feeds);

        // System.assertEquals('A Análise crédito '+analise.Name+' foi aprovada com sucesso!', feeds[0].Body, 'Deveria conter mensagem de análise aprovada.');
    }

    @IsTest
    static void testHandleNotification_Invalid() {
        try {
            AnaliseCreditoHelper.handleNotification(null);
            System.assert(false, 'Deveria estourar uma excessão.');
        } catch (IllegalArgumentException e) {
            System.assert(
                e.getMessage().contains('A lista de Análises de Crédito não deve ser nula ou vazia.'),
                'Deveria aparecer mensagem caso argumento fosse null'
            );
        }
    }
}