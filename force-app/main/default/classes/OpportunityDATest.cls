@isTest
private class OpportunityDATest {

    @isTest static void testGetOpportunityLineItems() {
        Test.startTest();
        
        Opportunity testOpportunity = new Opportunity(
            Name='Test Opportunity',
            StageName='Negociação',
            CloseDate=System.today().addMonths(1)
        );
        insert testOpportunity;

        Product2 testProduct = new Product2(
            Name = 'produtoTeste', 
            NumeroDaUnidade__c = 35, 
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
        insert testProduct;

        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id=Test.getStandardPricebookId(),
            Product2Id=testProduct.Id,
            UnitPrice=100,
            IsActive=true
        );
        insert testPricebookEntry;

        List<OpportunityLineItem> items = OpportunityDA.getOpportunityLineItems(testOpportunity.Id);

        Test.stopTest();
    }

    @isTest
    static void testGetOpportunitiesWithQuote() {
        Test.startTest();

      
        Opportunity oppWithPricebook = new Opportunity(
            Name='With Pricebook',
            StageName='Negociação',
            CloseDate=System.today().addMonths(1),
            Pricebook2Id=Test.getStandardPricebookId()
        );
        insert oppWithPricebook;

        Opportunity oppWithoutPricebook = new Opportunity(
            Name='Without Pricebook',
            StageName='Negociação',
            CloseDate=System.today().addMonths(1)
        );
        insert oppWithoutPricebook;

        Set<Id> oppIds = new Set<Id>{
            oppWithPricebook.Id,
            oppWithoutPricebook.Id
        };

        Map<Id,Opportunity> results = OpportunityDA.getOpportunitiesWithQuote(oppIds);

        Test.stopTest();
    }

    @isTest static void testGetOpportunityContactRoles() {
        Test.startTest();

        Account testAccount = new Account(Name='Test Account', Type = 'HouseImobiliaria');
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name='Test Opportunity',
            StageName='Prospecting',
            CloseDate=System.today().addMonths(1),
            AccountId=testAccount.Id
        );
        insert testOpportunity;

        Contact testContact = new Contact(
            LastName='Test Contact',
            AccountId=testAccount.Id
        );
        insert testContact;

        OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId=testOpportunity.Id,
            ContactId=testContact.Id,
            Role='Decision Maker'
        );
        insert ocr;

        List<OpportunityContactRole> roles = OpportunityDA.getOpportunityContactRoles(testOpportunity.Id);

        Test.stopTest();
        System.assertEquals(1, roles.size(), 'Deve retornar exatamente um OpportunityContactRole');
    }

    @isTest
    static void testHasSyncedQuote() {
        Test.startTest();
        
        
        Opportunity oppWithQuote = new Opportunity(
            Name = 'Opportunity with Quote',
            StageName = 'Negociação',
            CloseDate = System.today().addMonths(1)
        );
        insert oppWithQuote;

        Quote syncedQuote = new Quote(
            OpportunityId = oppWithQuote.Id,
            Name = 'Synced Quote',
            Status = 'Aprovada'
        );
        insert syncedQuote;

        
        oppWithQuote.SyncedQuoteId = syncedQuote.Id;
        update oppWithQuote;

     
        Boolean hasQuote = OpportunityDA.hasSyncedQuote(oppWithQuote.Id);
        System.assertEquals(true, hasQuote, 'Deveria ter uma Cotação sincronizada');

       
        Opportunity oppWithoutQuote = new Opportunity(
            Name = 'Opportunity without Quote',
            StageName = 'Negociação',
            CloseDate = System.today().addMonths(1)
        );
        insert oppWithoutQuote;

       
        Boolean hasNoQuote = OpportunityDA.hasSyncedQuote(oppWithoutQuote.Id);
        System.assertEquals(false, hasNoQuote, 'Não deveria ter uma Cotação sincronizada');

        Test.stopTest();
    }


    @isTest
    static void testGetAllById () {
        Opportunity testOpportunity2 = new Opportunity(
            Name='Teste',
            StageName='Negociação',
            CloseDate=System.today().addMonths(1)
        );
        insert testOpportunity2;

        Set<Id> idOpp = new Set<Id>();

        idOpp.add(testOpportunity2.Id);

        List<Opportunity> opp = OpportunityDA.getAllById(idOpp);

        Opportunity opp2 = OpportunityDA.getById(testOpportunity2.id);

        Test.startTest();

            System.assertEquals(1, opp.size(), 'Deve retornar exatamente uma Oportunidade');

        Test.stopTest();

    }

    @isTest
    static void testTetProductsById() {
        Opportunity testOpportunity2 = new Opportunity(
            Name='Teste',
            StageName='Negociação',
            CloseDate=System.today().addMonths(1)
        );
        insert testOpportunity2;

        List<OpportunityLineItem> items = OpportunityDA.getProductsById(testOpportunity2.Id);

        Test.startTest();

        System.assertEquals(0, items.size());

        Test.stopTest();
    }

    @isTest
    static void testGetAnaliseCreditoCountByOpportunity() {
        Opportunity testOpportunity2 = new Opportunity(
            Name='Teste',
            StageName='Negociação',
            CloseDate=System.today().addMonths(1)
        );
        insert testOpportunity2;

        Set<Id> opportunityIds = new Set<Id>{testOpportunity2.Id};

        Map<Id, Integer> mapAnalisesRelacionadas = OpportunityDA.getAnaliseCreditoCountByOpportunity(opportunityIds);

        Test.startTest();

        System.assertEquals(0, mapAnalisesRelacionadas.size());

        Test.stopTest();
    }

    @isTest
    static void testGetAllByAnaliseCreditoId(){
        Opportunity testOpportunity2 = new Opportunity(
            Name='Teste',
            StageName='Negociação',
            CloseDate=System.today().addMonths(1)
        );
        insert testOpportunity2;

        Set<Id> idsAnalise = new Set<Id>{testOpportunity2.Id};

        List<Opportunity> opp = OpportunityDA.getAllByAnaliseCreditoId(idsAnalise);

        Test.startTest();

        System.assertEquals(0, opp.size());

        Test.stopTest();
    }


    @isTest
    static void testGetByAnaliseCreditoId(){
        Opportunity testOpportunity2 = new Opportunity(
            Name='Teste',
            StageName='Negociação',
            CloseDate=System.today().addMonths(1)
        );
        insert testOpportunity2;

        List<Opportunity> opp = OpportunityDA.getByAnaliseCreditoId(testOpportunity2.Id);

        Test.startTest();

        System.assertEquals(0, opp.size());

        Test.stopTest();
    }


    @isTest
    static void testGetOpportunityContactRolesPercent() {
        Opportunity testOpportunity2 = new Opportunity(
            Name='Teste',
            StageName='Negociação',
            CloseDate=System.today().addMonths(1)
        );
        insert testOpportunity2;

        List<OpportunityContactRole> roles = OpportunityDA.getOpportunityContactRolesPercent(testOpportunity2.Id);

        Test.startTest();

        System.assertEquals(0, roles.size());

        Test.stopTest();
    }

    @IsTest
    static void testGetOpportunitiesWithChecklistAproval() {

        Opportunity testOpportunity2 = new Opportunity(
            Name='Teste',
            StageName='Negociação',
            CloseDate=System.today().addMonths(1)
        );
        insert testOpportunity2;

        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            WHERE Name = 'Teste'
            LIMIT 1
        ];

        Test.startTest();
        Boolean result = OpportunityDA.getOpportunityWithChecklistApproval(opp.Id);
        Test.stopTest();

        System.assertEquals(false, result);
    }

}