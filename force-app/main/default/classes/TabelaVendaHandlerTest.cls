@isTest
public class TabelaVendaHandlerTest {

    @isTest
    public static void testInsert() {
        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendas();

        Test.startTest();
        insert tabela;
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdate() {
        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendas();

        insert tabela;

        Test.startTest();
        update tabela;
        Test.stopTest();
    }
}