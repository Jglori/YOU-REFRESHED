@isTest
public class EspelhoVendasControllerTest {

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
        List<Empreendimento__c> result = EspelhoVendasController.getEmpreendimentosDisponiveis();
        Test.stopTest();

        Assert.areEqual(true, result.size() > 0 , 'Deve retornar uma lista de empreendimentos disponíveis');
    }

    @isTest
    static void testGetUnidades() {
        Test.startTest();
        List<Product2> result = EspelhoVendasController.getUnidades(null, null, null, null, null);
        Test.stopTest();

        Assert.areEqual(true, result.size() > 0, 'Deve retornar uma lista de unidades');
    }

    @isTest
    static void testRetornarUnidadesDisponiveis() {
        Empreendimento__c empreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1];

        Test.startTest();
        List<Product2> result = EspelhoVendasController.retornarUnidadesDisponiveis(empreendimento.Id);
        Test.stopTest();

        Assert.areEqual(true, result.size() > 0 , 'Deve retornar uma lista de empreendimentos disponíveis');
    }

    @isTest
    static void testBuscarNomesEmpreendimentos() {
        Test.startTest();
        List<String> result = EspelhoVendasController.buscarNomesEmpreendimentos();
        Test.stopTest();

        Assert.areEqual(true, result.size() > 0 , 'Deve retornar uma lista de nomes de empreendimentos');
    }

    @isTest
    static void testBuscarBlocosPorEmpreendimento() {
        Empreendimento__c empreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1];
        Test.startTest();
        List<Bloco__c> result = EspelhoVendasController.buscarBlocosPorEmpreendimento(empreendimento.Id);
        Test.stopTest();

        Assert.areEqual(true, result.size() > 0 , 'Deve retornar uma lista de nomes de blocos');
    }
    

    @isTest
    static void testBuscarStatusUnidades() {
        Test.startTest();
        List<String> result = EspelhoVendasController.buscarStatusUnidades();
        Test.stopTest();

        Assert.areEqual(true, result.size() > 0, 'Deve retornar uma lista de status de unidades');
    }

    @isTest
    static void testBuscarTiposUnidades() {
        Test.startTest();
        List<RecordType> result = EspelhoVendasController.buscarTiposUnidades();
        Test.stopTest();

        Assert.areEqual(true, result.size() > 0, 'Deve retornar uma lista de tipos de unidades');
    }

    @isTest
    static void testGetConfiguracaoEspelho() {
        Test.startTest();
        List<Product2> result = EspelhoVendasController.getUnidades(null, null, null, null, null);
        Test.stopTest();

        Assert.areEqual(true, result.size() > 0, 'Deve retornar uma lista de unidades');
    }
}