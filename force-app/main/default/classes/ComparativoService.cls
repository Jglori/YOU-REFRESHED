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

           ComparacaoResultado valorM2 = new ComparacaoResultado();
           valorM2.item = 'Valor do m²';
   
           valorM2.valorTabela = (tabelaVenda != null && unidadeTabelaVendaProduto.PrecoLista__c != null && unidadeTabelaVendaProduto.MetragemUnidade__c != null) 
                         ? (Decimal) valoresMatriz.get('nominalTabela') / unidadeTabelaVendaProduto.MetragemUnidade__c : 0.0;
                         
                         System.debug('Valor m2 tabela: '+ valorM2.valorTabela);

           if (produtoSelecionado == null || produtoSelecionado.MetragemTotal__c == null || (Decimal) valoresMatriz.get('nominalProposta') == null) {
               valorM2.valorProposta = 0.0;
           } else {
               valorM2.valorProposta = (Decimal) valoresMatriz.get('nominalProposta') / unidadeTabelaVendaProduto.MetragemUnidade__c;
           }
           System.debug('Valor m2 proposta: '+valorM2.valorProposta);
           System.debug('Valor Proposta'+ valorM2.valorProposta);

           valorM2.diferenca = valorM2.valorTabela - valorM2.valorProposta;
           System.debug('Valor Diferenca'+valorM2.diferenca);

           resultados.add(valorM2);
          
           System.debug('Resultados'+resultados);

        
        ComparacaoResultado captacaoAteMetadePrazo = new ComparacaoResultado();
        captacaoAteMetadePrazo.item = '% de Captação até metade do prazo';


    List<SeriePagamentosService.ValorLinha> matrizMesaMesTabela = SeriePagamentosService.getListaGlobalTabela(tabelaId);
    Double valorTotalMetadeSeriesTabela = 0.0;

    for(Integer i = 0; i < matrizMesaMesTabela.size()/2; i++){
        valorTotalMetadeSeriesTabela += matrizMesaMesTabela[i].valorTotal;
    }

    captacaoAteMetadePrazo.valorTabela =  valorTotalMetadeSeriesTabela/100.0 * (Double)valoresMatriz.get('nominalTabela');



    List<SeriePagamentosService.ObjetoSerie> propostasConvertidas = new List<SeriePagamentosService.ObjetoSerie>();

    for(SeriePagamentos__c item : proposta){
        SeriePagamentosService.ObjetoSerie obj = new SeriePagamentosService.ObjetoSerie();
        
        obj.valorTotal = item.ValorTotal__c;
        obj.quantidadeParcelas = (Integer)item.QuantidadeParcelas__c;
        obj.periodicidade = (Integer)item.Periodicidade__c;
        obj.inicioPagamento = (Integer)item.InicioPagamento__c;
        obj.tabelaVenda = tabelaId;
        obj.aposHabiteSe = item.AposHabiteSe__c;

        propostasConvertidas.add(obj);
    }

    List<SeriePagamentosService.ValorLinha> matrizMesaMesProposta = SeriePagamentosService.getListaGlobalProposta(tabelaId, propostasConvertidas, (Decimal)valoresMatriz.get('nominalProposta'));
    Double valorTotalMetadeSeriesProposta = 0.0;

    for(Integer i = 0; i < matrizMesaMesProposta.size()/2; i++){
        valorTotalMetadeSeriesProposta += matrizMesaMesProposta[i].valorTotal;
    }

    captacaoAteMetadePrazo.valorProposta =  valorTotalMetadeSeriesProposta/100.0 * (Double)valoresMatriz.get('nominalProposta');

    system.debug('vamo ver se funciona mesmo: ' + captacaoAteMetadePrazo.valorTabela);
    system.debug('vamo ver se funciona mesmo: ' + captacaoAteMetadePrazo.valorProposta);


        // system.debug('matriz mes a mes comparativa' + matrizMesAMes);
        

        // // 4.Captação até habite-se
        // ComparacaoResultado captacaoAteHabiteSe = new ComparacaoResultado();
        // captacaoAteHabiteSe.item = '% de Captação até habite-se';
        // captacaoAteHabiteSe.valorTabela = captacaoAteHabTabela;
        // captacaoAteHabiteSe.valorProposta = captacaoAteHabProposta;
        // captacaoAteHabiteSe.diferenca = captacaoAteHabiteSe.valorTabela - captacaoAteHabiteSe.valorProposta;
        // resultados.add(captacaoAteHabiteSe);


        // // Captação após Habite-se
        // ComparacaoResultado captacaoAposHabiteSe = new ComparacaoResultado();
        // captacaoAposHabiteSe.item = '% de Captação após habite-se';
        // captacaoAposHabiteSe.valorTabela = captacaoAposTabela;
        // captacaoAposHabiteSe.valorProposta = captacaoAposProposta;
        // captacaoAposHabiteSe.diferenca = captacaoAposHabiteSe.valorTabela - captacaoAposHabiteSe.valorProposta;
        // resultados.add(captacaoAposHabiteSe);

        // // Desconto nominal
        // ComparacaoResultado descontoNominal = new ComparacaoResultado();
        // Decimal nominalProposta = 0.0;
        // Decimal vplProposta = 0.0;
        // Decimal nominalTabela = 0.0;
        // Decimal vplTabela = 0.0;
        
        // if (valoresMatriz != null) {
        //     // Obtenção dos valores da proposta
        //     if (valoresMatriz.containsKey('nominalProposta')) {
        //         nominalProposta = valoresMatriz.get('nominalProposta') != null ? (Decimal) valoresMatriz.get('nominalProposta') : 0.0;
        //     } else {
        //         System.debug('Chave nominalProposta não encontrada na matriz');
        //     }
        
        //     if (valoresMatriz.containsKey('valorVplProposta')) {
        //         vplProposta = valoresMatriz.get('valorVplProposta') != null ? (Decimal) valoresMatriz.get('valorVplProposta') : 0.0;
        //     } else {
        //         System.debug('Chave valorVplProposta não encontrada na matriz');
        //     }
        
        //     // Obtenção dos valores da tabela
        //     if (valoresMatriz.containsKey('nominalTabela')) {
        //         nominalTabela = valoresMatriz.get('nominalTabela') != null ? (Decimal) valoresMatriz.get('nominalTabela') : 0.0;
        //     } else {
        //         System.debug('Chave nominalTabela não encontrada na matriz');
        //     }
        
        //     if (valoresMatriz.containsKey('valorVplTabela')) {
        //         vplTabela = valoresMatriz.get('valorVplTabela') != null ? (Decimal) valoresMatriz.get('valorVplTabela') : 0.0;
        //     } else {
        //         System.debug('Chave valorVplTabela não encontrada na matriz');
        //     }
        // } else {
        //     System.debug('valoresMatriz null');
        // }
        
        // // Debug para verificar os valores
        // System.debug('Captação até metade do prazo: ' + captacaoMetadeTabela);
        // System.debug('Nominal Proposta: ' + nominalProposta);
        // System.debug('Nominal Tabela: ' + nominalTabela);
        // System.debug('Valor VPL Proposta: ' + vplProposta);
        // System.debug('Valor VPL Tabela: ' + vplTabela);
        
        // // Calcular os valores de nominal menos VPL
        // Decimal propostaMenosVpl = nominalProposta - vplProposta;
        // Decimal tabelaMenosVpl = nominalTabela - vplTabela;
        
        // System.debug('Proposta - VPL Proposta: ' + propostaMenosVpl);
        // System.debug('Tabela - VPL Tabela: ' + tabelaMenosVpl);
        
        // // Definição dos valores de descontoNominal com base nos valores da matriz
        // descontoNominal.item = 'Desconto Nominal';
        // descontoNominal.valorTabela = tabelaMenosVpl;  // Usando valor da matriz (nominal - vpl) para tabela
        // descontoNominal.valorProposta = propostaMenosVpl;  // Usando valor da matriz (nominal - vpl) para proposta
        // descontoNominal.diferenca = descontoNominal.valorTabela - descontoNominal.valorProposta;
        
        // resultados.add(descontoNominal);
        

        system.debug('resultados comparativa: ' + resultados);
        return resultados;
    }
}