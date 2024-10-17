public without sharing class ContentVersionSelector {
    public static List<ContentVersion> obterArquivosPorIds(Set<Id> idsArquivos) {
        return [
            SELECT
                VersionDataUrl,
                FirstPublishLocationId
            FROM ContentVersion
            WHERE Id IN :idsArquivos
        ];
    }

    public static List<ContentVersion> obterArquivoParaURL(){
        return [
            SELECT
                VersionDataUrl,
                Title,
                FileType
            FROM ContentVersion
            ORDER BY CreatedDate DESC LIMIT 1];
    }
}