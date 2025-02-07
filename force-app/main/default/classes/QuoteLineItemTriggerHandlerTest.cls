@isTest
public class QuoteLineItemTriggerHandlerTest {
    
    @isTest
    static void testBeforeInsert() {
       
        Account account = new Account(Name = 'Test Account');
        insert account;
        
      
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = account.Id
        );
        insert opp;
        
     
        Quote quote = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            Pricebook2Id = Test.getStandardPricebookId() 
        );
        insert quote;
        
        // Cria um produto
        Product2 product = new Product2(
            Name = 'Test Product',
            IsActive = true,
             NumeroDaUnidade__c = 123,
            Status__c = 'Reservada'
        );
        insert product;
        
     
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pricebookEntry;
     

        QuoteLineItem qli1 = new QuoteLineItem(
            QuoteId = quote.Id,
            Quantity = 1,
            UnitPrice = 100,
            PricebookEntryId = pricebookEntry.Id
        );
        insert qli1;
        
       
        QuoteLineItem qli2 = new QuoteLineItem(
            QuoteId = quote.Id,
            Quantity = 1,
            UnitPrice = 200,
            PricebookEntryId = pricebookEntry.Id
        );
        
        Test.startTest();
        try {
       
            insert qli2;
            System.assert(false, 'Expected DmlException was not thrown');
        } catch (DmlException e) {
           
            System.assert(e.getMessage().contains('Não é permitido adicionar mais de um produto à cotação.'));
        }
        Test.stopTest();
    }
}