@isTest
public class ProdutoSelectorTest {


    
    @TestSetup
    static void makeData(){
        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();
        insert empreendimento;

        Product2 produto = TestDataFactory.gerarProduto();
        produto.Empreendimento__c = empreendimento.Id;
        insert produto;
    }

    @isTest
    public static void testGetProdutosById(){
        Product2 produto = [SELECT id FROM Product2 LIMIT 1];
        
        Test.startTest();
        Product2 resultado = ProdutoSelector.getProdutosById(produto.Id);
        Test.stopTest();

        Assert.areEqual(produto.Id, resultado.Id, 'Os ids dos produtos devem ser iguais');
    }

    @isTest
    public static void testCoeficienteProdutoPorId(){
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];

        Test.startTest();
        Map<Id, Product2> resultado = ProdutoSelector.coeficienteProdutoPorId(new List<Id>{produto.Id});
        Test.stopTest();

        Assert.areEqual(produto.Id, resultado.get(produto.Id).Id, 'Os ids devem ser iguais');
    }

    @isTest
    public static void testObterUnidadesRelacionadas(){
        Empreendimento__c empreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1];

        Test.startTest();
        Map<Id, Product2> resultado = ProdutoSelector.obterUnidadesRelacionadas(new Set<Id>{empreendimento.Id});
        Test.stopTest();

        Assert.areEqual(1, resultado.size(), 'O mapa deve conter apenas 1 produto');
    }

    @isTest
    public static void testBuscarUnidadePorSetId(){

        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];

        Test.startTest();
        Product2 resultado = ProdutoSelector.buscarUnidadePorSetId(new Set<Id>{produto.Id});
        Test.stopTest();

        Assert.areEqual(produto.Id, resultado.Id, 'Os ids devem ser iguais');
    }
}