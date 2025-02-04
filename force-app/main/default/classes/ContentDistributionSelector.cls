public without sharing class ContentDistributionSelector {

    public static List<ContentDistribution> obterDistribuicoesPorIdsArquivos(Set<Id> idsArquivos) {
        return [
            SELECT 
                Id,
                Name,
                ContentVersion.VersionDataUrl,
                ContentVersion.Title,
                ContentDownloadUrl, 
                PdfDownloadUrl 
            FROM ContentDistribution 
            WHERE ContentVersionId IN :idsArquivos
        ];
    }

    public static ContentDistribution obterDistribuicaoParaURL(String idArquivo) {
        List<ContentDistribution> distribuicoes = [
            SELECT Id, Name, ContentDownloadUrl, ContentVersionId
            FROM ContentDistribution
            WHERE ContentVersionId = :idArquivo
            LIMIT 1
        ];

        return distribuicoes.isEmpty() ? null : distribuicoes[0];
    }

    public static ContentDistribution criarContentDistribution(ContentVersion contentVersion, String name) {
        List<ContentDistribution> existentes = [
            SELECT Id, ContentVersionId 
            FROM ContentDistribution 
            WHERE ContentVersionId = :contentVersion.Id
            LIMIT 1
        ];

        if (existentes.isEmpty()) {
            ContentDistribution contentDistribution = new ContentDistribution(
                Name = name,
                ContentVersionId = contentVersion.Id,
                PreferencesAllowViewInBrowser = true,
                PreferencesLinkLatestVersion = true
            );

            try {
                insert contentDistribution;
                return contentDistribution;
            } catch (DmlException e) {
                throw e;
            }
        } else {
            return existentes[0];
        }
    }
}