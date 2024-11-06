public with sharing class ParametrizarCriteriosService {
    public static List<String> getVariacoesLimite() {
        List<String> variacoes = new List<String>();
        
        // Usando a API de esquema para acessar o Conjunto de Valores de Lista Global
        Schema.DescribeFieldResult camposResultado = ConjuntoCriteriosAnalise__c.VariacaoLimiteCaptacaoVista__c.getDescribe();
        List<Schema.PicklistEntry> valoresPicklist = camposResultado.getPicklistValues();
        
        for (Schema.PicklistEntry entry : valoresPicklist) {
            variacoes.add(entry.getLabel());
        }
        
        return variacoes;
    }

    // metodo para criar um novo registro
    public static void criarConjuntoCriterios(Object conjunto) {
        Map<String, Object> conjuntoCriteriosToMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(conjunto));
    
        // Agora você pode acessar os valores do mapa e fazer a atribuição
        ConjuntoCriteriosAnalise__c conjuntoCriterios = new ConjuntoCriteriosAnalise__c();
        
        conjuntoCriterios.valorNominal__c = (Decimal) conjuntoCriteriosToMap.get('nominal');
        conjuntoCriterios.VariacaoLimiteValorNominal__c = (String) conjuntoCriteriosToMap.get('nominalVariacao');
        conjuntoCriterios.ValorVpl__c = (Decimal) conjuntoCriteriosToMap.get('vpl');
        conjuntoCriterios.VariacaoLimiteValorVPL__c = (String) conjuntoCriteriosToMap.get('vplVariacao');
        conjuntoCriterios.ValorMetro__c = (Decimal) conjuntoCriteriosToMap.get('metro');
        conjuntoCriterios.VariacaoLimiteMetro__c = (String) conjuntoCriteriosToMap.get('metroVariacao');
        conjuntoCriterios.PrazoFinanciamento__c = (Decimal) conjuntoCriteriosToMap.get('prazo');
        conjuntoCriterios.VariacaoLimitePrazoFinanciamento__c = (String) conjuntoCriteriosToMap.get('prazoVariacao');
        conjuntoCriterios.CaptacaoVista__c = (Decimal) conjuntoCriteriosToMap.get('captacaoVista');
        conjuntoCriterios.VariacaoLimiteCaptacaoVista__c = (String) conjuntoCriteriosToMap.get('captacaoVistaVariacao');
        conjuntoCriterios.CaptacaoPosHabitaSe__c = (Decimal) conjuntoCriteriosToMap.get('captacaoPos');
        conjuntoCriterios.VariacaoLimiteCaptacaoPos__c = (String) conjuntoCriteriosToMap.get('captacaoPosVariacao');
        conjuntoCriterios.CaptacaoMensal__c = (Decimal) conjuntoCriteriosToMap.get('captacaoMensal');
        conjuntoCriterios.VariacaoLimiteCaptacaoMensal__c = (String) conjuntoCriteriosToMap.get('captacaoMensalVariacao');
    
        insert conjuntoCriterios;
    }
    
    public static List<Double> testarConjuntoCriterios(Decimal valorTabela, Decimal valorProposta) {
        Decimal valorDiferenca = valorTabela - valorProposta;
        Decimal valorDiferencaPorcentagem = (valorDiferenca / valorTabela);

        List<Decimal> valores = new List<Decimal>();
        valores.add(valorDiferenca);
        valores.add(valorDiferencaPorcentagem);
    
        return valores;
    }
}