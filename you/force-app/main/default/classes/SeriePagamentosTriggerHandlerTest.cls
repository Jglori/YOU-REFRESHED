@isTest
public class SeriePagamentosTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendas();
        insert tabela;


        SeriePagamentos__c serie = TestDataFactory.gerarSeriePagamento(tabela.id);
        serie.Restante__c = true;
        insert serie;
    }
    
    @isTest
    public static void testInsert(){

        List<SeriePagamentos__c> listaUpsert = new List<SeriePagamentos__c>();
        SeriePagamentos__c serieInserida = [SELECT id FROM SeriePagamentos__c LIMIT 1];

        listaUpsert.add(serieInserida);

        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendas();
        insert tabela;

        SeriePagamentos__c serie = TestDataFactory.gerarSeriePagamento(tabela.id);
        serie.Restante__c = true;

        listaUpsert.add(serie);

        Test.startTest();

        upsert listaUpsert;

        Test.stopTest();
    }
    
}