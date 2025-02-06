@isTest
private class ComparativoServiceTest {

    @isTest
    static void testCalcularComparacao() {

        // Criando e inserindo TabelaVendas__c diretamente
        TabelaVendas__c tabelaVenda = new TabelaVendas__c(
            Name = 'Teste', 
            PeriodicidadeParcelaPos__c = 1, 
            PeriodicidadeParcela__c = 1
        );
        insert tabelaVenda;

        // Criando e inserindo UnidadeTabelaVendas__c diretamente
        UnidadeTabelaVendas__c unidadeTabelaVendaProduto = new UnidadeTabelaVendas__c(
            Name = 'UnidadeVendaTeste',
            TabelaVenda__c = tabelaVenda.Id,
            PrecoLista__c = 300000
        );
        insert unidadeTabelaVendaProduto;

        // Criando e inserindo Produto2 diretamente
        Product2 produto = new Product2(
            AgenteFinanceiro__c = 'FII',
            Enquadramento__c = 'HIS',
            Andar__c = 10,
            Coeficiente__c = 0,
            NumeroQuartos__c = 2,
            NumeroDeSuites__c = 1,
            NumeroDeVagasIncorporadas__c = 1,
            Name = 'Produto de Teste',
            ProductCode = 'Teste-1',
            isActive = true,
            NumeroDaUnidade__c = 777,
            Status__c = 'Reservada',
            ValorM2__C = 8,
            ExternalId = '10'
        );
        insert produto;

        // Criando e inserindo SeriePagamentos__c diretamente
        SeriePagamentos__c seriePagamento = new SeriePagamentos__c(
            Name = 'Teste',
            InicioPagamento__c = 1,
            QuantidadeParcelas__c = 1,
            ValorTotal__c = 1,
            TabelaVenda__c = tabelaVenda.Id,
            TipoCondicao__c = 'Ato'
        );
        insert seriePagamento;

        // Criando valores fictícios para a matriz de valores
        Map<String, Object> valoresMatriz = new Map<String, Object>();
        valoresMatriz.put('nominalTabela', 5000.0);
        valoresMatriz.put('nominalProposta', 4500.0);

        // Chamando o método da classe ComparativoService
        List<ComparativoService.ComparacaoResultado> resultados = ComparativoService.calcularComparacao(
            tabelaVenda.Id,
            new List<SeriePagamentos__c>{seriePagamento},
            valoresMatriz,
            produto
        );

        // Validando os resultados esperados
        System.assertNotEquals(null, resultados, 'A lista de resultados não pode ser nula');
        System.assertEquals(1, resultados.size(), 'Deve retornar apenas um resultado');
        
        // Validando os valores específicos de comparação
        ComparativoService.ComparacaoResultado resultado = resultados[0];
        System.assertEquals('Valor do m²', resultado.item, 'O item comparado deve ser o valor do m²');
        System.assertNotEquals(null, resultado.valorTabela, 'O valor da tabela não pode ser nulo');
        System.assertNotEquals(null, resultado.valorProposta, 'O valor da proposta não pode ser nulo');
        System.assertNotEquals(null, resultado.diferenca, 'A diferença entre valores não pode ser nula');
    }
}