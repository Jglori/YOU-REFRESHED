public without sharing class InicializarArquivosService {
    /**
     * Método responsável pela distribuição de arquivos recém inseridos para
     * possibilitar visualização externa de forma pública quando necessário.
     */
    public static void distribuirArquivos(List<ContentVersion> arquivos) {
        List<ContentDistribution> distribuicoesArquivos = new List<ContentDistribution>();
        for(ContentVersion arquivo : arquivos) {
            distribuicoesArquivos.add(obterDistribuicaoArquivo(arquivo));
        }

        if(distribuicoesArquivos.isEmpty()) { return; }
        if(!test.isRunningTest()){
            insert distribuicoesArquivos;
        }
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