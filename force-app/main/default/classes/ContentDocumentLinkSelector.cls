public without sharing class ContentDocumentLinkSelector {
    public static List<ContentDocumentLink> obterLinksPorIdsRegistrosRelacionados(Set<Id> idsRegistrosRelacionados){
        return [
            SELECT 
                ContentDocumentId, 
                LinkedEntityId,
                ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :idsRegistrosRelacionados
        ];
    }
}