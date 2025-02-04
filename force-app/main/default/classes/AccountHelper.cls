public with sharing class AccountHelper {
    public static void verifyCNPJ(List<Account> accs) {
        // Obter RecordTypeId dinamicamente para contas jurídicas
        Id recordTypeIdJuridica = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Conta').getRecordTypeId();

        for (Account acc : accs) {
            System.debug('Conta: ' + acc);
            if (acc.RecordTypeId == recordTypeIdJuridica && String.isNotBlank(acc.CNPJ__c) && !ValidarCNPJ.validarcnpj(acc.CNPJ__c)) {
                acc.addError('CNPJ inválido. Por favor, insira um CNPJ válido.');
            }
        }
    }

    public static void verifyCPF(List<Account> accs) {
        Id recordTypeIdFisica = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Conta pessoal').getRecordTypeId();
        Id recordTypeIdJuridica = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Conta').getRecordTypeId();

        System.debug('RecordTypeIdJuridica linha 18: ' + recordTypeIdJuridica);
        for (Account acc : accs) {
            System.debug('RecordTypeId: ' + acc.RecordTypeId);
            System.debug('Conta: ' + acc);
            if (acc.RecordTypeId.equals(recordTypeIdFisica)) {
                System.debug('CPF: ' + acc.CPF__pc);
                System.debug('RecordType id na linha 24 ' + acc.RecordTypeId);
                if (String.isNotBlank(acc.CPF__pc) && !ValidarCPF.validarCPF(acc.CPF__pc)) {
                    acc.addError('CPF inválido. Por favor, insira um CPF válido. O CPF deve ser preenchido com 11 dígitos corridos');
                }
            }
        }
    }
}