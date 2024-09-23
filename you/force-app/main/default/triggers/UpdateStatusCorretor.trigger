trigger UpdateStatusCorretor on Contact (before insert, before update) {
    for (Contact contact : Trigger.new) {
        if (contact.StatusUsuarioCorretor__c == 'Congelado') {
            contact.StatusCorretor__c = 'Suspenso';
        } else if (contact.StatusUsuarioCorretor__c == 'Desativado') {
            contact.StatusCorretor__c = 'Desligado';
        }
    }
}