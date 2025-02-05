@isTest
public class EntradaTabelaPrecoSelectorTest {
    
    @TestSetup
    static void makeData(){
        Product2 produto = TestDataFactory.gerarProduto();
        insert produto;

        PricebookEntry entrada = TestDataFactory.gerarPricebookEntry(produto.Id);
        insert entrada;
    }

    @isTest
    public static void testGetEntradaTabelaPrecoByProdutoId(){
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        Test.startTest();
        PricebookEntry entrada = EntradaTabelaPrecoSelector.getEntradaTabelaPrecoByProdutoId(produto.id);
        Test.stopTest();

        Assert.areEqual(100, entrada.UnitPrice, 'Os valores devem ser iguais');
    }
}