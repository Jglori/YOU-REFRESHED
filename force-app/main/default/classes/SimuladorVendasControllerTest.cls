@isTest
public class SimuladorVendasControllerTest {
    
    @TestSetup
    static void makeData(){
        // Criar e inserir um Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c();
        empreendimento.Name = 'Empreendimento de Teste';
        empreendimento.CNPJEmpreendimento__c = '22151181000190';
        insert empreendimento;

        // Criar e inserir um Produto
        Product2 produto = new Product2();
        produto.Name = 'Produto de Teste';
        produto.ProductCode = 'Teste-1';
        produto.isActive = true;
        produto.NumeroDaUnidade__c = 777;
        produto.Status__c = 'Disponivel';
        insert produto;

        // Criar e inserir uma PricebookEntry
        PricebookEntry entradaPreco = new PricebookEntry();
        entradaPreco.Pricebook2Id = Test.getStandardPricebookId();
        entradaPreco.Product2Id = produto.Id;
        entradaPreco.UseStandardPrice = false;
        entradaPreco.UnitPrice = 100;
        entradaPreco.IsActive = true;
        insert entradaPreco;

        // Criar e inserir uma TabelaVendas associada ao Empreendimento
        TabelaVendas__c tabela = new TabelaVendas__c();
        tabela.Name = 'Teste';
        tabela.PeriodicidadeParcelaPos__c = 1;
        tabela.PeriodicidadeParcela__c = 1;
        tabela.Empreendimento__c = empreendimento.Id;
        insert tabela;
    }

    @isTest
    public static void testBuscarProdutoPorId(){

        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];

        Test.startTest();
        Product2 produtoBuscado = SimuladorVendasController.buscarProdutoPorId(produto.id);
        Test.stopTest();

        Assert.areEqual(produto.Id, produtoBuscado.Id, 'Os Ids devem ser os mesmos');
    }

    @isTest
    public static void testBuscarEntradaTabelaPrecoPorIdDeProduto(){

        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
       
        Test.startTest();
        PricebookEntry entrada = SimuladorVendasController.buscarEntradaTabelaPrecoPorIdDeProduto(produto.Id);
        Test.stopTest();

        Assert.areEqual(100, entrada.UnitPrice, 'Os valores devem ser iguais');
    }

    @isTest
    public static void testObterTabelasPorIdEmpreendimento(){
        Empreendimento__c  empreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1];

        Test.startTest();
        List<TabelaVendas__c> tabelas = SimuladorVendasController.obterTabelasPorIdEmpreendimento(empreendimento.Id);
        Test.stopTest();

        Assert.areEqual(1, tabelas.size(), 'A lista de tabelas deve ter 1 item');
    }

}