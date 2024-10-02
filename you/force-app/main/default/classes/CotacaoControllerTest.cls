@isTest
public with sharing class CotacaoControllerTest {
    
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

        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendasCotacao(cotacao);
        insert tabela;

        SeriePagamentos__c seriesTabela = TestDataFactory.gerarSeriePagamento(tabela.Id);
        insert seriesTabela;

        UnidadeTabelaVendas__c unidadeTabela = TestDataFactory.gerarUnidadeTabelaVendas(tabela.id);
        insert unidadeTabela;

        Product2 produto = TestDataFactory.gerarProduto();
        insert produto;
    }

    @isTest
    public static void testCalcularTotalVPLTabela(){
        TabelaVendas__c tabela = [SELECT id FROM TabelaVendas__c LIMIT 1];
        
        Test.startTest();
        Map<String, Decimal> resultado = CotacaoController.calcularTotalVPLTabela(tabela.Id);
        Test.stopTest();

        Assert.areEqual(3000.00, resultado.get('valorVPL'), 'Os valores deve ser iguais');
    }

    @isTest
    public static void testCalcularTotalVPLProposta(){
        TabelaVendas__c tabela = [SELECT id FROM TabelaVendas__c LIMIT 1];

        SeriePagamentosService.ObjetoSerie objetoSerie = new SeriePagamentosService.ObjetoSerie();
        objetoSerie.id = 'serie01';
        objetoSerie.valorTotal = 1;
        objetoSerie.quantidadeParcelas = 1;
        objetoSerie.inicioPagamento = 1;
        objetoSerie.tabelaVenda = tabela.Id;
        objetoSerie.aposHabiteSe = false;

        Test.startTest();
        Map<String, Decimal> retornoValoresReaisProposta = CotacaoController.calcularTotalVPLProposta(tabela.Id,new List<SeriePagamentosService.ObjetoSerie>{objetoSerie}, 300000);
        Test.stopTest();

        Assert.areEqual(3000.00, retornoValoresReaisProposta.get('valorVPL'), 'Os valores devem ser iguais.');
    }

    @isTest
    public static void testLimparListasGlobais(){
        Test.startTest();
        List<SeriePagamentosService.ValorLinha> resutado = CotacaoController.limparListasGlobais();
        Test.stopTest();

        Assert.areEqual(0, resutado.size(), 'A lista deve estar vazia.');
    }

    @isTest
    public static void testObterSeriesProposta(){

        Quote cotacao = [SELECT Id, Name FROM Quote LIMIT 1];

        Test.startTest();
        List<SeriePagamentos__c> resultado = CotacaoController.obterSeriesProposta(cotacao.Id);
        Test.stopTest();

        Assert.areEqual(true, resultado.size() > 0, 'A lista deve conter os dados');
    }

    @isTest
    public static void testCriarTabelaDaSimulacao(){
        
        Quote cotacao = [SELECT Id, Name FROM Quote LIMIT 1];
        TabelaVendas__c tabelaSelecionada = [SELECT id, PeriodicidadeParcelaPos__c, PeriodicidadeParcela__c FROM TabelaVendas__c LIMIT 1];
        Product2 unidade = [SELECT id FROM Product2 LIMIT 1];
        List<SeriePagamentos__c> seriesProposta = new List<SeriePagamentos__c>();
        SeriePagamentos__c serie = TestDataFactory.gerarSeriePagamento(tabelaSelecionada.Id);
        seriesProposta.add(serie);
        Test.startTest();
        Id resultado = CotacaoController.criarTabelaDaSimulacao(seriesProposta, cotacao.Id, cotacao.Name, tabelaSelecionada, unidade.Id, 3000.00);
        Test.stopTest();

        Assert.areEqual(false, resultado == null, 'A id não pode ser null');
    }

    @isTest
    public static void testCotacaoTabelaRelacionada(){
        Quote cotacao = [SELECT Id, Name FROM Quote LIMIT 1];

        Test.startTest();
        List<TabelaVendas__c> resultado = CotacaoController.cotacaoTabelaRelacionada(cotacao.Id);
        Test.stopTest();

        Assert.areEqual(true, resultado.size() > 0, 'A lista deve conter dados');
    }

}