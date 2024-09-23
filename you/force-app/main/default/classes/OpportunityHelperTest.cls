@isTest
private class OpportunityHelperTest {

    @isTest
    static void testSetDefaultCloseDate() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Nova Oportunidade';
        opp.StageName = 'Negociação';
        opp.CloseDate = null;

        List<Opportunity> opps = new List<Opportunity>{ opp };
        OpportunityHelper.addDaysToCloseDateOnCreation(opps);

        for (Opportunity o : opps) {
            System.assertEquals(Date.today().addDays(5), o.CloseDate, 'CloseDate should be set to today + 5 days');
        }
    }

    @isTest
    static void testValidateTransitionToFichaCadastral_AllFieldsFilled() {
        Account acc = createTestAccount();
        Contact corretorContact = createTestCorretorContact(); // Cria e insere o usuário
        Empreendimento__c empreendimento = createTestEnterprise(acc);
        Bloco__c bloco = createTestBloco(empreendimento);
        Product2 unidade = createTestProduct(empreendimento, bloco);

        Opportunity opp = new Opportunity(
            Name = 'Nova Oportunidade',
            StageName = 'Negociação',
            CloseDate = Date.today().addDays(5),
            Amount = 1000,
            AccountId = acc.Id,
            CanalAtendimento__c = 'WhatsApp',
            Probability = 20,
            TipoVenda__c = 'Negócio novo',
            Corretor__c = corretorContact.Id // Atribui o ID do usuário ao campo Corretor__c
        );
        insert opp;

        Quote quote = new Quote(
            OpportunityId = opp.Id,
            Name = 'Nova Cotação',
            Status = 'Aprovada',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert quote;

        opp.SyncedQuoteId = quote.Id;
        update opp;

        Product2 product = createTestProduct('Produto de Teste');
        PricebookEntry pricebookEntry = createTestPricebookEntry(product, quote.Pricebook2Id);

        QuoteLineItem quoteLineItem = new QuoteLineItem(
            QuoteId = quote.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert quoteLineItem;

        OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = quote.OpportunityId,
            ContactId = createTestCorretorContact().Id,
            Role = 'Fiador'
        );
        insert ocr;

        opp.StageName = 'Ficha Cadastral';
        update opp;

        List<Opportunity> opps = new List<Opportunity>{ opp };

        Test.startTest();
        OpportunityHelper.validateTransitionToFichaCadastral(opps, new Map<Id, Opportunity>{ opp.Id => opp });
        Test.stopTest();

        for (Opportunity o : opps) {
            System.assert(o.getErrors().isEmpty(), 'There should be no errors if all required fields are filled');
        }
    }

    @isTest
    static void testValidateTransitionToFichaCadastral_MissingRequiredFields() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Nova Oportunidade';
        opp.StageName = 'Negociação';
        opp.CloseDate = Date.today();
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Nova Oportunidade';
        opp2.StageName = 'Ficha Cadastral';
        opp2.CloseDate = Date.today();

        List<Opportunity> opps = new List<Opportunity>{ opp, opp2 };
        
        Test.startTest();
        OpportunityHelper.validateTransitionToFichaCadastral(opps, new Map<Id, Opportunity>{ opp.Id => opp });
        Test.stopTest();
    }
    
    private static Account createTestAccount() {
        Account acc = new Account(Name = 'first five');
        insert acc;
        return acc;
    }


    private static Contact createTestCorretorContact() {
      
        Account acc = new Account(Name = 'first ss', Type = 'HouseImobiliaria');
        insert acc;
    
        
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Corretor' LIMIT 1];
        if (rt == null) {
          System.debug('O tipo de registro "Corretor" não foi encontrado.');
        }
    
      
        Contact contact = new Contact(
            FirstName = 'fernandes',
            LastName = 'dantas',
            Email = 'dantas@elera.io',
            AccountId = acc.Id,
            RecordTypeId = rt.Id 
        );
    
        insert contact;
        return contact;
    }
    

    private static Empreendimento__c createTestEnterprise(Account acc) {
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Nome do Empreendimento',
            SPE__c = acc.Id,
            CNPJEmpreendimento__c = '25790394000150',
            TipoEmpreendimento__c = 'Casa',
            StatusObra__c = 'Entregue',
            MetragemPrivativaTotal__c = 5000,
            MetragemTerreno__c = 10000,
            MetragemConstruIdaM__c = 7000
        );
        insert empreendimento;
        return empreendimento;
    }

    private static Bloco__c createTestBloco(Empreendimento__c empreendimento) {
        Bloco__c bloco = new Bloco__c(
            Name = 'Nome do Bloco',
            DataLancamento__c = Date.today(),
            DataEntrega__c = Date.today().addMonths(12),
            Empreendimento__c = empreendimento.Id,
            QuantidadeAndares__c = 10,
            TotalUnidades__c = 50
        );
        insert bloco;
        return bloco;
    }

    private static Product2 createTestProduct(String productName) {
        Product2 product = new Product2(
            Name = productName,
            ProductCode = 'TestCode' + System.currentTimeMillis(),
            NumeroDaUnidade__c = 8,
            IsActive = true
        );
        insert product;
        return product;
    }

    private static Product2 createTestProduct(Empreendimento__c empreendimento, Bloco__c bloco) {
        Product2 unidade = new Product2(
            Name = 'Nome do Produto do Apartamento',
            ProductCode = '854785964',
            ExternalId = '10',
            Empreendimento__c = empreendimento.Id,
            Bloco__c = bloco.Id,
            NumeroDaUnidade__c = 10,
            ValorM2__c = 8
        );
        insert unidade;
        return unidade;
    }

    private static PricebookEntry createTestPricebookEntry(Product2 product, Id pricebookId) {
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pricebookEntry;
        return pricebookEntry;
    }
}