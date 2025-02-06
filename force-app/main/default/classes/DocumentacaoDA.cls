public with sharing class DocumentacaoDA {
    
    public static Documentacao__c getById(Id id) {
        return [
            SELECT Id, Name, Contato__c, ContentDocumentId_c__c, Entregue__c, Validado__c
            FROM Documentacao__c
            WHERE Id = :id
        ];
    }

    public static List<Documento__mdt> getMetadasByName(Set<String> names) {
        return [
            SELECT Nome_do_Documento__c, Obrigatorio__c, Papel__c
            FROM Documento__mdt
            WHERE Nome_do_Documento__c IN :names
        ];
    }

    public static List<Documento__mdt> getMetadasByPapers(Set<String> papers) {
        return [
            SELECT Nome_do_Documento__c, Obrigatorio__c, Papel__c
            FROM Documento__mdt 
            WHERE Papel__c IN :papers
        ];
    }

    public static List<Documentacao__c> getAllById(Set<Id> ids) {
        return [
            SELECT Id, Name, Contato__c, ContentDocumentId_c__c, Entregue__c, Validado__c
            FROM Documentacao__c
            WHERE Id IN :ids
        ];
    }

    public static List<Documentacao__c> getAllDocumentsFromChecklist(Set<Id> idsOpp) {
        if (idsOpp == null || idsOpp.isEmpty()) {
            return new List<Documentacao__c>();
        }

        List<Documentacao__c> documents = new List<Documentacao__c>();

        for (Checklist_de_Documentos__c cklistDoc : ChecklistDA.getWithDocumentsByOpportunity( idsOpp )) {
            documents.add(
                new Documentacao__c(
                    Id = cklistDoc.Documenta_o__c,
                    Contato__c = cklistDoc.Documenta_o__r.Contato__c, 
                    Obrigatorio__c = cklistDoc.Documenta_o__r.Obrigatorio__c, 
                    Entregue__c = cklistDoc.Documenta_o__r.Entregue__c,
                    Name = cklistDoc.Documenta_o__r.Name,
                    DataEntrega__c = cklistDoc.Documenta_o__r.DataEntrega__c
                )
            );
        }

        return documents;
    }

}