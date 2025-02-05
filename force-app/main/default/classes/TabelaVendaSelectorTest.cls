@isTest
public with sharing class TabelaVendaSelectorTest {
    
    @TestSetup
    static void makeData(){
        Account contaParaContato = TestDataFactory.gerarConta('HouseImobiliaria');
        insert contaParaContato;
        
        Account contaParaOportunidade = TestDataFactory.gerarConta();
        insert contaParaOportunidade;

        Id recordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Corretor').getRecordTypeId();
    
        Contact contato = TestDataFactory.gerarContato(contaParaContato, recordTypeId);
        insert contato;

        Opportunity oportunidade = TestDataFactory.gerarOportunidade(contaParaOportunidade, contato);
        insert oportunidade;

        Quote cotacao = TestDataFactory.gerarCotacao(oportunidade);
        insert cotacao;

        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();
        insert empreendimento;

        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendasCotacao(cotacao);
        tabela.Empreendimento__c = empreendimento.Id;
        insert tabela;

        SeriePagamentos__c seriesTabela = TestDataFactory.gerarSeriePagamento(tabela.Id);
        insert seriesTabela;

        UnidadeTabelaVendas__c unidadeTabela = TestDataFactory.gerarUnidadeTabelaVendas(tabela.id);
        insert unidadeTabela; 
    }

    @isTest
    public static void testObterUnidadeTabelasPorId(){
        TabelaVendas__c tabela = [SELECT Id FROM TabelaVendas__c LIMIT 1];
        
        Test.startTest();
        List<UnidadeTabelaVendas__c> resultado = TabelaVendaSelector.obterUnidadeTabelasPorId(tabela.Id);
        Test.stopTest();
        
        Assert.areEqual(true, resultado.size() > 0, 'O retorno da consulta deve ter 1 ou mais registros.');
    }

    @isTest
    public static void testObterTabelasRelacionadas(){
        TabelaVendas__c tabela = [SELECT Id FROM TabelaVendas__c LIMIT 1];
        
        Test.startTest();
        TabelaVendas__c resultado = TabelaVendaSelector.obterTabelasRelacionadas(tabela.Id);
        Test.stopTest();
        
        Assert.areEqual(tabela.Id, resultado.Id, 'Os ids devem ser iguais.');
    }

    @isTest
    public static void testObterTabelasPorIdEmpreendimento(){
        Empreendimento__c empreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1];
        
        Test.startTest();
        List<TabelaVendas__c> resultado = TabelaVendaSelector.obterTabelasPorIdEmpreendimento(empreendimento.Id);
        Test.stopTest();
        
        Assert.areEqual(true, resultado.size() > 0, 'O retorno da consulta deve ter 1 ou mais registros.');
    }

    @isTest
    public static void testObterCotacaoRelacionada(){
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        
        Test.startTest();
        List<TabelaVendas__c> resultado = TabelaVendaSelector.obterCotacaoRelacionada(qt.Id);
        Test.stopTest();
        
        Assert.areEqual(true, resultado.size() > 0, 'O retorno da consulta deve ter 1 ou mais registros.');
    }

    @isTest
    public static void testBuscarTabelaPorIdCotacao(){
        Quote qt = [SELECT Id FROM Quote LIMIT 1];
        
        Test.startTest();
        TabelaVendas__c resultado = TabelaVendaSelector.buscarTabelaPorIdCotacao(qt.Id);
        Test.stopTest();
        
        Assert.areEqual(true, resultado != null, 'O resultado não pode ser nulo.');
    }

    
}