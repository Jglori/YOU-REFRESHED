@isTest
public class comissaoControllerTest {
    @TestSetup
    static void makeData(){
        // Criando TabelaVendas
        TabelaVendas__c tabela = new TabelaVendas__c();
        tabela.Name = 'Teste';
        tabela.PeriodicidadeParcelaPos__c = 1;
        tabela.PeriodicidadeParcela__c = 1;
        insert tabela;

        // Criando SeriePagamentos
        SeriePagamentos__c serie = new SeriePagamentos__c();
        serie.Name = 'Teste';
        serie.InicioPagamento__c = 1;
        serie.QuantidadeParcelas__c = 1;
        serie.ValorTotal__c = 1;
        serie.TabelaVenda__c = tabela.Id;
        serie.TipoCondicao__c = 'Ato';
        serie.AposHabiteSe__c = false;
        insert serie;

        SeriePagamentos__c serie2 = new SeriePagamentos__c();
        serie2.Name = 'Teste2';
        serie2.InicioPagamento__c = 1;
        serie2.QuantidadeParcelas__c = 1;
        serie2.ValorTotal__c = 1;
        serie2.TabelaVenda__c = tabela.Id;
        serie2.TipoCondicao__c = 'Mensais';
        serie2.AposHabiteSe__c = false;
        insert serie2;
    }

    @isTest
    public static void testAnalisarProposta(){
        List<SeriePagamentos__c> series = [SELECT Id, Name, InicioPagamento__c, QuantidadeParcelas__c, ValorTotal__c, TabelaVenda__c, TipoCondicao__c, AposHabiteSe__c FROM SeriePagamentos__c];
        TabelaVendas__c tabela = [SELECT Id, Name FROM TabelaVendas__c LIMIT 1];
        Map<String, Object> valoresMatriz = new Map<String, Object> {
            'nominalProposta' => 100000, 
            'nominalTabela' => 200000, 
            'valorVplProposta' => 80000, 
            'valorVplTabela' => 160000
        };

        Test.startTest();
        List<Object> retorno = comissaoController.analisarProposta(tabela.id, series, valoresMatriz);
        Test.stopTest();

        Assert.areEqual(true, (retorno.size() > 0), 'A lista não pode estar vazia');
    }
}