@IsTest
private class OpportunityProductsHelperTest {

    @TestSetup
    static void setupTestData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Product2 unidade = new Product2(
            Name = 'Test Unidade',
            ProductCode = 'TestCode123',
            IsActive = true,
            NumeroDaUnidade__c = 100
        );
        insert unidade;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Negociação',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert opp;

        Quote quote = new Quote(
            OpportunityId = opp.Id,
            Name = 'Test Quote',
            Status = 'Aprovada',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert quote;

        opp.SyncedQuoteId = quote.Id;
        update opp;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = opp.Pricebook2Id,
            Product2Id = unidade.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;
    }

    @IsTest
    static void testBeforeInsert_Success() {
        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :opp.Pricebook2Id LIMIT 1];

        OpportunityLineItem newItem = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100
        );

        Test.startTest();
        insert newItem;
        Test.stopTest();

        System.assertEquals(0, newItem.getErrors().size());
    }

    @IsTest
    static void testBeforeInsert_Failure() {
        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :opp.Pricebook2Id LIMIT 1];

        OpportunityLineItem newItem = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100
        );

        opp.SyncedQuoteId = [SELECT Id FROM Quote LIMIT 1].Id;
        update opp;

        Test.startTest();
        try {
            insert newItem;
        } catch (DmlException e) {
            System.debug('DML Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
}