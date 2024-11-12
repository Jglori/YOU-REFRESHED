public with sharing class ContatoHelper{

    public static void verifyCPF(List<Contact> contacts) {
        for (Contact contact : contacts) {
            if (!ValidarCPF.validarCPF(contact.CPF__c)) {
                contact.addError('CPF inválido. Por favor, insira um CPF válido. O CPF deve ser preenchido com 11 dígitos corridos');
            }
        }
    }

    public static void handleStatusCorretor(List<Contact> contacts) {
        for (Contact contact : contacts) {
            if (contact.StatusUsuarioCorretor__c == 'Congelado') {
                contact.StatusCorretor__c = 'Suspenso';
            } else if (contact.StatusUsuarioCorretor__c == 'Desativado') {
                contact.StatusCorretor__c = 'Desligado';
            }
        }
    }

    public static void handleCRECIStatus(List<Contact> contacts) {
        Date dataAtual = Date.today();
        
        for (Contact contact : contacts) {
            if (contact.DatadeVencimento__c != null) {                
                if (contact.DatadeVencimento__c >= dataAtual) {
                    contact.CRECIAtivo__c = true;
                } else {
                    contact.CRECIAtivo__c = false;
                }
            }
        }
    }
}