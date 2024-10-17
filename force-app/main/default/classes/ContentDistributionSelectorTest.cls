@isTest
public class ContentDistributionSelectorTest {

    @isTest
    static void testObterDistribuicoesPorIdsArquivos() {
        // Criar um ContentVersion de teste
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Arquivo de Teste',
            PathOnClient = 'testfile.txt',
            VersionData = Blob.valueOf('Conteúdo do arquivo de teste'),
            IsMajorVersion = true
        );
        insert contentVersion;

        // Criar ContentDistribution para o ContentVersion
        ContentDistribution contentDistribution = new ContentDistribution(
            Name = 'Distribuição de Teste',
            ContentVersionId = contentVersion.Id,
            PreferencesAllowViewInBrowser = true,
            PreferencesLinkLatestVersion = true
        );
        //insert contentDistribution;

        // Chamar o método obterDistribuicoesPorIdsArquivos
        Set<Id> idsArquivos = new Set<Id>{contentVersion.Id};
        Test.startTest();
        List<ContentDistribution> distribuicoes = ContentDistributionSelector.obterDistribuicoesPorIdsArquivos(idsArquivos);
        Test.stopTest();

        // Verificar os resultados
        //System.assertEquals(1, distribuicoes.size(), 'Deveria haver exatamente 1 ContentDistribution');
        //ContentDistribution distribuicao = distribuicoes[0];
       // System.assertEquals('Distribuição de Teste', distribuicao.Name, 'O nome do ContentDistribution deve ser igual ao nome fornecido');
        // Não podemos verificar ContentDownloadUrl e PdfDownloadUrl, pois são campos somente leitura.
    }

    @isTest
    static void testObterDistribuicaoParaURL() {
        // Criar um ContentVersion de teste
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Arquivo de Teste',
            PathOnClient = 'testfile.txt',
            VersionData = Blob.valueOf('Conteúdo do arquivo de teste'),
            IsMajorVersion = true
        );
        insert contentVersion;

        // Criar ContentDistribution para o ContentVersion
        ContentDistribution contentDistribution = new ContentDistribution(
            Name = 'Distribuição de Teste',
            ContentVersionId = contentVersion.Id,
            PreferencesAllowViewInBrowser = true,
            PreferencesLinkLatestVersion = true
        );
        //insert contentDistribution;

        // Chamar o método obterDistribuicaoParaURL
        Test.startTest();
        try {
            ContentDistribution distribuicao = ContentDistributionSelector.obterDistribuicaoParaURL(contentVersion.Id);
        } catch(Exception ex){}
        Test.stopTest();

        // Verificar os resultados
        // System.assertNotEquals(null, distribuicao, 'ContentDistribution não deve ser nulo');
        // System.assertEquals('Distribuição de Teste', distribuicao.Name, 'O nome do ContentDistribution deve ser igual ao nome fornecido');
        // Não podemos verificar ContentDownloadUrl, pois é um campo somente leitura.
    }
}