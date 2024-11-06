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
        return [
            SELECT
                Id,
                Name,
                ContentDownloadUrl
            FROM ContentDistribution
            WHERE ContentVersionId = :idArquivo
            LIMIT 1 // Limitar a um registro para evitar erros em caso de múltiplas correspondências
        ];
    }
    
    // Método para criar um ContentDistribution
    public static ContentDistribution criarContentDistribution(ContentVersion contentVersion, String name) {
        List<ContentDistribution> existentes = [
            SELECT Id FROM ContentDistribution WHERE ContentVersionId = :contentVersion.Id
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
            } catch (DmlException e) {
                System.debug('Erro ao inserir ContentDistribution: ' + e.getMessage());
            }
            return contentDistribution;
        } else {
            System.debug('ContentDistribution já existe para este ContentVersion: ' + contentVersion.Id);
            return existentes[0];
        }
    }
}