@isTest
public class UnidadeTabelaSelectorTest {
   
    @TestSetup
    static void makeData(){
        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendas();
        insert tabela;

        Product2 produto = TestDataFactory.gerarProduto();
        insert produto;

        UnidadeTabelaVendas__c unidade = TestDataFactory.gerarUnidadeTabelaVendas(tabela.Id);
        unidade.Unidade__c = produto.id;
        insert unidade;
    }

    @isTest
    public static void testObterUnidadeTabelaPorId(){
        TabelaVendas__c tabela = [SELECT Id FROM TabelaVendas__c LIMIT 1];

        Test.startTest();
        List<UnidadeTabelaVendas__c> unidades = UnidadeTabelaSelector.obterUnidadeTabelaPorId(tabela.Id);
        Test.stopTest();

        Assert.areEqual(true, unidades.size() > 0, 'O retorno da consulta deve ter 1 ou mais registros.');
    }

    @isTest
    public static void testObterUnidadesTabelaExistentes(){
        TabelaVendas__c tabela = [SELECT Id FROM TabelaVendas__c LIMIT 1];

        Test.startTest();
        Map<Id, UnidadeTabelaVendas__c> unidades = UnidadeTabelaSelector.obterUnidadesTabelaExistentes(new Set<id>{tabela.Id});
        Test.stopTest();

        Assert.areEqual(true, unidades.size() > 0, 'O retorno da consulta deve ter 1 ou mais registros.');
    }

    @isTest
    public static void testObterUnidadesTabelaPorIdUnidade(){
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];

        Test.startTest();
        UnidadeTabelaVendas__c resultado = UnidadeTabelaSelector.obterUnidadesTabelaPorIdUnidade(produto.Id);
        Test.stopTest();

        Assert.areEqual(produto.id, resultado.Unidade__c, 'Os Ids devem ser iguais.');
    }

    @isTest
    public static void testObterUnidadeTabelaVendaPorIdTabelaVendas(){
        UnidadeTabelaVendas__c unidadeTabela = [SELECT Id FROM UnidadeTabelaVendas__c LIMIT 1];

        Test.startTest();
        UnidadeTabelaVendas__c unidade = UnidadeTabelaSelector.obterUnidadeTabelaVendaPorIdTabelaVendas(unidadeTabela.Id);
        Test.stopTest();

        Assert.areEqual(true, unidade != null, 'O retorno da consulta deve ter 1 ou mais registros.');
    }
}