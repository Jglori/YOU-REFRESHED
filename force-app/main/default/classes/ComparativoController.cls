public with sharing class ComparativoController {
    @AuraEnabled(cacheable=true)
    public static List<Object> calcularComparacao(Id tabelaId, List<SeriePagamentos__c> proposta, Map<String, Object> valoresMatriz){
        List<Object> resultado = ComparativoService.calcularComparacao(tabelaId, proposta, valoresMatriz);
        System.debug(resultado);
        return resultado;
    }
}