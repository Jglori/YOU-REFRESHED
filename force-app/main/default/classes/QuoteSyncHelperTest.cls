@IsTest
public class QuoteSyncHelperTest {

    @TestSetup
    static void setupTestData() {
        // Cria uma conta de teste
        Account account = new Account(Name = 'Test Account');
        account.CNPJ__c = '34138415000148';
        insert account;

        // Cria uma oportunidade associada à conta
        Opportunity opportunity = new Opportunity(
            Name = 'Teste Oportunidade',
            AccountId = account.Id,
            CloseDate = System.today().addDays(30),
            StageName = 'Negociação'
        );
        insert opportunity;
    }

    @IsTest
    static void testQuoteSyncTrigger_StatusUpdate() {
		Product2 product = new Product2(name='Product',productCode='XX1234', isActive=true, NumeroDaUnidade__c = 15, 
                                        Status__c = 'Vendida');
        insert product;
    
        id standardPBID = Test.getStandardPricebookId(); 
    
        PricebookEntry stdPBE = new PriceBookEntry(
            Product2Id=product.Id,
            Pricebook2Id=standardPBID,
            UnitPrice = 3000000.00,
            UseStandardPrice = false,
            IsActive=true
        );
    
        insert stdPBE;     
      
        PriceBook2 customPriceBook = new PriceBook2();
        customPriceBook.Name='Custom Pricebook';
        customPriceBook.IsActive=true;
        insert customPriceBook;

        PricebookEntry cusPBE = new PriceBookEntry(
            Product2Id = product.Id,
            Pricebook2Id=customPriceBook.Id,
            UnitPrice = 5000000.00,
            UseStandardPrice = false,
            IsActive=true
        );

        insert cusPBE;

        // Criar uma oportunidade associada ao Pricebook personalizado
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            Pricebook2Id = customPriceBook.Id, 
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting'
        );
        insert opp;

        Opportunity opptest = new Opportunity(
            Name = 'Test Opportunity 1',
            Pricebook2Id = customPriceBook.Id,
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting'
        );
        insert opptest;

        
        Opportunity opptest2 = new Opportunity(
            Name = 'Test Opportunity 2',
            Pricebook2Id = customPriceBook.Id, 
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting'
        );
        insert opptest2;

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = cusPBE.Id,
            Quantity = 1,
            TotalPrice = 100
        );
        insert oli;
        
        OpportunityLineItem olitest = new OpportunityLineItem(
            OpportunityId = opptest.Id,
            PricebookEntryId = cusPBE.Id,
            Quantity = 1,
            TotalPrice = 100
        );
        insert olitest;

        Quote quote = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            Pricebook2Id = customPriceBook.Id,
            Status = 'Simulacao'
        );
        insert quote;

        Quote quotetest = new Quote(
            Name = 'Test Quote 2',
            OpportunityId = opptest2.id,
            Pricebook2Id = customPriceBook.Id,
            Status = 'Simulacao'
        );
        insert quotetest;

        System.debug('opptest ' + opptest);

        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = quote.Id,
            PricebookEntryId = cusPBE.Id,
            Quantity = 1,   
            UnitPrice = 100
        );
        insert qli;

        QuoteLineItem qlitest = new QuoteLineItem(
            QuoteId = quotetest.Id,
            PricebookEntryId = cusPBE.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert qlitest;
            
        Set<Id> opportunityIds = new Set<Id>();
        opportunityIds.add(quote.OpportunityId);

        System.debug('set ' + opportunityIds);
            
        Map<Id, Quote> syncedQuotesMap = new Map<Id, Quote>(
            [SELECT Id, Name, OpportunityId, IsSyncing  FROM Quote WHERE OpportunityId IN :opportunityIds]
        );
        System.debug('map ' + syncedQuotesMap);

        List<Quote> newQuotes = [SELECT Id, OpportunityId, Status, Name FROM Quote LIMIT 1];
        newQuotes.add(quote);
        newQuotes.add(quotetest);
        System.debug('list ' + newQuotes);

        quote.Status = 'Aprovada';
        update quote;
        
        Quote syncedQuote = syncedQuotesMap.get(quote.OpportunityId);

        Test.startTest();
            QuoteSyncHelper.BeforeInsertOrUpdate(newQuotes);            
        Test.stopTest();

        Quote updatedQuote = [SELECT Id, Status FROM Quote WHERE Id = :quote.Id];
        System.assertEquals('Aprovada', updatedQuote.Status, 'O status da cotação não foi atualizado corretamente.');
    }
    
}