@isTest
private class QuoteTriggerHandlerTest {

    @TestSetup
    static void makeData() {
        // Criar Account
        Account account = new Account(Name = 'Test Account');
        insert account;

        // Criar Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Nome do Empreendimento',
            SPE__c = account.Id, 
            CNPJEmpreendimento__c = '25790394000150',
            TipoEmpreendimento__c = 'Casa',
            StatusObra__c = 'Entregue',
            MetragemPrivativaTotal__c = 5000,
            MetragemTerreno__c = 10000,
            MetragemConstruIdaM__c = 7000
        );
        insert empreendimento;

        // Criar Bloco
        Bloco__c bloco = new Bloco__c(
            Name = 'Nome do Bloco',
            DataLancamento__c = Date.today(),
            DataEntrega__c = Date.today().addMonths(12),
            Empreendimento__c = empreendimento.Id,
            QuantidadeAndares__c = 10,
            TotalUnidades__c = 50
        );
        insert bloco;

        // Criar Unidade
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

        // Criar Opportunity
        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = account.Id,
            CloseDate = System.today().addDays(30),
            StageName = 'Negociacao'
        );
        insert opportunity;

        // Criar Cotações
        List<Quote> quotes = new List<Quote>();

        // Criar cotação aprovada
        Quote approvedQuote = new Quote(
            Name = 'Test Quote Approved',
            OpportunityId = opportunity.Id,
            Status = 'Aprovada'
        );
        quotes.add(approvedQuote);

        // Criar cotação não aprovada
        Quote draftQuote = new Quote(
            Name = 'Test Quote Draft',
            OpportunityId = opportunity.Id,
            Status = 'Draft'
        );
        quotes.add(draftQuote);

        insert quotes;
    }

    @isTest
    static void testUpdateOpportunitiesFromQuotes_WhenQuotesApproved() {
        List<Quote> newQuotes = [SELECT Id, Status, OpportunityId FROM Quote WHERE Status = 'Approved'];
        Map<Id, Quote> oldMap = new Map<Id, Quote>();
        for (Quote quote : newQuotes) {
            oldMap.put(quote.Id, new Quote(Id = quote.Id, Status = 'Draft'));
        }

        Test.startTest();
        Test.stopTest();

        List<Opportunity> updatedOpportunities = [SELECT Id, Amount, SyncedQuoteId FROM Opportunity WHERE Id IN (SELECT OpportunityId FROM Quote WHERE Status = 'Approved')];
        System.assertNotEquals(0, updatedOpportunities.size(), 'Deve haver oportunidades atualizadas após a aprovação das cotações');
    }

    @isTest
    static void testUpdateOpportunitiesFromQuotes_WhenQuotesNotApproved() {
        List<Quote> newQuotes = [SELECT Id, Status, OpportunityId FROM Quote WHERE Status = 'Draft'];
        Map<Id, Quote> oldMap = new Map<Id, Quote>();
        for (Quote quote : newQuotes) {
            oldMap.put(quote.Id, new Quote(Id = quote.Id, Status = 'Aprovada'));
        }

        Test.startTest();
        QuoteHelper.updateOpportunitiesFromQuotes(newQuotes, oldMap);
        Test.stopTest();

        List<Opportunity> updatedOpportunities = [SELECT Id, Amount, SyncedQuoteId, Empreendimento__c FROM Opportunity WHERE Id IN (SELECT OpportunityId FROM Quote WHERE Status = 'Draft')];
    }
}