@isTest
public with sharing class SeriePagamentosServiceTest {
    
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
    }

    @isTest
    public static void testSetValorRealVPLTabelaVendas(){
        TabelaVendas__c tabela = [SELECT id FROM TabelaVendas__c LIMIT 1];
        Test.startTest();
        Map<String, Decimal> retornoValoresReaisVPL = SeriePagamentosService.setValorRealVPLTabelaVendas(tabela.Id);
        Test.stopTest();

        Assert.areEqual(3000.00, retornoValoresReaisVPL.get('valorVPL'), 'Os valores devem ser iguais.');
    }

    @isTest
    public static void testSetValorRealPropostaCliente(){
        TabelaVendas__c tabela = [SELECT id FROM TabelaVendas__c LIMIT 1];

        SeriePagamentosService.ObjetoSerie objetoSerie = new SeriePagamentosService.ObjetoSerie();
        objetoSerie.id = 'serie01';
        objetoSerie.valorTotal = 1;
        objetoSerie.quantidadeParcelas = 1;
        objetoSerie.inicioPagamento = 1;
        objetoSerie.tabelaVenda = tabela.Id;
        objetoSerie.aposHabiteSe = false;

        Test.startTest();
        Map<String, Decimal> retornoValoresReaisProposta = SeriePagamentosService.setValorRealPropostaCliente(tabela.Id,new List<SeriePagamentosService.ObjetoSerie>{objetoSerie}, 300000);
        Test.stopTest();

        Assert.areEqual(3000.00, retornoValoresReaisProposta.get('valorVPL'), 'Os valores devem ser iguais.');
    }

    @IsTest
    public static void testSeriesProposta() {
        Quote cotacao = [SELECT id FROM Quote LIMIT 1];
        Test.startTest();
        List<SeriePagamentos__c> retornoSeriesProposta = SeriePagamentosService.seriesProposta(cotacao.Id);
        Test.stopTest();

        List<SeriePagamentos__c> expected = [
            SELECT 
                Id,
                ValorTotal__c,
                QuantidadeParcelas__c,
                Periodicidade__c,
                InicioPagamento__c,
                TabelaVenda__c,
                AposHabiteSe__c,
                Restante__c,
                TipoCondicao__c
            FROM SeriePagamentos__c 
            WHERE TabelaVenda__c =: [
                SELECT
                    Id
                FROM TabelaVendas__c
                LIMIT 1
            ].Id
        ];

        Assert.areEqual(expected, retornoSeriesProposta, 'Os valores devem ser iguais.');
    }
}