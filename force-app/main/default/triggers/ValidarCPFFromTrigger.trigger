trigger ValidarCPFFromTrigger on Lead (before insert, before update) {
    for (Lead lead : Trigger.new) {
        if (!String.isBlank(lead.CPF__c) && !ValidarCPF.validarCPF(lead.CPF__c)) {lead.addError('CPF inválido. Por favor, insira um CPF válido.');}
    }
}