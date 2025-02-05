public with sharing class ComparativoController {
    @AuraEnabled(cacheable=true)
    public static List<Object> calcularComparacao(Id tabelaId, List<SeriePagamentos__c> proposta, Map<String, Object> valoresMatriz, String produto){
        
        system.debug('Produto serializado: ' + produto);
        Product2 produtoSelecionado = (Product2) JSON.deserialize(produto, Product2.class);
        system.debug('Produto desserializado: ' + produtoSelecionado);

        List<Object> resultado = ComparativoService.calcularComparacao(tabelaId, proposta, valoresMatriz, produtoSelecionado);
        System.debug(resultado);
        return resultado;
    }
}