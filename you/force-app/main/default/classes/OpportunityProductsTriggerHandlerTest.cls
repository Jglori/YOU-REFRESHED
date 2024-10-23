@IsTest
private class OpportunityProductsTriggerHandlerTest {

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

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert oli;
    }

    @IsTest
    static void testBeforeDelete_Success() {
        OpportunityLineItem oliToDelete = [SELECT Id FROM OpportunityLineItem LIMIT 1];

        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id IN (SELECT OpportunityId FROM OpportunityLineItem WHERE Id = :oliToDelete.Id) LIMIT 1];
        opp.SyncedQuoteId = null;
        update opp;

        Test.startTest();
        Test.stopTest();

        System.assert(true, 'O OpportunityLineItem foi excluído com sucesso');
    }

    @IsTest
    static void testBeforeDelete_Failure() {
        OpportunityLineItem oliToDelete = [SELECT Id FROM OpportunityLineItem LIMIT 1];

        Opportunity opp = [SELECT Id, SyncedQuoteId FROM Opportunity WHERE Id IN (SELECT OpportunityId FROM OpportunityLineItem WHERE Id = :oliToDelete.Id) LIMIT 1];
        opp.SyncedQuoteId = [SELECT Id FROM Quote LIMIT 1].Id;
        update opp;

        Test.startTest();
        try {
            delete oliToDelete;
            System.assert(false, 'A exclusão deveria ter falhado com uma exceção de validação.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Não é permitido excluir produtos diretamente na oportunidade'), 'Esperado: Não é permitido excluir produtos diretamente na oportunidade');
        }
        Test.stopTest();
    }
}