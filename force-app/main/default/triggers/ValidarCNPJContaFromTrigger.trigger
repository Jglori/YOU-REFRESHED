trigger ValidarCNPJContaFromTrigger on Account (before insert, before update) {

   for (Account acc: Trigger.new) {
        if (!String.isBlank(acc.CNPJ__c) && !ValidarCNPJ.validarCNPJ(acc.CNPJ__c)) { acc.addError('CNPJ inválido. Por favor, insira um CNPJ válido. O CNPJ deve ser preenchido com 14 dígitos corridos');    }
    }
}