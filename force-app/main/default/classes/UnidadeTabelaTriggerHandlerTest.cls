@isTest
public class UnidadeTabelaTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendas();
        insert tabela;

        Product2 produto = TestDataFactory.gerarProduto();
        insert produto;

        UnidadeTabelaVendas__c unidade = TestDataFactory.gerarUnidadeTabelaVendas(tabela.Id);
        unidade.Unidade__c = produto.id;
        unidade.CoeficienteTabela__c = 1;
        insert unidade;
    }

    @isTest
    public static void testUpdateOpportunitiesFromQuotes(){
        List<UnidadeTabelaVendas__c> unidades = [SELECT id, CoeficienteTabela__c, Unidade__c FROM UnidadeTabelaVendas__c];

        for(UnidadeTabelaVendas__c unit : unidades){
            unit.CoeficienteTabela__c = 6;
        }
        
        test.startTest();
        update unidades;
        test.stopTest();

        Product2 produto = [SELECT id, Coeficiente__c FROM Product2 LIMIT 1];

        Assert.areEqual(6.00, produto.Coeficiente__c, 'Os valores devem ser giuais');
    }
}