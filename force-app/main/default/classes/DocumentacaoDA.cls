public with sharing class DocumentacaoDA {
    
    public static List<Documentacao__c> getById(Id id) {
        return [
            SELECT Id, Name, Contato__c, ContentDocumentId_c__c, Entregue__c, Validado__c
            FROM Documentacao__c
            WHERE Id = :id
        ];
    }

    public static List<Documentacao__c> getAllById(Set<Id> ids) {
        return [
            SELECT Id, Name, Contato__c, ContentDocumentId_c__c, Entregue__c, Validado__c
            FROM Documentacao__c
            WHERE Id IN :ids
        ];
    }

}