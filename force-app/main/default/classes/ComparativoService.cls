public class ComparativoService {
    
    public class ComparacaoResultado {
        @AuraEnabled
        public String item { get; set; } 
        @AuraEnabled
        public Double valorTabela { get; set; }
        @AuraEnabled
        public Double valorProposta { get; set; }
        @AuraEnabled
        public Double diferenca { get; set; }
    }

    public static List<ComparacaoResultado> calcularComparacao(Id tabelaId, List<SeriePagamentos__c> proposta, Map<String, Object> valoresMatriz) {
        System.debug(proposta);


        TabelaVendas__c tabelaVenda = TabelaVendaSelector.obterTabelasRelacionadas(tabelaId);
        List<UnidadeTabelaVendas__c> tabelaVendaUnidades = TabelaVendaSelector.obterUnidadeTabelasPorId(tabelaId);
        System.debug('TabelaVendaUnidadesComparativa' +tabelaVendaUnidades);
        System.debug('matrizComparativa' +valoresMatriz);
        List<ComparacaoResultado> resultados = new List<ComparacaoResultado>();

        
        Decimal quantidadeParcelas = 0.0;
        Decimal quantidadeParcelasProp = 0.0;
        Decimal captacaoVistaTabela = 0.0;
        Decimal captacaoVistaProposta = 0.0;
        Decimal captacaoMensalTabela = 0.0;
        Decimal captacaoMensalProposta = 0.0;
        Decimal captacaoAteHabTabela = 0.0;
        Decimal captacaoAteHabProposta = 0.0;
        Decimal captacaoMetadeTabela = 0.0;
        Decimal captacaoMetadeProposta = 0.0;
        Decimal captacaoAposTabela = 0.0;
        Decimal captacaoAposProposta = 0.0;
        List<SeriePagamentos__c> series = SeriePagamentoSelector.obterSeriePagamentosPorInicioPagamento(tabelaId);
        for (SeriePagamentos__c s : series) {
            quantidadeParcelas += s.QuantidadeParcelas__c != null ? s.QuantidadeParcelas__c : 0;
            if (!s.AposHabiteSe__c) {
                captacaoAteHabTabela += s.ValorTotal__c != null ? s.ValorTotal__c : 0;
            }
            if (s.AposHabiteSe__c) {
                captacaoAposTabela += s.ValorTotal__c != null ? s.ValorTotal__c : 0; 
            }
        }
        for (SeriePagamentos__c s : proposta) {
            quantidadeParcelasProp += s.QuantidadeParcelas__c != null ? s.QuantidadeParcelas__c : 0;

            if (!s.AposHabiteSe__c) {
                captacaoAteHabProposta += s.ValorTotal__c != null ? s.ValorTotal__c : 0;
            }
            if (s.AposHabiteSe__c) {
                captacaoAposProposta += s.ValorTotal__c != null ? s.ValorTotal__c : 0; 
            }
        }
        

        for (SeriePagamentos__c s : series) {
        List<Decimal> parcelasTabela = SeriePagamentosService.calcularParcelas(s.ValorTotal__c, Integer.valueOf(s.QuantidadeParcelas__c));
        Decimal metadeTabela = s.QuantidadeParcelas__c / 2;
        for (Integer i = 0; i < metadeTabela; i++) {
        captacaoMetadeTabela += parcelasTabela[i];
        system.debug('Catacao metade tabela' +captacaoMetadeTabela);
            }
        }

        for (SeriePagamentos__c s : proposta) {
            List<Decimal> parcelasProposta = SeriePagamentosService.calcularParcelas(s.ValorTotal__c, Integer.valueOf(s.QuantidadeParcelas__c));
            Decimal metadeProposta = s.QuantidadeParcelas__c / 2;
        for (Integer i = 0; i < metadeProposta; i++) {
            captacaoMetadeProposta += parcelasProposta[i];
            system.debug('Catacao metade proposta' +captacaoMetadeProposta);
            }
        }

           
           ComparacaoResultado valorM2 = new ComparacaoResultado();
           valorM2.item = 'Valor do m²';
   
          
           valorM2.valorTabela = (tabelaVenda != null && tabelaVenda.Empreendimento__r != null && tabelaVenda.Empreendimento__r.ValorM__c != null) 
                         ? tabelaVenda.Empreendimento__r.ValorM__c 
                         : 0.0;
                         System.debug('Valor m2 tabela'+valorM2.valorTabela);
           if (tabelaVendaUnidades[0].MetragemUnidade__c == null) {
               valorM2.valorProposta = 0.0;
           } else {
               valorM2.valorProposta = tabelaVendaUnidades[0].PrecoLista__c/tabelaVendaUnidades[0].MetragemUnidade__c;
               
           }
           System.debug('Valor m2 proposta'+valorM2.valorProposta);
           System.debug('Valor Proposta'+ valorM2.valorProposta);
           valorM2.diferenca = valorM2.valorTabela - valorM2.valorProposta;
           System.debug('Valor Diferenca'+valorM2.diferenca);
           resultados.add(valorM2);
          
           System.debug('Resultados'+resultados);

        
        ComparacaoResultado captacaoAteMetadePrazo = new ComparacaoResultado();
        captacaoAteMetadePrazo.item = '% de Captação até metade do prazo';
        captacaoAteMetadePrazo.valorTabela = captacaoMetadeTabela;
        captacaoAteMetadePrazo.valorProposta = captacaoMetadeProposta;
        captacaoAteMetadePrazo.diferenca = captacaoAteMetadePrazo.valorTabela - captacaoAteMetadePrazo.valorProposta; 
        resultados.add(captacaoAteMetadePrazo);

        // 4.Captação até habite-se
        ComparacaoResultado captacaoAteHabiteSe = new ComparacaoResultado();
        captacaoAteHabiteSe.item = '% de Captação até habite-se';
        captacaoAteHabiteSe.valorTabela = captacaoAteHabTabela;
        captacaoAteHabiteSe.valorProposta = captacaoAteHabProposta;
        captacaoAteHabiteSe.diferenca = captacaoAteHabiteSe.valorTabela - captacaoAteHabiteSe.valorProposta;
        resultados.add(captacaoAteHabiteSe);


        // Captação após Habite-se
        ComparacaoResultado captacaoAposHabiteSe = new ComparacaoResultado();
        captacaoAposHabiteSe.item = '% de Captação após habite-se';
        captacaoAposHabiteSe.valorTabela = captacaoAposTabela;
        captacaoAposHabiteSe.valorProposta = captacaoAposProposta;
        captacaoAposHabiteSe.diferenca = captacaoAposHabiteSe.valorTabela - captacaoAposHabiteSe.valorProposta;
        resultados.add(captacaoAposHabiteSe);

        // Desconto nominal
        ComparacaoResultado descontoNominal = new ComparacaoResultado();
        Decimal nominalProposta = 0.0;
        Decimal vplProposta = 0.0;
        Decimal nominalTabela = 0.0;
        Decimal vplTabela = 0.0;
        
        if (valoresMatriz != null) {
            // Obtenção dos valores da proposta
            if (valoresMatriz.containsKey('nominalProposta')) {
                nominalProposta = valoresMatriz.get('nominalProposta') != null ? (Decimal) valoresMatriz.get('nominalProposta') : 0.0;
            } else {
                System.debug('Chave nominalProposta não encontrada na matriz');
            }
        
            if (valoresMatriz.containsKey('valorVplProposta')) {
                vplProposta = valoresMatriz.get('valorVplProposta') != null ? (Decimal) valoresMatriz.get('valorVplProposta') : 0.0;
            } else {
                System.debug('Chave valorVplProposta não encontrada na matriz');
            }
        
            // Obtenção dos valores da tabela
            if (valoresMatriz.containsKey('nominalTabela')) {
                nominalTabela = valoresMatriz.get('nominalTabela') != null ? (Decimal) valoresMatriz.get('nominalTabela') : 0.0;
            } else {
                System.debug('Chave nominalTabela não encontrada na matriz');
            }
        
            if (valoresMatriz.containsKey('valorVplTabela')) {
                vplTabela = valoresMatriz.get('valorVplTabela') != null ? (Decimal) valoresMatriz.get('valorVplTabela') : 0.0;
            } else {
                System.debug('Chave valorVplTabela não encontrada na matriz');
            }
        } else {
            System.debug('valoresMatriz null');
        }
        
        // Debug para verificar os valores
        System.debug('Captação até metade do prazo: ' + captacaoMetadeTabela);
        System.debug('Nominal Proposta: ' + nominalProposta);
        System.debug('Nominal Tabela: ' + nominalTabela);
        System.debug('Valor VPL Proposta: ' + vplProposta);
        System.debug('Valor VPL Tabela: ' + vplTabela);
        
        // Calcular os valores de nominal menos VPL
        Decimal propostaMenosVpl = nominalProposta - vplProposta;
        Decimal tabelaMenosVpl = nominalTabela - vplTabela;
        
        System.debug('Proposta - VPL Proposta: ' + propostaMenosVpl);
        System.debug('Tabela - VPL Tabela: ' + tabelaMenosVpl);
        
        // Definição dos valores de descontoNominal com base nos valores da matriz
        descontoNominal.item = 'Desconto Nominal';
        descontoNominal.valorTabela = tabelaMenosVpl;  // Usando valor da matriz (nominal - vpl) para tabela
        descontoNominal.valorProposta = propostaMenosVpl;  // Usando valor da matriz (nominal - vpl) para proposta
        descontoNominal.diferenca = descontoNominal.valorTabela - descontoNominal.valorProposta;
        
        resultados.add(descontoNominal);
        


        return resultados;
    }
}