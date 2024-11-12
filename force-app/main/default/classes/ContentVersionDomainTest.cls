@isTest
public class ContentVersionDomainTest {

    @isTest
    static void testObterArquivosPorIdRelacionadoComIds() {
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

        Set<Id> idsArquivos = new Set<Id>{contentVersion1.Id, contentVersion2.Id};

        Test.startTest();
        Map<Id, ContentVersion> arquivosPorId = ContentVersionDomain.obterArquivosPorIdRelacionado(idsArquivos);
        Test.stopTest();

    }

    @isTest
    static void testObterArquivosPorIdRelacionadoComLista() {
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

        List<ContentVersion> arquivos = [SELECT Id, FirstPublishLocationId FROM ContentVersion WHERE Id IN :new Set<Id>{contentVersion1.Id, contentVersion2.Id}];

        Test.startTest();
        Map<Id, ContentVersion> arquivosPorId = ContentVersionDomain.obterArquivosPorIdRelacionado(arquivos);
        Test.stopTest();

    }
}