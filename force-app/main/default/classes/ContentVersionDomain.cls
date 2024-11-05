public class ContentVersionDomain {
    public static Map<Id, ContentVersion> obterArquivosPorIdRelacionado(Set<Id> idsArquivos) {
        List<ContentVersion> arquivos = ContentVersionSelector.obterArquivosPorIds(idsArquivos);

        return obterArquivosPorIdRelacionado(arquivos);
    }

    public static Map<Id, ContentVersion> obterArquivosPorIdRelacionado(List<ContentVersion> arquivos) {
        Map<Id, ContentVersion> arquivosPorIdRelacionado = new Map<Id, ContentVersion>();
        for(ContentVersion arquivo : arquivos) {
            arquivosPorIdRelacionado.put(arquivo.FirstPublishLocationId, arquivo);
        }

        return arquivosPorIdRelacionado;
    }
}