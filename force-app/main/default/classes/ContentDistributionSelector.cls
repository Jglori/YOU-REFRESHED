public without sharing class ContentDistributionSelector {
    public static List<ContentDistribution> obterDistribuicoesPorIdsArquivos(Set<Id> idsArquivos) {
        return [
            SELECT 
                Name,
                ContentVersion.VersionDataUrl,
                ContentVersion.Title,
                ContentDownloadUrl, 
                PdfDownloadUrl 
            FROM ContentDistribution 
            WHERE ContentVersionId IN :idsArquivos
        ];
    }
    
    public static ContentDistribution obterDistribuicaoParaURL(String idArquivo){
        return [
            SELECT
                Name,
                ContentDownloadUrl
            FROM ContentDistribution
            WHERE ContentVersionId = :idArquivo
        ];
    }
}