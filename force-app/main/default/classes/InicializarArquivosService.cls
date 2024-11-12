public without sharing class InicializarArquivosService {
    public static void distribuirArquivos(List<ContentVersion> arquivos) {
        List<ContentDistribution> distribuicoesArquivos = new List<ContentDistribution>();
        for(ContentVersion arquivo : arquivos) {
            // Verifique se já existe um ContentDistribution com o mesmo ContentVersionId
            List<ContentDistribution> distribuicoesExistentes = [
                SELECT Id FROM ContentDistribution WHERE ContentVersionId = :arquivo.Id
            ];

            if (distribuicoesExistentes.isEmpty()) {
                distribuicoesArquivos.add(obterDistribuicaoArquivo(arquivo));
            } else {
                System.debug('ContentDistribution já existe para o ContentVersionId: ' + arquivo.Id);
            }
        }

        if(distribuicoesArquivos.isEmpty()) { return; }

        insert distribuicoesArquivos;
    }

    private static ContentDistribution obterDistribuicaoArquivo(ContentVersion arquivo) {
        return new ContentDistribution(
            Name = arquivo.Title,
            ContentVersionId = arquivo.Id,
            PreferencesAllowViewInBrowser = true,
            PreferencesLinkLatestVersion = true
        );
    }
}