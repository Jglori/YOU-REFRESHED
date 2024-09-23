public with sharing class EmpreendimentoTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        for (Empreendimento__c emp : (List<Empreendimento__c>) Trigger.new) {
            String cnpj = emp.CNPJEmpreendimento__c;
            if (!EmpreendimentoHelper.validarCNPJ(cnpj)) {
                emp.addError('CNPJ inválido. Por favor, insira um CNPJ válido. O CNPJ deve ser preenchido com 14 dígitos corridos');
            }
        }
    }
    
    
       public override void beforeUpdate() {
        for (Empreendimento__c emp : (List<Empreendimento__c>) Trigger.new) {
            String cnpj = emp.CNPJEmpreendimento__c;
            if (!EmpreendimentoHelper.validarCNPJ(cnpj)) {
                emp.addError('CNPJ inválido. Por favor, insira um CNPJ válido. O CNPJ deve ser preenchido com 14 dígitos corridos');
            }
        }
    }
}