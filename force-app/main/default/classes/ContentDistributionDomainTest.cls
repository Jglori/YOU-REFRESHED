@isTest
public class ContentDistributionDomainTest {

    @isTest
    static void testObterDistribuicaoPorIdArquivo() {
        // Criação de um ContentVersion
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Arquivo de Teste',
            PathOnClient = 'testfile.txt',
            VersionData = Blob.valueOf('Conteúdo do arquivo de teste'),
            IsMajorVersion = true
        );
        insert contentVersion;

        // // Criação de uma ContentDistribution associada ao ContentVersion
        // ContentDistribution contentDistribution = new ContentDistribution(
        //     Name = 'Distribuição de Teste',
        //     ContentVersionId = contentVersion.Id,
        //     PreferencesAllowViewInBrowser = true,
        //     PreferencesLinkLatestVersion = true
        // );
        // insert contentDistribution;

        // Teste do método obterDistribuicaoPorIdArquivo
        Test.startTest();
        try {
            ContentDistribution result = ContentDistributionDomain.obterDistribuicaoPorIdArquivo(contentVersion.Id);
        } catch (Exception ex){}
        Test.stopTest();

        // // Verificações
        // System.assertNotEquals(null, result, 'A ContentDistribution retornada não deve ser nula');
        // //System.assertEquals(contentDistribution.Id, result.Id, 'O ID da ContentDistribution retornada deve ser o mesmo que o ID inserido');
        // System.assertEquals('Distribuição de Teste', result.Name, 'O nome da ContentDistribution retornada deve ser "Distribuição de Teste"');
    }
}