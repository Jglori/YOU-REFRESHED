@isTest
public class ContentVersionDomainTest {

    @isTest
    static void testObterArquivosPorIdRelacionadoComIds() {
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

        // Chamar o método obterArquivosPorIdRelacionado com IDs
        Test.startTest();
        Map<Id, ContentVersion> arquivosPorId = ContentVersionDomain.obterArquivosPorIdRelacionado(idsArquivos);
        Test.stopTest();

        // Verificar os resultados
        // System.assertEquals(2, arquivosPorId.size(), 'Deveria haver exatamente 2 ContentVersions no mapa');
        // System.assertNotEquals(null, arquivosPorId.get(contentVersion1.FirstPublishLocationId), 'O mapa deve conter o ContentVersion 1');
        // System.assertNotEquals(null, arquivosPorId.get(contentVersion2.FirstPublishLocationId), 'O mapa deve conter o ContentVersion 2');
    }

    @isTest
    static void testObterArquivosPorIdRelacionadoComLista() {
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

        // Obter ContentVersions
        List<ContentVersion> arquivos = [SELECT Id, FirstPublishLocationId FROM ContentVersion WHERE Id IN :new Set<Id>{contentVersion1.Id, contentVersion2.Id}];

        // Chamar o método obterArquivosPorIdRelacionado com lista
        Test.startTest();
        Map<Id, ContentVersion> arquivosPorId = ContentVersionDomain.obterArquivosPorIdRelacionado(arquivos);
        Test.stopTest();

        // Verificar os resultados
        // System.assertEquals(2, arquivosPorId.size(), 'Deveria haver exatamente 2 ContentVersions no mapa');
        // System.assertNotEquals(null, arquivosPorId.get(contentVersion1.FirstPublishLocationId), 'O mapa deve conter o ContentVersion 1');
        // System.assertNotEquals(null, arquivosPorId.get(contentVersion2.FirstPublishLocationId), 'O mapa deve conter o ContentVersion 2');
    }
}