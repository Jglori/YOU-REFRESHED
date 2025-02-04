public with sharing class ContatoHelper{

    public static void verifyCPF(List<Contact> contacts) {

        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
    
        for (Contact contact : contacts) {
            if (contact.RecordTypeId == recordTypeCliente) {
                if (String.isNotBlank(contact.CPF__c) && !ValidarCPF.validarCPF(contact.CPF__c)) {
                    contact.addError('CPF inválido. Por favor, insira um CPF válido. O CPF deve ser preenchido com 11 dígitos corridos');
                }
            } else {
                System.debug('Não é um cliente, portanto não valida o CPF.');
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