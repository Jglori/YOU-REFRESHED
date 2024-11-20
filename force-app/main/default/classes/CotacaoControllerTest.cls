@isTest
public with sharing class CotacaoControllerTest {
    
    @TestSetup
    static void makeData(){
        Account contaParaContato = TestDataFactory.gerarConta('HouseImobiliaria');
        insert contaParaContato;
        
        Account contaParaOportunidade = TestDataFactory.gerarConta();
        insert contaParaOportunidade;

        Id recordTypeId = '012Dw0000001hHDIAY';
        Contact contato = TestDataFactory.gerarContato(contaParaContato, recordTypeId);
        insert contato;

        Opportunity oportunidade = TestDataFactory.gerarOportunidade(contaParaOportunidade, contato);
        insert oportunidade;

        Quote cotacao = TestDataFactory.gerarCotacao(oportunidade);
        insert cotacao;

        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendas(cotacao);
        insert tabela;

        SeriePagamentos__c seriesTabela = TestDataFactory.gerarSeriePagamento(tabela.Id);
        insert seriesTabela;

        UnidadeTabelaVendas__c unidadeTabela = TestDataFactory.gerarUnidadeTabelaVendas(tabela.id);
        insert unidadeTabela;
    }

    @isTest
    public static void testCalcularTotalVPLTabela(){
        TabelaVendas__c tabela = [SELECT id FROM TabelaVendas__c LIMIT 1];
        
        Test.startTest();
        Map<String, Decimal> resultado = CotacaoController.calcularTotalVPLTabela(tabela.Id);
        Test.stopTest();

        System.debug(resultado);
    }

}