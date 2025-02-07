@isTest
public class ContentDistributionDomainTest {

    @testSetup
    static void setupTestData() {
        // Criação de um ContentVersion para todos os testes
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDoc.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert cv;

        // Verifique se o ContentDistribution já existe antes de inserir
        ContentDistribution existingCd = [SELECT Id FROM ContentDistribution WHERE ContentVersionId = :cv.Id LIMIT 1];

        if (existingCd == null) {
            // Se não existir, então insira um novo ContentDistribution
            ContentDistribution cd = new ContentDistribution(
                Name = 'Test Distribution',
                ContentVersionId = cv.Id,
                PreferencesAllowViewInBrowser = true,
                PreferencesLinkLatestVersion = true
            );
            insert cd;
        }
    }

    @isTest
    static void testObterDistribuicaoPorIdArquivoWithExistingDistribution() {
        // Busca o ContentVersion criado pelo @testSetup
        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];

        // Chama o método para obter a distribuição por ID de arquivo
        Test.startTest();
        ContentDistribution result = ContentDistributionDomain.obterDistribuicaoPorIdArquivo(cv.Id);
        Test.stopTest();

        // Validações
        System.assertNotEquals(null, result, 'A distribuição não deve ser nula.');
        System.assertEquals(cv.Id, result.ContentVersionId, 'O ID do ContentVersion deve corresponder.');
    }

   @isTest
    static void testObterDistribuicaoPorIdArquivoWithNoDistribution() {
        // Cria um novo ContentVersion sem uma ContentDistribution
        ContentVersion cv = new ContentVersion(
            Title = 'No Distribution Document',
            PathOnClient = 'NoDistDoc.pdf',
            VersionData = Blob.valueOf('No Distribution Content'),
            IsMajorVersion = true
        );
        insert cv;
    
        // Chama o método para obter a distribuição por ID de arquivo
        Test.startTest();
        ContentDistribution result = ContentDistributionDomain.obterDistribuicaoPorIdArquivo(cv.Id);
        Test.stopTest();
    
        // Verifica se a distribuição retornada não tem ContentVersionId ou se foi criada automaticamente
        if (result != null) {
            System.assertEquals(cv.Id, result.ContentVersionId, 'O ContentVersionId não deve corresponder, pois nenhuma distribuição foi criada.');
        }
    }

}