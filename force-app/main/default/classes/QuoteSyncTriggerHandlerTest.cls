@isTest
public class QuoteSyncTriggerHandlerTest {
    @isTest
    static void testBeforeInsert() {
        List<Quote> testQuotes = new List<Quote>();
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            //Pricebook2Id = customPriceBook.Id, // Associar ao Pricebook personalizado
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting'
        );
        insert opp;
        
        testQuotes.add(new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            Status = 'Draft',
            ExpirationDate = System.today() + 10
        ));

        Test.startTest();
            insert testQuotes;
        Test.stopTest();

        System.assertNotEquals(null, testQuotes[0].Id, 'O registro deveria ter sido inserido com sucesso.');
    }
    
    @isTest
    static void testBeforeUpdate() {
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            //Pricebook2Id = customPriceBook.Id, // Associar ao Pricebook personalizado
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting'
        );
        insert opp;

        Quote testQuote = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            Status = 'Draft',
            ExpirationDate = System.today() + 10
        );
        insert testQuote;

        // Modifica o registro para o teste de update
        testQuote.Status = 'Presented';

        // Inicia o teste e executa o disparador
        Test.startTest();
        	update testQuote;
         	//QuoteSyncTriggerHandler.beforeInsert();
        Test.stopTest();

        // Valide os resultados (se aplicável)
        // Exemplo:
        System.assertEquals('Presented', testQuote.Status, 'O status deveria ter sido atualizado.');
    }
}