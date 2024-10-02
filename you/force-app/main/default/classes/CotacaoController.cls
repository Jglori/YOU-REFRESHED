public class CotacaoController {
    @AuraEnabled
    public static Map<String, Decimal> calcularTotalVPLTabela(Id idTabelaVendas){
        System.debug('idTabelaVendas: ' + idTabelaVendas);
        return SeriePagamentosService.setValorRealVPLTabelaVendas(idTabelaVendas);
    }

    @AuraEnabled
    public static Map<String, Decimal>  calcularTotalVPLProposta(Id idTabelaVendas, List<SeriePagamentosService.ObjetoSerie> objetosSeries, Decimal valorTotalProposta){
        Decimal valorPropostaValido = valorTotalProposta != null ? valorTotalProposta : 0.0;
        return SeriePagamentosService.setValorRealPropostaCliente(idTabelaVendas, objetosSeries, valorPropostaValido);   
    }

    @AuraEnabled
    public static List<SeriePagamentosService.ValorLinha> limparListasGlobais(){
       return SeriePagamentosService.limparListas();
    }
 
    @AuraEnabled
    public static List<SeriePagamentos__c> obterSeriesProposta(Id idCotacao){
        return SeriePagamentosService.seriesProposta(idCotacao);
    }

    @AuraEnabled
    public static Id criarTabelaDaSimulacao(List<SeriePagamentos__c> seriesDeProposta, Id idCotacao, String nomeCotacao, TabelaVendas__c tabelaSelecionada, Id unidadeSelecionadaId, Decimal nominalProposta){
        system.debug('unidadeSelecionadaId: ' + unidadeSelecionadaId);
        return TabelaVendasService.criarTabelaDaSimulacao(seriesDeProposta, idCotacao, nomeCotacao, tabelaSelecionada, unidadeSelecionadaId, nominalProposta);
    }

    @AuraEnabled
    public static List<TabelaVendas__c> cotacaoTabelaRelacionada(Id idCotacao){
        return SeriePagamentosService.cotacaoTabelaRelacionada(idCotacao);
    }
}