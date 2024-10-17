public class ContratoService {
    public static String contratoText(Opportunity opp, TemplateDocumento__c template) {
        String text = template.ConteudoTemplate__c; 

        Empreendimento__c emp = EmpreendimentoSelector.getEmpreendimentoById(opp.Empreendimento__c); 
        Account conta = (Account) QueryHelper.selectAllFields('Account', opp.AccountId);
        Product2 prd = (Product2) QueryHelper.selectAllFields('Product2', opp.Unidade__c);
        Bloco__c bloco = (Bloco__c) QueryHelper.selectAllFields('Bloco__c', prd.Bloco__c);

        Map<String, Schema.SObjectField> oppFields = Schema.SObjectType.Opportunity.fields.getMap(); 
        Map<String, Schema.SObjectField> empFields = Schema.SObjectType.Empreendimento__c.fields.getMap(); 
        Map<String, Schema.SObjectField> acctFields = Schema.SObjectType.Account.fields.getMap(); 
        Map<String, Schema.SObjectField> blocoFields = Schema.SObjectType.Bloco__c.fields.getMap();
        Map<String, Schema.SObjectField> prdFields = Schema.SObjectType.Product2.fields.getMap();

        Map<String, Map<String, Schema.SObjectField>> tagFields = new Map<String, Map<String, Schema.SObjectField>>{
            'Opportunity.' => oppFields,
            'Empreendimento__r.' => empFields,
            'Account.' => acctFields,
            'Bloco__r.' => blocoFields,
            'Product2.' => prdFields
        };

        for (String tagPrefix : tagFields.keySet()) {
            Map<String, Schema.SObjectField> fieldsMap = tagFields.get(tagPrefix);

            for (String fieldName : fieldsMap.keySet()) {
                String apiName = fieldsMap.get(fieldName).getDescribe().getName();
                String fullTag = tagPrefix + apiName;

                if (text.contains(fullTag)) {
                    String fieldValue;

                    if (tagPrefix == 'Opportunity.') {
                        fieldValue = opp.get(apiName) == null ? 'N/A' : String.valueOf(opp.get(apiName));
                    } else if (tagPrefix == 'Empreendimento__r.' && emp != null) {
                        fieldValue = emp.get(apiName) == null ? 'N/A' : String.valueOf(emp.get(apiName));
                    } else if(tagPrefix == 'Account.' && conta != null) {
                        fieldValue = conta.get(apiName) == null ? 'N/A' : String.valueOf(conta.get(apiName));
                    } else if(tagPrefix == 'Bloco__r.' && bloco != null) {
                        fieldValue = bloco.get(apiName) == null ? 'N/A' : String.valueOf(bloco.get(apiName));
                    } else if(tagPrefix == 'Product2.' && prd != null) {
                        fieldValue = prd.get(apiName) == null ? 'N/A' : String.valueOf(prd.get(apiName));
                    } else {
                        fieldValue = 'N/A';
                    }
                    text = text.replace(fullTag, fieldValue);

                    System.debug('Texto atualizado: ' + text);
                }
            }
        }
        
        return text; 
    }
}
