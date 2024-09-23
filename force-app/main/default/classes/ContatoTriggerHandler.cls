public with sharing class ContatoTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        for (Contact ctt : (List<Contact>) Trigger.new) {
            String cpf = ctt.CPF__c;
            if (String.isNotBlank(cpf) && !ContatoHelper.validarCPF(cpf)) {
                ctt.addError('CPF inválido. Por favor, insira um CPF válido. O CPF deve ser preenchido com 11 dígitos corridos');
            }
        }
    }
    
    
       public override void beforeUpdate() {
        for (Contact ctt : (List<Contact>) Trigger.new) {
            String cpf = ctt.CPF__c;
            if (String.isNotBlank(cpf) && !ContatoHelper.validarCPF(cpf)) {
                ctt.addError('CPF inválido. Por favor, insira um CPF válido. O CPF deve ser preenchido com 11 dígitos corridos');
            }
        }
    }
}