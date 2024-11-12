public class FieldTypeChecker {
    public static void checkFieldTypes() {
        Schema.DescribeSObjectResult leadDescribe = Lead.sObjectType.getDescribe();
        
        Schema.DescribeFieldResult quantidadeDeReiteracoesField = leadDescribe.fields.getMap().get('QuantidadeDeReiteracoes__c').getDescribe();
        Schema.DescribeFieldResult canalAtendimentoField = leadDescribe.fields.getMap().get('CanalAtendimento__c').getDescribe();
        
        String quantidadeDeReiteracoesType = quantidadeDeReiteracoesField.getType().name();
        String canalAtendimentoType = canalAtendimentoField.getType().name();
        
        System.debug('Tipo do campo QuantidadeDeReiteracoes__c: ' + quantidadeDeReiteracoesType);
        System.debug('Tipo do campo CanalAtendimento__c: ' + canalAtendimentoType);
    }
}