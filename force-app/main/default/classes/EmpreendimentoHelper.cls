public with sharing class EmpreendimentoHelper {
    public static void verifyEmpreendimentoCNPJ(List<Empreendimento__c> emps) {
        for (Empreendimento__c emp : emps) {
            if (!ValidarCNPJ.validarcnpj(emp.CNPJEmpreendimento__c)) {
                emp.addError('CNPJ inválido. Por favor, insira um CNPJ válido.');
            }
        }
    }
}