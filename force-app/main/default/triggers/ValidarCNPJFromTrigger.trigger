trigger ValidarCNPJFromTrigger on Lead (before insert, before update) {
    for (Lead lead : Trigger.new) {
        if (!String.isBlank(lead.CNPJ__c) && !ValidarCNPJ.validarcnpj(lead.CNPJ__c)) { lead.addError('CNPJ inválido. Por favor, insira um CNPJ válido.');}
    }
}