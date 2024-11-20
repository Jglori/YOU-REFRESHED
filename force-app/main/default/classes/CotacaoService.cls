public with sharing class CotacaoService {
    public static Quote atualizarCotacaoDaSimulacao(Quote cotacao){
        Quote cotacaoExistente = CotacaoSelector.getQuoteById(cotacao.Id);

        if(cotacaoExistente != null){
            cotacaoExistente.PorcentagemCaptacaoProposta__c = cotacao.PorcentagemCaptacaoProposta__c;
            cotacaoExistente.ValorNominalTabela__c = cotacao.ValorNominalTabela__c;
            cotacaoExistente.ValorNominalProposta__c = cotacao.ValorNominalProposta__c;
            cotacaoExistente.ValorVPLTabela__c = cotacao.ValorVPLTabela__c;
            cotacaoExistente.ValorVPLProposta__c = cotacao.ValorVPLProposta__c;
            cotacaoExistente.DiferencaNominalReal__c = cotacao.DiferencaNominalReal__c;
            cotacaoExistente.DiferencaNominalPorcentagem__c = cotacao.DiferencaNominalPorcentagem__c;
            cotacaoExistente.DiferencaVPLReal__c = cotacao.DiferencaVPLReal__c;
            cotacaoExistente.DiferencaVPLPorcentagem__c = cotacao.DiferencaVPLPorcentagem__c;
            update cotacaoExistente;
        }

        return cotacaoExistente;
    }
}