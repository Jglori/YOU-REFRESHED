@isTest
public class EspelhoVendasServiceTest {

    @TestSetup
    static void makeData(){
        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();
        empreendimento.DisponivelEspelho__c = true;
        insert empreendimento;

        Product2 produto = TestDataFactory.gerarProduto();
        produto.Empreendimento__c = empreendimento.Id;
        produto.Status__c = 'Disponivel';
        insert produto;

        Bloco__c bloco = TestDataFactory.gerarBloco(empreendimento.Id);
        insert bloco;

    }

    @isTest
    static void testGetEmpreendimentosDisponiveis() {
        Test.startTest();
        List<Empreendimento__c> result = EspelhoVendasService.getEmpreendimentosDisponiveis();
        Test.stopTest();

        Assert.areEqual(true, result.size() > 0 , 'Deve retornar uma lista de empreendimentos disponíveis');
    }

    @isTest
    static void testRetornarUnidadesDisponiveis() {
        Empreendimento__c empreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1];

        Test.startTest();
        List<Product2> result = EspelhoVendasService.retornarUnidadesDisponiveis(empreendimento.Id);
        Test.stopTest();

        Assert.areEqual(true, result.size() > 0 , 'Deve retornar uma lista de empreendimentos disponíveis');
    }

    @isTest
    static void testBuscarNomesEmpreendimentos() {
        Test.startTest();
        List<String> result = EspelhoVendasService.buscarNomesEmpreendimentos();
        Test.stopTest();

        Assert.areEqual(true, result.size() > 0 , 'Deve retornar uma lista de nomes de empreendimentos');
    }

     @isTest
    static void testBuscarBlocosPorEmpreendimento() {
        Empreendimento__c empreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1];
        Test.startTest();
        List<Bloco__c> result = EspelhoVendasService.buscarBlocosPorEmpreendimento(empreendimento.Id);
        Test.stopTest();

        Assert.areEqual(true, result.size() > 0 , 'Deve retornar uma lista de nomes de blocos');
    }

    @isTest
    static void testGetConfiguracaoEspelho() {

        Test.startTest();
        List<Configura_o_de__mdt> result = EspelhoVendasService.getConfiguracaoEspelho();
        Test.stopTest();

        Assert.areEqual(true, result.size() > 0, 'A lista deve retornar dados');

        // Test.startTest();
        // // Simula a recuperação de dados de metadados personalizados
        // List<Configura_o_de__mdt> configuracoes = new List<Configura_o_de__mdt>();
        // for (Integer i = 0; i < 3; i++) {
        //     Configura_o_de__mdt config = new Configura_o_de__mdt();
        //     config.Status__c = 'Status ' + i;
        //     config.Cor__c = 'Cor ' + i;
        //     configuracoes.add(config);
        // }
        // Test.setMock(Configura_o_de__mdt.class, configuracoes);
        
        // List<Configura_o_de__mdt> result = EspelhoVendasService.getConfiguracaoEspelho();
        // Test.stopTest();

        // System.assertNotEquals(0, result.size(), 'Deve retornar uma lista de configurações de espelho');
    }

    @isTest
    static void testBuscarStatusUnidades() {
        Test.startTest();
        List<String> result = EspelhoVendasService.buscarStatusUnidades();
        Test.stopTest();

        Assert.areEqual(true, result.size() > 0, 'Deve retornar uma lista de status de unidades');
    }

    @isTest
    static void testBuscarTiposUnidades() {
        Test.startTest();
        List<RecordType> result = EspelhoVendasService.buscarTiposUnidades();
        Test.stopTest();

        Assert.areEqual(true, result.size() > 0, 'Deve retornar uma lista de tipos de unidades');
    }

    @isTest
    static void testGetUnidades() {
        Test.startTest();
        List<Product2> result = EspelhoVendasService.getUnidades(null, null, null, null, null);
        Test.stopTest();

        Assert.areEqual(true, result.size() > 0, 'Deve retornar uma lista de unidades');
    }
}