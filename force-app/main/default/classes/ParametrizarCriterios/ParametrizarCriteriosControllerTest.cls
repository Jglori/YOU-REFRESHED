@isTest
public class ParametrizarCriteriosControllerTest {

    @testSetup
    static void setupTestData() {
        ConjuntoCriteriosAnalise__c conjunto = new ConjuntoCriteriosAnalise__c(
            ValorNominal__c = 1000.00,
            VariacaoLimiteValorNominal__c = 'Abaixo do limite',
            ValorVPL__c = 2000.00,
            VariacaoLimiteValorVPL__c = 'Acima do limite',
            ValorMetro__c = 3000.00,
            VariacaoLimiteMetro__c = 'Não for igual',
            PrazoFinanciamento__c = 4000.00,
            VariacaoLimitePrazoFinanciamento__c = 'Abaixo do limite',
            CaptacaoVista__c = 5000.00,
            VariacaoLimiteCaptacaoVista__c = 'Acima do limite',
            CaptacaoPosHabitaSe__c = 6000.00,
            VariacaoLimiteCaptacaoPos__c = 'Não for igual',
            CaptacaoMensal__c = 7000.00,
            VariacaoLimiteCaptacaoMensal__c = 'Abaixo do limite'
        );
        insert conjunto;
    }

    @isTest
    static void testGetVariacoesLimite() {
        Test.startTest();
        List<String> variacoes = ParametrizarCriteriosController.getVariacoesLimite();
        Test.stopTest();
        
        System.assertNotEquals(0, variacoes.size(), 'A lista de variações não deve estar vazia.');
        System.assert(variacoes.contains('Abaixo do limite'), 'Deve conter "Abaixo do limite"');
        System.assert(variacoes.contains('Acima do limite'), 'Deve conter "Acima do limite"');
        System.assert(variacoes.contains('Não for igual'), 'Deve conter "Não for igual"');
        System.assertEquals(3, variacoes.size(), 'A lista de variações deve conter exatamente 3 elementos.');
    }

    @isTest
    static void testCriarConjuntoCriterios() {
        Map<String, Object> conjuntoMap = new Map<String, Object>{
            'nominal' => 1500.00,
            'nominalVariacao' => 'Abaixo do limite',
            'vpl' => 2500.00,
            'vplVariacao' => 'Acima do limite',
            'metro' => 3500.00,
            'metroVariacao' => 'Não for igual',
            'prazo' => 4500.00,
            'prazoVariacao' => 'Abaixo do limite',
            'captacaoVista' => 5500.00,
            'captacaoVistaVariacao' => 'Acima do limite',
            'captacaoPos' => 6500.00,
            'captacaoPosVariacao' => 'Não for igual',
            'captacaoMensal' => 7500.00,
            'captacaoMensalVariacao' => 'Abaixo do limite'
        };

        String conjuntoJson = JSON.serialize(conjuntoMap);
        Object conjunto = JSON.deserializeUntyped(conjuntoJson);

        Test.startTest();
        ParametrizarCriteriosController.criarConjuntoCriterios(conjunto);
        Test.stopTest();
        
        ConjuntoCriteriosAnalise__c insertedRecord = [SELECT 
            ValorNominal__c, 
            VariacaoLimiteValorNominal__c, 
            ValorVPL__c, 
            VariacaoLimiteValorVPL__c, 
            ValorMetro__c, 
            VariacaoLimiteMetro__c,
            PrazoFinanciamento__c, 
            VariacaoLimitePrazoFinanciamento__c,
            CaptacaoVista__c, 
            VariacaoLimiteCaptacaoVista__c,
            CaptacaoPosHabitaSe__c, 
            VariacaoLimiteCaptacaoPos__c,
            CaptacaoMensal__c, 
            VariacaoLimiteCaptacaoMensal__c
            FROM ConjuntoCriteriosAnalise__c 
            WHERE ValorNominal__c = 1500.00
            LIMIT 1
        ];
        
        System.assertNotEquals(null, insertedRecord, 'O registro ConjuntoCriteriosAnalise__c deve ser inserido.');
        System.assertEquals(1500.00, insertedRecord.ValorNominal__c, 'O campo ValorNominal__c deve ser 1500.00.');
    }

    @isTest
    static void testTestarConjuntoCriterios() {
        Decimal valorTabela = 1000.00;
        Decimal valorProposta = 800.00;

        Test.startTest();
        List<Decimal> resultados = ParametrizarCriteriosController.testarConjuntoCriterios(valorTabela, valorProposta);
        Test.stopTest();
        
        System.assertNotEquals(null, resultados, 'A lista de resultados não deve ser nula.');
        System.assertEquals(2, resultados.size(), 'A lista de resultados deve conter dois elementos.');
        System.assertEquals(200.00, resultados[0], 'A diferença deve ser 200.00.');
        System.assertEquals(0.20, resultados[1], 'A diferença percentual deve ser 0.20 (20%).');
    }
}
