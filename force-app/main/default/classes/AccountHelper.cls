public with sharing class AccountHelper {
    public static void verifyCNPJ(List<Account> accs) {
        for (Account acc : accs) {
            if (!acc.IsPersonAccount && !ValidarCNPJ.validarcnpj(acc.CNPJ__c)) {
                acc.addError('CNPJ inválido. Por favor, insira um CNPJ válido.');
            }
        }
    }

    public static void verifyCPF(List<Account> accs) {
        for (Account acc : accs) {
            if (acc.IsPersonAccount && !ValidarCPF.validarCPF(acc.CPF__pc)) {
                acc.addError('CPF inválido. Por favor, insira um CPF válido. O CPF deve ser preenchido com 11 dígitos corridos');
            }
        }
    }
}