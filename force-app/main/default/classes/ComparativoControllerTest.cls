@isTest
public class ComparativoControllerTest {

    @isTest
    public static void testCalcularComparacao() {
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

        // Criar o Mapa de valoresMatriz
        Map<String, Object> valoresMatriz = new Map<String, Object>();
        valoresMatriz.put('nominalTabela', 10000.0);
        valoresMatriz.put('nominalProposta', 9500.0);

        // Serializar o Produto
        String produtoJson = JSON.serialize(produto);

        // Chamar o método do controlador
        Test.startTest();
        List<Object> resultado = ComparativoController.calcularComparacao(tabelaVenda.Id, new List<SeriePagamentos__c>{seriePagamento}, valoresMatriz, produtoJson);
        Test.stopTest();

        // Verificar o resultado
        System.assertNotEquals(null, resultado, 'O resultado não pode ser nulo');
        System.assertEquals(2, resultado.size(), 'Deve haver dois itens no resultado (valor do m² e captação até metade do prazo)');
    }
}