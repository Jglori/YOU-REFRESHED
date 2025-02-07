public class ComparativoService {

    public class ComparacaoResultado {
        @AuraEnabled
        public String item { get; set; }
        @AuraEnabled
        public Decimal valorTabela { get; set; }
        @AuraEnabled
        public Decimal valorProposta { get; set; }
        @AuraEnabled
        public Decimal diferenca { get; set; }
    }

    public static List<ComparacaoResultado> calcularComparacao(Id tabelaId, List<SeriePagamentos__c> proposta, Map<String, Object> valoresMatriz, Product2 produtoSelecionado) {
        System.debug(proposta);
        System.debug(valoresMatriz);
        System.debug(tabelaId);
        System.debug(produtoSelecionado);

        TabelaVendas__c tabelaVenda = TabelaVendaSelector.obterTabelasRelacionadas(tabelaId);
        UnidadeTabelaVendas__c unidadeTabelaVendaProduto = UnidadeTabelaSelector.obterUnidadeTabelaVendaPorIdTabelaEIdProduto(tabelaId, produtoSelecionado.Id);

        List<ComparacaoResultado> resultados = new List<ComparacaoResultado>();

        System.debug(unidadeTabelaVendaProduto);
        System.debug(tabelaVenda);

        // Calculando o valor do m²
        ComparacaoResultado valorM2 = new ComparacaoResultado();
        valorM2.item = 'Valor do m²';

        if (tabelaVenda != null 
            && unidadeTabelaVendaProduto != null 
            && unidadeTabelaVendaProduto.PrecoLista__c != null 
            && unidadeTabelaVendaProduto.MetragemUnidade__c != null
            && valoresMatriz.containsKey('nominalTabela')) {

            valorM2.valorTabela = (Decimal) valoresMatriz.get('nominalTabela') / unidadeTabelaVendaProduto.MetragemUnidade__c;
        } else {
            valorM2.valorTabela = 0.0;
        }

        System.debug('Valor m² tabela: ' + valorM2.valorTabela);

        if (produtoSelecionado != null 
            && produtoSelecionado.MetragemTotal__c != null 
            && valoresMatriz.containsKey('nominalProposta') 
            && unidadeTabelaVendaProduto != null 
            && unidadeTabelaVendaProduto.MetragemUnidade__c != null) {

            valorM2.valorProposta = (Decimal) valoresMatriz.get('nominalProposta') / unidadeTabelaVendaProduto.MetragemUnidade__c;
        } else {
            valorM2.valorProposta = 0.0;
        }

        System.debug('Valor m² proposta: ' + valorM2.valorProposta);
        System.debug('Valor Proposta: ' + valorM2.valorProposta);

        // Calcular a diferença entre valorTabela e valorProposta
        valorM2.diferenca = valorM2.valorTabela - valorM2.valorProposta;
        System.debug('Valor Diferença: ' + valorM2.diferenca);

        // Adicionar o resultado na lista
        resultados.add(valorM2);

        System.debug('Resultados: ' + resultados);

        // Calculando a captação até metade do prazo
        ComparacaoResultado captacaoAteMetadePrazo = new ComparacaoResultado();
        captacaoAteMetadePrazo.item = '% de Captação até metade do prazo';

        List<SeriePagamentosService.ValorLinha> matrizMesaMesTabela = SeriePagamentosService.getListaGlobalTabela(tabelaId);
        Double valorTotalMetadeSeriesTabela = 0.0;

        for (Integer i = 0; i < matrizMesaMesTabela.size() / 2; i++) {
            valorTotalMetadeSeriesTabela += matrizMesaMesTabela[i].valorTotal;
        }

        captacaoAteMetadePrazo.valorTabela = valorTotalMetadeSeriesTabela / 100.0 * (Double) valoresMatriz.get('nominalTabela');

        List<SeriePagamentosService.ObjetoSerie> propostasConvertidas = new List<SeriePagamentosService.ObjetoSerie>();

        for (SeriePagamentos__c item : proposta) {
            SeriePagamentosService.ObjetoSerie obj = new SeriePagamentosService.ObjetoSerie();
            
            obj.valorTotal = item.ValorTotal__c;
            obj.quantidadeParcelas = (Integer) item.QuantidadeParcelas__c;
            obj.periodicidade = (Integer) item.Periodicidade__c;
            obj.inicioPagamento = (Integer) item.InicioPagamento__c;
            obj.tabelaVenda = tabelaId;
            obj.aposHabiteSe = item.AposHabiteSe__c;

            propostasConvertidas.add(obj);
        }

        List<SeriePagamentosService.ValorLinha> matrizMesaMesProposta = SeriePagamentosService.getListaGlobalProposta(tabelaId, propostasConvertidas, (Decimal) valoresMatriz.get('nominalProposta'));
        Double valorTotalMetadeSeriesProposta = 0.0;

        for (Integer i = 0; i < matrizMesaMesProposta.size() / 2; i++) {
            valorTotalMetadeSeriesProposta += matrizMesaMesProposta[i].valorTotal;
        }

        captacaoAteMetadePrazo.valorProposta = valorTotalMetadeSeriesProposta / 100.0 * (Double) valoresMatriz.get('nominalProposta');

        System.debug('vamo ver se funciona mesmo: ' + captacaoAteMetadePrazo.valorTabela);
        System.debug('vamo ver se funciona mesmo: ' + captacaoAteMetadePrazo.valorProposta);

        // Adicionar a comparação de captação até metade do prazo na lista
        resultados.add(captacaoAteMetadePrazo);

        System.debug('resultados comparativa: ' + resultados);
        return resultados;
    }
}