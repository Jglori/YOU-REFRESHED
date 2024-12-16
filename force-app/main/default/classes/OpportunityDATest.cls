@isTest
private class OpportunityDATest {

    @TestSetup
    static void setup() {
        Account acc = TestDataFactory.gerarConta();
        insert acc;

        Product2 testProduct = TestDataFactory.gerarProduto();
        insert testProduct;

        Opportunity testOpportunity = TestDataFactory.gerarOportunidade();
        testOpportunity.StageName = 'Ficha Cadastral';

        Opportunity testOpportunityPre = TestDataFactory.gerarOportunidade();
        testOpportunityPre.StageName = 'Pré-análise';
        testOpportunityPre.AccountId = acc.Id;
        testOpportunityPre.Unidade__c = testProduct.Id;

        Opportunity oppWithPricebook = TestDataFactory.gerarOportunidade();
        oppWithPricebook.Name='With Pricebook';
        oppWithPricebook.Pricebook2Id=Test.getStandardPricebookId();

        Opportunity oppWithoutPricebook = TestDataFactory.gerarOportunidade();
        oppWithoutPricebook.Name='Without Pricebook';
        insert new List<Opportunity> {testOpportunity, testOpportunityPre, oppWithPricebook, oppWithoutPricebook};

        AnaliseCredito__c analise = TestDataFactory.gerarAnaliseCredito(testOpportunityPre);
        insert analise;

        /*
            * Realiza a aprovação da oportunidade 
        */
        {
            Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
            submitRequest.setComments('Enviando Opportunity para aprovação');
            submitRequest.setObjectId(testOpportunity.Id);
            Approval.ProcessResult approvalResult = Approval.process(submitRequest);
    
            Approval.ProcessWorkitemRequest workitemRequest = new Approval.ProcessWorkitemRequest();
            workitemRequest.setComments('Aprovando Opportunity');
            workitemRequest.setAction('Approve');
            workitemRequest.setWorkitemId(approvalResult.getNewWorkitemIds()[0]);
            Approval.process(workitemRequest);
        }

        PricebookEntry testPricebookEntry = TestDataFactory.gerarPricebookEntry(testProduct);
        insert testPricebookEntry;

        OpportunityLineItem oli = TestDataFactory.gerarOpportunityLineItem(oppWithPricebook, testProduct);
        oli.pricebookEntryId = testPricebookEntry.Id;
        insert oli;

        Contact ctt = TestDataFactory.gerarContato();
        insert ctt;

        OpportunityContactRole ocr = TestDataFactory.gerarOpportunityContactRole(testOpportunity, ctt);
        insert ocr;
    }

    @isTest
    static void testGetOpportunitiesWithQuote() {
        List<Opportunity> opps = [
            SELECT Id
            FROM Opportunity
            WHERE Name = 'With Pricebook'
        ];
        
        Test.startTest();
  
        Map<Id,Opportunity> results = OpportunityDA.getOpportunitiesWithQuote(new Set<Id>{ opps[0].Id });

        System.assertEquals(1, results.size());

        Test.stopTest();
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


    @IsTest
    static void testGetOpportunityLineItems() {
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            WHERE Name='With Pricebook' 
        ];

        Test.startTest();
        List<OpportunityLineItem> results = OpportunityDA.getOpportunityLineItems(opp.Id);
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Deveria conter um valor na lista.');
    }

    
    @IsTest
    static void testGetOpportunityContactRoles() {
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            WHERE Name='Teste' 
            LIMIT 1
        ];

        Test.startTest();
        List<OpportunityContactRole> results = OpportunityDA.getOpportunityContactRoles(opp.Id);
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Deveria conter um valor na lista.');
    }


    @IsTest
    static void testObterOportunidadePorIdProduto() {
        Product2 product = [
            SELECT Id
            FROM Product2
        ];

        Test.startTest();
        List<Opportunity> results = OpportunityDA.obterOportunidadePorIdProduto(new Set<Id>{ product.Id });
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Deveria conter 1 item na lista');
    }

    @IsTest
    static void testGetAnaliseCreditoCountByOpportunity() {
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            WHERE Name = 'Teste'
            AND StageName = 'Pré-análise'
        ];

        Test.startTest();
        Map<Id, Integer> result = OpportunityDA.getAnaliseCreditoCountByOpportunity(new Set<Id>{ opp.Id });
        Test.stopTest();
    
        System.assertEquals(1, result.get(opp.Id), 'Quantidade deveria retornar 1');
    }

    @IsTest
    static void testGetOpportunitiesWithChecklistAproval() {
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            WHERE Name = 'Teste'
            LIMIT 1
        ];

        Test.startTest();
        Boolean result = OpportunityDA.getOpportunityWithChecklistAproval(opp.Id);
        Test.stopTest();

        System.assert(result, 'Deveria retornar true');
    }

    @IsTest
    static void testGetAllByAnaliseCredito() {
        AnaliseCredito__c analise = [
            SELECT Id
            FROM AnaliseCredito__c
        ];

        Test.startTest();
        List<Opportunity> results = OpportunityDA.getAllByAnaliseCredito(new Set<Id>{ analise.Id });
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Deveria conter 1 item na lista.');
    }

    @IsTest
    static void testGetByAnaliseCredito() {
        AnaliseCredito__c analise = [
            SELECT Id
            FROM AnaliseCredito__c
        ];

        Test.startTest();
        List<Opportunity> results = OpportunityDA.getByAnaliseCredito(analise.Id);
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Deveria conter 1 item na lista.');
    }

    @IsTest
    static void testGetAllById() {
        List<Opportunity> opps = [
            SELECT id
            FROM Opportunity
        ];
        
        Set<Id> oppIds = new Set<Id>(); 
        for (Opportunity opp : opps) {
            oppIds.add(opp.Id);
        }  

        Test.startTest();
        List<Opportunity> results = OpportunityDA.getAllById(oppIds);
        Test.stopTest();

        System.assertEquals(4, results.size(), 'Deveria conter 4 itens no resultado');
    }
}