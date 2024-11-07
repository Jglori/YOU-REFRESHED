@IsTest
public class QuoteLineItemTriggerTest {
    
    @IsTest
    static void testSingleQuoteLineItemInsert() {
        // Criação de uma conta de teste
        Account testAccount = TestDataFactory.gerarConta();
        insert testAccount;

        // Criação de uma oportunidade
        Opportunity testOpportunity = TestDataFactory.gerarOportunidade(testAccount, TestDataFactory.gerarContato(testAccount));
        insert testOpportunity;

        // Criação de uma cotação
        Quote testQuote = TestDataFactory.gerarCotacao(testOpportunity);
        insert testQuote;

        // Criação de um produto
        Product2 testProduct = TestDataFactory.gerarProduto();
        insert testProduct;

        // Criação de uma entrada de preço (PricebookEntry)
        PricebookEntry testPricebookEntry = TestDataFactory.gerarPricebookEntry(testProduct.Id);
        insert testPricebookEntry;

        // Criação do item de linha de cotação (QuoteLineItem)
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = testQuote.Id,
            PricebookEntryId = testPricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100
        );

        Test.startTest();
        insert qli;
        Test.stopTest();

        // Validação: um item deve ser permitido
        System.assertEquals(1, [SELECT COUNT() FROM QuoteLineItem WHERE QuoteId = :testQuote.Id], 'Apenas um item de linha de cotação deve ser permitido.');
    }

    @IsTest
    static void testMultipleQuoteLineItemsInsert() {
        // Preparação de dados para o teste
        Account testAccount = TestDataFactory.gerarConta();
        insert testAccount;

        Opportunity testOpportunity = TestDataFactory.gerarOportunidade(testAccount, TestDataFactory.gerarContato(testAccount));
        insert testOpportunity;

        Quote testQuote = TestDataFactory.gerarCotacao(testOpportunity);
        insert testQuote;

        Product2 testProduct = TestDataFactory.gerarProduto();
        insert testProduct;

        PricebookEntry testPricebookEntry = TestDataFactory.gerarPricebookEntry(testProduct.Id);
        insert testPricebookEntry;

        // Inserção do primeiro item de linha de cotação (deve ser permitido)
        QuoteLineItem qli1 = new QuoteLineItem(
            QuoteId = testQuote.Id,
            PricebookEntryId = testPricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100
        );

        Test.startTest();
        insert qli1;
        Test.stopTest();

        // Tentativa de inserção de um segundo item de linha de cotação (deve falhar)
        QuoteLineItem qli2 = new QuoteLineItem(
            QuoteId = testQuote.Id,
            PricebookEntryId = testPricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100
        );

        try {
            Test.startTest();
            insert qli2;
            Test.stopTest();
            System.assert(false, 'Não deveria permitir a inserção de mais de um item de linha de cotação para uma cotação.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Não é permitido adicionar mais de um produto à cotação.'), 
                'A mensagem de erro esperada não foi retornada.');
        }
    }

    @IsTest
    static void testUpdateQuoteLineItem() {
        // Preparação de dados para o teste
        Account testAccount = TestDataFactory.gerarConta();
        insert testAccount;

        Opportunity testOpportunity = TestDataFactory.gerarOportunidade(testAccount, TestDataFactory.gerarContato(testAccount));
        insert testOpportunity;

        Quote testQuote = TestDataFactory.gerarCotacao(testOpportunity);
        insert testQuote;

        Product2 testProduct = TestDataFactory.gerarProduto();
        insert testProduct;

        PricebookEntry testPricebookEntry = TestDataFactory.gerarPricebookEntry(testProduct.Id);
        insert testPricebookEntry;

        // Criação do item de linha de cotação
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = testQuote.Id,
            PricebookEntryId = testPricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert qli;

        // Atualização do item de linha de cotação existente (deve ser permitido)
        qli.Quantity = 2;

        Test.startTest();
        update qli;
        Test.stopTest();

        QuoteLineItem updatedQLI = [SELECT Quantity FROM QuoteLineItem WHERE Id = :qli.Id];
        System.assertEquals(2, updatedQLI.Quantity, 'A quantidade do item de linha de cotação deveria ter sido atualizada para 2.');
    }
}