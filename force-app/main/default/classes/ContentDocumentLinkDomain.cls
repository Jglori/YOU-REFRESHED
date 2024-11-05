public class ContentDocumentLinkDomain {
    public static ContentDocumentLink obterLinkPorIdRegistroRelacionado(Id idRegistroRelacionado){
        List<ContentDocumentLink> links = ContentDocumentLinkSelector.obterLinksPorIdsRegistrosRelacionados(new Set<Id>{ idRegistroRelacionado });

        return links.isEmpty() ? new ContentDocumentLink() : links.get(0);
    }
}