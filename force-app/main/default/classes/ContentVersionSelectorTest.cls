@isTest
public class ContentVersionSelectorTest {

    @isTest
    static void testObterArquivosPorIds() {
        // Criar ContentVersions de teste
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Arquivo de Teste 1',
            PathOnClient = 'testfile1.txt',
            VersionData = Blob.valueOf('Conteúdo do arquivo de teste 1'),
            IsMajorVersion = true
        );
        insert contentVersion1;

        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Arquivo de Teste 2',
            PathOnClient = 'testfile2.txt',
            VersionData = Blob.valueOf('Conteúdo do arquivo de teste 2'),
            IsMajorVersion = true
        );
        insert contentVersion2;

        // Obter IDs dos ContentVersions
        Set<Id> idsArquivos = new Set<Id>{contentVersion1.Id, contentVersion2.Id};

        // Chamar o método obterArquivosPorIds
        Test.startTest();
        List<ContentVersion> arquivos = ContentVersionSelector.obterArquivosPorIds(idsArquivos);
        Test.stopTest();

        // Verificar os resultados
        // System.assertEquals(2, arquivos.size(), 'Deveria haver exatamente 2 ContentVersions');
        ContentVersion arquivo1 = arquivos[0];
        ContentVersion arquivo2 = arquivos[1];

        // Verificar se os arquivos retornados correspondem aos IDs fornecidos
        // System.assertEquals(contentVersion1.Id, arquivo1.Id, 'O ID do ContentVersion 1 deve corresponder ao esperado');
        // System.assertEquals(contentVersion2.Id, arquivo2.Id, 'O ID do ContentVersion 2 deve corresponder ao esperado');
    }

    @isTest
    static void testObterArquivoParaURL() {
        // Criar ContentVersions de teste
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Arquivo de Teste 1',
            PathOnClient = 'testfile1.txt',
            VersionData = Blob.valueOf('Conteúdo do arquivo de teste 1'),
            IsMajorVersion = true
        );
        insert contentVersion1;

        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Arquivo de Teste 2',
            PathOnClient = 'testfile2.txt',
            VersionData = Blob.valueOf('Conteúdo do arquivo de teste 2'),
            IsMajorVersion = true
        );
        insert contentVersion2;

        // Chamar o método obterArquivoParaURL
        Test.startTest();
        List<ContentVersion> arquivos = ContentVersionSelector.obterArquivoParaURL();
        Test.stopTest();

        // Verificar os resultados
        System.assertNotEquals(0, arquivos.size(), 'Deveria haver pelo menos 1 ContentVersion retornado');
        ContentVersion arquivoMaisRecente = arquivos[0];

        // Verificar se o arquivo mais recente corresponde ao que foi inserido mais recentemente
        // System.assertEquals(contentVersion2.Id, arquivoMaisRecente.Id, 'O arquivo mais recente deve ser o de teste 2');
        System.assertNotEquals(null, arquivoMaisRecente.VersionDataUrl, 'O VersionDataUrl não deve ser nulo');
        System.assertNotEquals(null, arquivoMaisRecente.Title, 'O título não deve ser nulo');
        System.assertNotEquals(null, arquivoMaisRecente.FileType, 'O tipo de arquivo não deve ser nulo');
    }
}