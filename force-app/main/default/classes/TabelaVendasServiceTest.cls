@isTest
public class TabelaVendasServiceTest {
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
        tabela.Empreendimento__c = empreendimento.id;
        insert tabela;

        SeriePagamentos__c seriesTabela = TestDataFactory.gerarSeriePagamento(tabela.Id);
        insert seriesTabela;

        Product2 produto = TestDataFactory.gerarProduto();
        produto.Empreendimento__c = empreendimento.id;
        insert produto;

        UnidadeTabelaVendas__c unidadeTabela = TestDataFactory.gerarUnidadeTabelaVendas(tabela.id);
        unidadeTabela.Unidade__c = produto.id;
        insert unidadeTabela;
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
        Id resultado = TabelaVendasService.criarTabelaDaSimulacao(seriesProposta, cotacao.Id, cotacao.Name, tabelaSelecionada, unidade.Id, 3000.00);
        Test.stopTest();

        Assert.areEqual(false, resultado == null, 'A id não pode ser null');
    }

    @isTest
    public static void testInserirUnidadesTabelas(){
        List<TabelaVendas__c> tabelas = [SELECT id, Empreendimento__c FROM tabelaVendas__c ];

        Test.startTest();
        TabelaVendasService.inserirUnidadesTabelas(tabelas);
        Test.stopTest();
    }
}