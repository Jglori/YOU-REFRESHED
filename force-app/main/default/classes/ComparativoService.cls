public class ComparativoService {

    @AuraEnabled(cacheable=false)

    // Método para comparar os valores da simulação com a tabela de vendas associada à oportunidade
    public static List<Map<String, Object>> compararTabelaEProposta(Id oppId, Map<String, Decimal> dadosSimulacao) {
        // Obter os dados da tabela de vendas associados à oportunidade
        Opportunity opp = TabelaVendaComparacao.obterTabelaPorId(oppId);

        List<Map<String, Object>> comparativo = new List<Map<String, Object>>();

        // Comparar Valor do m²
        comparativo.add(criarItemComparativo('Valor do m²', (Decimal) opp.get('ValorM2__c'), dadosSimulacao.get('ValorM2')));

         // Comparar Valor do m² a vista
        comparativo.add(criarItemComparativo('Valor do m²', (Decimal) opp.get('ValorM2__c'), dadosSimulacao.get('ValorM2aVista')));

        // Comparar Desconto Nominal
        comparativo.add(criarItemComparativo('Desconto Nominal', (Decimal) opp.get('DescontoNominalMoeda__c'), dadosSimulacao.get('DescontoNominal')));

        // Comparar Captação até metade do prazo da obra
        comparativo.add(criarItemComparativo('Captação até metade do prazo da obra', dadosSimulacao.get('CaptacaoMetadePrazoObraTabela'), dadosSimulacao.get('CaptacaoMetadePrazoObraProposta')));

        // Comparar Captação até habite-se
        comparativo.add(criarItemComparativo('Captação até habite-se', dadosSimulacao.get('CaptacaoAteHabiteSeTabela'), dadosSimulacao.get('CaptacaoAteHabiteSeProposta')));

        // Comparar Captação após habite-se
        comparativo.add(criarItemComparativo('Captação após habite-se',dadosSimulacao.get('CaptacaoAposHabiteSeTabela'), dadosSimulacao.get('CaptacaoAposHabiteSeProposta')));

        return comparativo;
    }

    // Método auxiliar para criar um item de comparação
    private static Map<String, Object> criarItemComparativo(String itemName, Decimal valorTabela, Decimal valorSimulacao) {
        Map<String, Object> itemComparativo = new Map<String, Object>();
        itemComparativo.put('Item', itemName);
        itemComparativo.put('Tabela', valorTabela != null ? 'R$ ' + valorTabela.format() : 'R$ 0.00');
        itemComparativo.put('Proposta', valorSimulacao != null ? 'R$ ' + valorSimulacao.format() : 'R$ 0.00');
        itemComparativo.put('Diferenca', (valorTabela != null && valorSimulacao != null) ? 'R$ ' + (valorTabela - valorSimulacao).format() : 'R$ 0.00');
        return itemComparativo;
    }
}
