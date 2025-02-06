@isTest
private class ContentDistributionSelectorTest {

    // Cenário 1: Criando uma nova distribuição quando não há uma existente
    @isTest
    static void testCriarContentDistribution_SemDistribuicaoExistente() {
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Content',
            PathOnClient = 'test.pdf',
            VersionData = Blob.valueOf('Test content data')
        );
        insert contentVersion;

        // Chama o método para criar a distribuição
        ContentDistribution contentDistribution = ContentDistributionSelector.criarContentDistribution(contentVersion, 'Test Distribution');
        
        System.assertNotEquals(contentDistribution, null, 'A distribuição criada não pode ser nula');
        System.assertNotEquals(contentDistribution.Id, null, 'A distribuição criada deve ter um Id');
    }

    // Cenário 2: Tentando criar uma distribuição duplicada (caso de distribuição já existente)
    @isTest
    static void testCriarContentDistribution_ComDistribuicaoExistente() {
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Content',
            PathOnClient = 'test.pdf',
            VersionData = Blob.valueOf('Test content data')
        );
        insert contentVersion;

        // Criação da primeira distribuição
        ContentDistribution contentDistribution = ContentDistributionSelector.criarContentDistribution(contentVersion, 'Test Distribution');
        
        // Tenta criar uma segunda distribuição para o mesmo ContentVersionId
        ContentDistribution distribuicaoExistente = ContentDistributionSelector.criarContentDistribution(contentVersion, 'Test Distribution');
        
        // Verifique se a distribuição retornada é a mesma da primeira
        System.assertEquals(contentDistribution.Id, distribuicaoExistente.Id, 'Deve retornar a mesma distribuição');
    }

    // Cenário 3: Verificando a obtenção de uma ContentDistribution por URL
    @isTest
    static void testObterDistribuicaoParaURL() {
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Content',
            PathOnClient = 'test.pdf',
            VersionData = Blob.valueOf('Test content data')
        );
        insert contentVersion;

        // Criação de uma distribuição para o ContentVersion
        ContentDistribution contentDistribution = ContentDistributionSelector.criarContentDistribution(contentVersion, 'Test Distribution');
        
        // Obtendo a distribuição para a URL
        ContentDistribution resultado = ContentDistributionSelector.obterDistribuicaoParaURL(contentVersion.Id);
        
        System.assertNotEquals(resultado, null, 'Distribuição não encontrada');
        System.assertEquals(resultado.Id, contentDistribution.Id, 'IDs não coincidem');
    }

    // Cenário 4: Verificando a obtenção de múltiplas distribuições por IDs de arquivos
    @isTest
    static void testObterDistribuicoesPorIdsArquivos() {
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Test Content 1',
            PathOnClient = 'test1.pdf',
            VersionData = Blob.valueOf('Test content data 1')
        );
        insert contentVersion1;

        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Test Content 2',
            PathOnClient = 'test2.pdf',
            VersionData = Blob.valueOf('Test content data 2')
        );
        insert contentVersion2;

        // Criação das distribuições para os ContentVersions
        ContentDistribution contentDistribution1 = ContentDistributionSelector.criarContentDistribution(contentVersion1, 'Test Distribution 1');
        ContentDistribution contentDistribution2 = ContentDistributionSelector.criarContentDistribution(contentVersion2, 'Test Distribution 2');

        // Obtendo distribuições por IDs de arquivos
        Set<Id> idsArquivos = new Set<Id>{ contentVersion1.Id, contentVersion2.Id };
        List<ContentDistribution> distribuicoes = ContentDistributionSelector.obterDistribuicoesPorIdsArquivos(idsArquivos);
        
        System.assertEquals(distribuicoes.size(), 2, 'Deve retornar 2 distribuições');
    }

    // Cenário 5: Erro ao criar ContentDistribution (DmlException)
    @isTest
    static void testCriarContentDistribution_DmlException() {
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Invalid Content',
            PathOnClient = 'test_invalid.pdf',
            VersionData = Blob.valueOf('Invalid data')
        );

        Test.startTest();
        try {
            ContentDistributionSelector.criarContentDistribution(contentVersion, null);
            System.assert(false, 'Deveria ter lançado uma exceção');
        } catch (DmlException e) {
            System.assert(true, 'Exceção capturada corretamente');
        }
        Test.stopTest();
    }

    // Cenário 6: Obtendo distribuição com lista vazia de IDs
    @isTest
    static void testObterDistribuicoesPorIdsArquivos_ListaVazia() {
        Set<Id> idsArquivos = new Set<Id>();
        List<ContentDistribution> distribuicoes = ContentDistributionSelector.obterDistribuicoesPorIdsArquivos(idsArquivos);

        System.assertEquals(distribuicoes.size(), 0, 'Deve retornar uma lista vazia');
    }

    // Cenário 7: Obtendo distribuição com ID inválido
    @isTest
    static void testObterDistribuicaoParaURL_IdInvalido() {
        ContentDistribution resultado = ContentDistributionSelector.obterDistribuicaoParaURL('00Q000000000000AAA');
        
        System.assertEquals(resultado, null, 'Deve retornar nulo para ID inválido');
    }
}