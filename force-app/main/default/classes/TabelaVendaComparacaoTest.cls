@IsTest
public class TabelaVendaComparacaoTest{
    @IsTest
    static void testCompararTabelaEProposta() {
        // Criar uma conta de teste
        Account acc = new Account(
            Name = 'Conta Teste'
        );
        insert acc;

        // Criar dados de teste para a Oportunidade
        Opportunity opp = new Opportunity(
            Name = 'Test Oportunidade', 
            StageName = 'Negociação', 
            CloseDate = Date.today(),
            AccountId = acc.Id // Associando a oportunidade à conta criada
        );
        insert opp;

        // Criar dados de teste para Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Empreendimento Teste',
            SPE__c = acc.Id,  
            CNPJEmpreendimento__c = '12345678000195',
            TipoEmpreendimento__c = 'Casa',
            StatusObra__c = 'Em construção', 
            MetragemTerreno__c = 1000,
            MetragemConstruIdaM__c = 1000,
            MetragemPrivativaTotal__c = 1000
        );
        insert empreendimento;

        // Criar um bloco associado ao empreendimento
        Bloco__c bloco = new Bloco__c(
            Name = 'Bloco Teste',
            TipoBloco__c = 'Ala',
            TotalUnidades__c = 535,
            QuantidadeAndares__c = 5,
            DataEntrega__c = Date.Today(),
            DataLancamento__c = Date.Today() + 1,
            Empreendimento__c = empreendimento.Id
        );
        insert bloco;

        // Criar um produto associado ao empreendimento
        Product2 produto = new Product2(
            Name = 'Produto Teste', 
            ValorM2__c = 1000,
            Coeficiente__c = 1.5,
            NumeroDaUnidade__c = 123,
            Andar__c = 12,
            AgenteFinanceiro__c = null,
            Bloco__c = bloco.Id,
            Enquadramento__c = 'HIS',
            Status__c = 'Livre',
            NumeroQuartos__c = 2,
            NumeroDeSuites__c = 1,
            NumeroDeVagasIncorporadas__c = 1,
            Empreendimento__c = empreendimento.Id
        );
        insert produto;

        // Criar uma Tabela de Vendas associada ao empreendimento
        TabelaVendas__c tabela = new TabelaVendas__c(
            Name = 'Tabela de vendas test',
            PeriodicidadeParcela__c = 6,
            PeriodicidadeParcelaPos__c = 12,
            DescontoNominalMoeda__c = 120.00, 
            Empreendimento__c = empreendimento.Id
            
        );
        insert tabela;

        // Atualizar a Oportunidade com o empreendimento relacionado
        opp.Empreendimento__c = empreendimento.Id;
        update opp;

        // Simular os dados fornecidos pelo simulador
        Map<String, Decimal> dadosSimulacao = new Map<String, Decimal>{
            'ValorM2aVista' => 900,
            'ValorM2' => 980,
            'DescontoNominal' => 110000,
            'CaptacaoMetadePrazoObra' => 26.67,
            'CaptacaoAteHabiteSe' => 73.33,
            'CaptacaoAposHabiteSe' => 22.95
        };

        
        Test.startTest();
        
        // Chamar o método a ser testado
        List<Map<String, Object>> comparativo = ComparativoService.compararTabelaEProposta(opp.Id, dadosSimulacao);

        
        Test.stopTest();

        // Validar o resultado
        System.assertEquals(6, comparativo.size(), 'Deve haver 6 itens na tabela comparativa.');

        // Verificar se as diferenças foram calculadas corretamente
        System.assertEquals('R$ 1000.00', comparativo[0].get('Tabela'), 'O valor do m² da tabela deve ser R$ 1000.00.');
        System.assertEquals('R$ 980.00', comparativo[0].get('Proposta'), 'O valor do m² da proposta deve ser R$ 980.00.');
        System.assertEquals('R$ 20.00', comparativo[0].get('Diferenca'), 'A diferença do valor do m² deve ser R$ 20.00.');

        System.assertEquals('R$ 120000.00', comparativo[1].get('Tabela'), 'O desconto nominal da tabela deve ser R$ 120000.00.');
        System.assertEquals('R$ 110000.00', comparativo[1].get('Proposta'), 'O desconto nominal da proposta deve ser R$ 110000.00.');
        System.assertEquals('R$ 10000.00', comparativo[1].get('Diferenca'), 'A diferença do desconto nominal deve ser R$ 10000.00.');
    }
}
