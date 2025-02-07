@isTest
public with sharing class CotacaoControllerTest {
    
    @TestSetup
    static void makeData(){
        // Criando as contas
        Account contaParaContato = new Account(Name = 'HouseImobiliaria');
        insert contaParaContato;

        Account contaParaOportunidade = new Account(Name = 'Conta de Teste');
        insert contaParaOportunidade;

        // Criando o contato
        Id recordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Corretor').getRecordTypeId();
        Contact contato = new Contact(AccountId = contaParaContato.Id, LastName = 'Teste', RecordTypeId = recordTypeId);
        insert contato;

        // Criando a oportunidade
        Opportunity oportunidade = new Opportunity(Name = 'Teste', AccountId = contaParaOportunidade.Id, StageName = 'Negociação', CloseDate = System.today().addDays(15));
        insert oportunidade;

        // Criando a cotação
        Quote cotacao = new Quote(Name = 'Teste', OpportunityId = oportunidade.Id);
        insert cotacao;

        // Criando a tabela de vendas
        TabelaVendas__c tabela = new TabelaVendas__c(Name = 'Teste', PeriodicidadeParcelaPos__c = 1, PeriodicidadeParcela__c = 1, Cotacao__c = cotacao.Id);
        insert tabela;

        // Criando a série de pagamentos
        SeriePagamentos__c seriesTabela = new SeriePagamentos__c(Name = 'Teste', TabelaVenda__c = tabela.Id, InicioPagamento__c = 1, QuantidadeParcelas__c = 1, ValorTotal__c = 1, TipoCondicao__c = 'Ato');
        insert seriesTabela;

        // Criando a unidade da tabela de vendas
        UnidadeTabelaVendas__c unidadeTabela = new UnidadeTabelaVendas__c(Name = 'UnidadeVendaTeste', TabelaVenda__c = tabela.Id, PrecoLista__c = 300000);
        insert unidadeTabela;

        // Criando o produto
        Product2 produto = new Product2(Name = 'Produto de Teste', ProductCode = 'Teste-1', isActive = true, NumeroDaUnidade__c = 777, Status__c = 'Disponivel');
        insert produto;
    }

    @isTest
    public static void testCalcularTotalVPLTabela(){
        TabelaVendas__c tabela = [SELECT id FROM TabelaVendas__c LIMIT 1];
        
        Test.startTest();
        Map<String, Decimal> resultado = CotacaoController.calcularTotalVPLTabela(tabela.Id);
        Test.stopTest();

        Assert.areEqual(3000.00, resultado.get('valorVPL'), 'Os valores devem ser iguais');
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
        Map<String, Decimal> retornoValoresReaisProposta = CotacaoController.calcularTotalVPLProposta(tabela.Id, new List<SeriePagamentosService.ObjetoSerie>{objetoSerie}, 300000);
        Test.stopTest();

        Assert.areEqual(3000.00, retornoValoresReaisProposta.get('valorVPL'), 'Os valores devem ser iguais.');
    }

    @isTest
    public static void testLimparListasGlobais(){
        Test.startTest();
        List<SeriePagamentosService.ValorLinha> resultado = CotacaoController.limparListasGlobais();
        Test.stopTest();

        Assert.areEqual(0, resultado.size(), 'A lista deve estar vazia.');
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
        SeriePagamentos__c serie = new SeriePagamentos__c(Name = 'Teste', TabelaVenda__c = tabelaSelecionada.Id, InicioPagamento__c = 1, QuantidadeParcelas__c = 1, ValorTotal__c = 1, TipoCondicao__c = 'Ato');
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