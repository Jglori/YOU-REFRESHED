@isTest
public class SeriePagamentoSelectorTest {
    
    @TestSetup
    static void makeData(){
        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendas();
        insert tabela;

        SeriePagamentos__c serie = TestDataFactory.gerarSeriePagamento(tabela.Id);
        serie.Restante__c = true;
        insert serie;
    }

    @isTest
    public static void testObterSeriePagamentosPorInicioPagamento(){
        TabelaVendas__c tabela = [SELECT Id FROM TabelaVendas__c LIMIT 1];

        Test.startTest();
        List<SeriePagamentos__c> resultado = SeriePagamentoSelector.obterSeriePagamentosPorInicioPagamento(tabela.Id);
        Test.stopTest();

        Assert.areEqual(true, resultado.size() > 0, 'O retorno da consulta deve ter 1 ou mais registros.');
    }

    @IsTest
    public static void testObterSeriePorId(){
        SeriePagamentos__c serie = [SELECT Id FROM SeriePagamentos__c LIMIT 1];

        Test.startTest();
        List<SeriePagamentos__c> resultado = SeriePagamentoSelector.obterSeriePorId(serie.Id);
        Test.stopTest();
        
        Assert.areEqual(true, resultado.size() > 0, 'O retorno da consulta deve ter 1 ou mais registros.');
    }

    @isTest
    public static void testObterSeriePorIdTabelaVendas(){
        TabelaVendas__c tabela = [SELECT Id FROM TabelaVendas__c LIMIT 1];      

        Test.startTest();
        List<SeriePagamentos__c> resultado = SeriePagamentoSelector.obterSeriePorIdTabelaVendas(tabela.Id);
        Test.stopTest();

        Assert.areEqual(true, resultado.size() > 0, 'O retorno da consulta deve ter 1 ou mais registros.');
    }

    @isTest
    public static void testObterSeriesPorIdTabela(){
        TabelaVendas__c tabela = [SELECT Id FROM TabelaVendas__c LIMIT 1];      

        Test.startTest();
        List<SeriePagamentos__c> resultado = SeriePagamentoSelector.obterSeriesPorIdTabela(tabela.Id);
        Test.stopTest();

        Assert.areEqual(true, resultado.size() > 0, 'O retorno da consulta deve ter 1 ou mais registros.');
    }

    
    @isTest
    public static void testObterSeriesPeloRestante(){
        TabelaVendas__c tabela = [SELECT Id FROM TabelaVendas__c LIMIT 1];      

        Test.startTest();
        List<SeriePagamentos__c> resultado = SeriePagamentoSelector.obterSeriesPeloRestante(new Set<Id>{tabela.Id});
        Test.stopTest();

        Assert.areEqual(true, resultado.size() > 0, 'O retorno da consulta deve ter 1 ou mais registros.');
    }
}