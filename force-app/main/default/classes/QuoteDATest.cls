@IsTest
public class QuoteDATest {
    
    @TestSetup
    static void makeData() {
        Account account = new Account(Name = 'Test Account');
        account.CNPJ__c = '34138415000148';
        insert account;
        
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Nome do Empreendimento',
        SPE__c = account.Id,
        CNPJEmpreendimento__c = '04682086000130',
        TipoEmpreendimento__c = 'Casa',
        StatusObra__c = 'Entregue',
        MetragemPrivativaTotal__c = 5000,
        MetragemTerreno__c = 10000,
        MetragemConstruIdaM__c = 7000
            );
        insert empreendimento;
        
        Bloco__c bloco = new Bloco__c(
            Name = 'Nome do Bloco',
        DataLancamento__c = Date.today(),
        DataEntrega__c = Date.today().addMonths(12),
        Empreendimento__c = empreendimento.Id,
        QuantidadeAndares__c = 10,
        TotalUnidades__c = 50
            );
        insert bloco;
        
        Product2 unidade = new Product2(
            Name = 'Nome do Produto do Apartamento',
        ProductCode = '854785964',
        ExternalId = '10',
        Empreendimento__c = empreendimento.Id,
        Bloco__c = bloco.Id,
        NumeroDaUnidade__c = 25,
        ValorM2__c = 8,
        Status__c = 'Reservada'
            );
        insert unidade;
        
        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
        AccountId = account.Id,
        CloseDate = System.today().addDays(30),
        StageName = 'Negociacao'
            );
        insert opportunity;
    }
    
    @IsTest
    static void testGetQuotesMapByIds() {
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Product2 unidade = [SELECT Id FROM Product2 LIMIT 1];
        
        Id standardPricebook = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntry = new PricebookEntry(
            Product2Id = unidade.Id,
        Pricebook2Id = standardPricebook,
        UnitPrice = 100,
        IsActive = true
            );
        insert pricebookEntry;
        
        Quote quote = new Quote(
            Name = 'Test Quote',
        OpportunityId = opportunity.Id,
        Pricebook2Id = standardPricebook
            );
        insert quote;
        
        Test.startTest();
        Map<Id, Quote> quotesMap = QuoteDA.getQuotesMapByIds(new List<Id>{quote.Id});
        Test.stopTest();
        
        System.assertEquals(1, quotesMap.size(), 'Deve haver 1 cotação no mapa.');
        System.assertNotEquals(null, quotesMap.get(quote.Id), 'A cotação no mapa não deve ser nula.');
    }
    
    @IsTest
    static void testGetProductByQuoteId() {
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Product2 unidade = [SELECT Id FROM Product2 LIMIT 1];
        
        Id standardPricebook = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntry = new PricebookEntry(
            Product2Id = unidade.Id,
        Pricebook2Id = standardPricebook,
        UnitPrice = 100,
        IsActive = true
            );
        insert pricebookEntry;
        
        Quote quote = new Quote(
            Name = 'Test Quote',
        OpportunityId = opportunity.Id,
        Pricebook2Id = standardPricebook
            );
        insert quote;
        
        QuoteLineItem quoteLineItem = new QuoteLineItem(
            QuoteId = quote.Id,
        Product2Id = unidade.Id,
        PricebookEntryId = pricebookEntry.Id,
        Quantity = 1,
        UnitPrice = 100
            );
        insert quoteLineItem;
        
        Test.startTest();
        Product2 product = QuoteDA.getProductByQuoteId(quote.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, product, 'O produto da cotação não deve ser nulo.');
    }
    
    @IsTest
    static void testGetQuoteLineItemsByQuoteId() {
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Product2 unidade = [SELECT Id FROM Product2 LIMIT 1];
        
        Id standardPricebook = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntry = new PricebookEntry(
            Product2Id = unidade.Id,
        Pricebook2Id = standardPricebook,
        UnitPrice = 100,
        IsActive = true
            );
        insert pricebookEntry;
        
        Quote quote = new Quote(
            Name = 'Test Quote',
        OpportunityId = opportunity.Id,
        Pricebook2Id = standardPricebook
            );
        insert quote;
        
        QuoteLineItem quoteLineItem = new QuoteLineItem(
            QuoteId = quote.Id,
        Product2Id = unidade.Id,
        PricebookEntryId = pricebookEntry.Id,
        Quantity = 1,
        UnitPrice = 100
            );
        insert quoteLineItem;
        
        Test.startTest();
        List<QuoteLineItem> lineItems = QuoteDA.getQuoteLineItemsByQuoteId(quote.Id);
        Test.stopTest();
        
        System.assertEquals(1, lineItems.size(), 'Deve haver 1 item de linha na cotação.');
        System.assertEquals(quote.Id, lineItems[0].QuoteId, 'O ID da cotação do item de linha deve corresponder ao ID da cotação.');
    }

    @IsTest
    static void testGetProductByQuoteId_NullScenario() {
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Id standardPricebook = Test.getStandardPricebookId();

        // Criando uma cotação sem associar um QuoteLineItem
        Quote quote = new Quote(
            Name = 'Test Quote',
            OpportunityId = opportunity.Id,
            Pricebook2Id = standardPricebook
        );
        insert quote;

        // Teste para validar o cenário onde não há QuoteLineItem associado
        Test.startTest();
        Product2 productNull = QuoteDA.getProductByQuoteId(quote.Id);
        Test.stopTest();

        // Validação do cenário nulo
        System.assertEquals(null, productNull, 'O produto da cotação deve ser nulo quando não há item de linha.');
    }
    
    @IsTest
    static void testGetOrCreatePricebookEntryId() {
        Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];
        
        Test.startTest();
        Id pbeId = QuoteDA.getOrCreatePricebookEntryId(testProduct.Id, null);
        Test.stopTest();
        
        System.assertNotEquals(null, pbeId, 'O ID do PricebookEntry não deve ser nulo.');
        PricebookEntry createdPBE = [SELECT Id FROM PricebookEntry WHERE Id = :pbeId];
        System.assertNotEquals(null, createdPBE, 'O registro do PricebookEntry deve existir.');
    }
}