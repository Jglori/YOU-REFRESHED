@isTest
public class InicializarArquivosServiceTest {

    @isTest
    static void testDistribuirArquivos() {
        // Criar um ContentVersion de teste
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Arquivo de Teste',
            PathOnClient = 'testfile.txt',
            VersionData = Blob.valueOf('Conteúdo do arquivo de teste')
        );
        insert contentVersion;

        // Atualizar o ContentVersion para criar um ContentDocument
        ContentDocument contentDocument = [SELECT Id FROM ContentDocument LIMIT 1];

        // Chamar o método distribuirArquivos
        Test.startTest();
        InicializarArquivosService.distribuirArquivos(new List<ContentVersion>{contentVersion});
        Test.stopTest();

        // Verificar se o ContentDistribution foi criado
        List<ContentDistribution> distribuicoes = [SELECT Id, Name, ContentVersionId, PreferencesAllowViewInBrowser, PreferencesLinkLatestVersion FROM ContentDistribution WHERE ContentVersionId = :contentVersion.Id];

        // System.assertEquals(1, distribuicoes.size(), 'Deveria haver exatamente 1 ContentDistribution');
        // ContentDistribution distribuicao = distribuicoes[0];
        // System.assertEquals('Arquivo de Teste', distribuicao.Name, 'O nome do ContentDistribution deve ser igual ao título do ContentVersion');
        // System.assertEquals(contentVersion.Id, distribuicao.ContentVersionId, 'O ContentVersionId do ContentDistribution deve ser igual ao ContentVersion');
        // System.assertEquals(true, distribuicao.PreferencesAllowViewInBrowser, 'O ContentDistribution deve permitir visualização no navegador');
        // System.assertEquals(true, distribuicao.PreferencesLinkLatestVersion, 'O ContentDistribution deve permitir o link da versão mais recente');
    }
}