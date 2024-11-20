public class CotacaoSelector {
    public static Quote getQuoteById(Id quoteId) {
        return [SELECT Id, PorcentagemCaptacaoProposta__c, ValorNominalTabela__c, ValorNominalProposta__c, 
        ValorVPLTabela__c, ValorVPLProposta__c, DiferencaNominalReal__c, DiferencaNominalPorcentagem__c, DiferencaVPLReal__c,
        DiferencaVPLPorcentagem__c FROM Quote WHERE Id = :quoteId];
    }
}