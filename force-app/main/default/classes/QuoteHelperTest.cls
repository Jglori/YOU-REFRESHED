@IsTest
public class QuoteHelperTest {

    @TestSetup
    static void makeData() {
        // Criação de uma conta
        Account account = new Account(Name = 'Test Account');
        insert account;

        // Criação de um Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Nome do Empreendimento',
            CNPJEmpreendimento__c = '12345678000195',
            SPE__c = account.Id
        );
        insert empreendimento;

        // Criação de um Produto (Unidade)
        Product2 unidade = new Product2(
            Name = 'Produto Teste',
            ProductCode = 'TestCode123',
            NumeroDaUnidade__c = 5,
            Empreendimento__c = empreendimento.Id
        );
        insert unidade;

        // Obter o Pricebook Padrão
        Id standardPricebook = Test.getStandardPricebookId();
        
        // Criar PricebookEntry
        PricebookEntry pricebookEntry = new PricebookEntry(
            Product2Id = unidade.Id,
            Pricebook2Id = standardPricebook,
            UnitPrice = 100,
            IsActive = true
        );
        insert pricebookEntry;

        // Criação de uma Oportunidade
        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = account.Id,
            CloseDate = System.today().addDays(30),
            StageName = 'Negociação'
        );
        insert opportunity;

        // Criação de uma Cotação
        Quote quote = new Quote(
            Name = 'Test Quote',
            OpportunityId = opportunity.Id,
            Pricebook2Id = standardPricebook,
            Status = 'Draft'
        );
        insert quote;

        // Criação de um QuoteLineItem
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = quote.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 2,
            UnitPrice = 2500
        );
        insert qli;
    }

    @IsTest
    static void testUpdateOpportunitiesFromQuotes_Approved() {
        // Recuperar cotações e simular aprovação
        List<Quote> newQuotes = [SELECT Id, OpportunityId, Status, GrandTotal FROM Quote LIMIT 1];
        Map<Id, Quote> oldMap = new Map<Id, Quote>();
        for (Quote quote : newQuotes) {
            oldMap.put(quote.Id, new Quote(Id = quote.Id, Status = 'Em aprovaçãoaft'));
        }

        // Atualizando a cotação para status 'Approved'
        for (Quote quote : newQuotes) {
            quote.Status = 'Aprovada';
        }

        // Executar o teste
        Test.startTest();
        QuoteHelper.updateOpportunitiesFromQuotes(newQuotes, oldMap);
        Test.stopTest();

        // Verificar que a oportunidade foi atualizada corretamente
        Opportunity updatedOpportunity = [SELECT Id, Amount, SyncedQuoteId FROM Opportunity WHERE Id = :newQuotes[0].OpportunityId];
        System.assertEquals(5000, updatedOpportunity.Amount, 'O valor da oportunidade deve ser atualizado com o GrandTotal da cotação.');
        System.assertEquals(newQuotes[0].Id, updatedOpportunity.SyncedQuoteId, 'A SyncedQuoteId deve ser atualizada com a cotação.');
    }

    @IsTest
    static void testUpdateOpportunitiesFromQuotes_NotApproved() {
        // Teste quando a cotação não é aprovada
        List<Quote> newQuotes = [SELECT Id, OpportunityId, Status, GrandTotal FROM Quote LIMIT 1];
        Map<Id, Quote> oldMap = new Map<Id, Quote>();
        for (Quote quote : newQuotes) {
            oldMap.put(quote.Id, new Quote(Id = quote.Id, Status = 'Aprovada'));
        }

        // Executar o teste sem alterar o status
        Test.startTest();
        QuoteHelper.updateOpportunitiesFromQuotes(newQuotes, oldMap);
        Test.stopTest();

        // Verificar que a oportunidade não foi atualizada
        Opportunity opportunity = [SELECT Id, Amount, SyncedQuoteId FROM Opportunity WHERE Id = :newQuotes[0].OpportunityId];
        System.assertEquals(null, opportunity.SyncedQuoteId, 'A SyncedQuoteId não deve ser atualizada quando a cotação não é aprovada.');
    }

    @IsTest
    static void testAddQuoteProductsToOpportunities() {
        // Obter cotações para adicionar produtos à oportunidade
        List<Quote> newQuotes = [SELECT Id FROM Quote LIMIT 1];
        List<Id> quoteIds = new List<Id>();
        for (Quote quote : newQuotes) {
            quoteIds.add(quote.Id);
        }

        // Executar o teste para adicionar produtos
        Test.startTest();
        QuoteHelper.addQuoteProductsToOpportunities(quoteIds);
        Test.stopTest();

        // Verificar se os OpportunityLineItems foram adicionados
        List<OpportunityLineItem> oppLineItems = [SELECT Id, OpportunityId, Quantity, UnitPrice FROM OpportunityLineItem WHERE OpportunityId IN (SELECT OpportunityId FROM Quote WHERE Id IN :quoteIds)];
        System.assertNotEquals(0, oppLineItems.size(), 'Os OpportunityLineItems devem ser adicionados com sucesso.');
    }

    @IsTest
    static void testUpdateOpportunitiesFromQuotes_NoQuoteChanges() {
        // Testar o cenário onde não há mudanças nas cotações
        List<Quote> newQuotes = [SELECT Id, OpportunityId, Status FROM Quote LIMIT 1];
        Map<Id, Quote> oldMap = new Map<Id, Quote>();
        for (Quote quote : newQuotes) {
            oldMap.put(quote.Id, new Quote(Id = quote.Id, Status = quote.Status));
        }

        // Executar o teste sem mudança de status
        Test.startTest();
        QuoteHelper.updateOpportunitiesFromQuotes(newQuotes, oldMap);
        Test.stopTest();

        // Verificar que nada foi atualizado
        Opportunity opportunity = [SELECT Id, SyncedQuoteId FROM Opportunity WHERE Id = :newQuotes[0].OpportunityId];
        System.assertEquals(null, opportunity.SyncedQuoteId, 'A SyncedQuoteId não deve ser alterada se não houver mudanças na cotação.');
    }
}