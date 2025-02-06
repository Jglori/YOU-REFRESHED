@isTest
private class QuoteTriggerHandlerTest {

    @TestSetup
    static void makeData() {
        // Criar Account
        Account account = new Account(Name = 'Test Account');
        insert account;

        // Criar Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Nome do Empreendimento',
            SPE__c = account.Id, 
            CNPJEmpreendimento__c = '25790394000150',
            TipoEmpreendimento__c = 'Casa',
            StatusObra__c = 'Entregue',
            MetragemPrivativaTotal__c = 5000,
            MetragemTerreno__c = 10000,
            MetragemConstruIdaM__c = 7000
        );
        insert empreendimento;

        // Criar Bloco
        Bloco__c bloco = new Bloco__c(
            Name = 'Nome do Bloco',
            DataLancamento__c = Date.today(),
            DataEntrega__c = Date.today().addMonths(12),
            Empreendimento__c = empreendimento.Id,
            QuantidadeAndares__c = 10,
            TotalUnidades__c = 50
        );
        insert bloco;

        Product2 unidade = new Product2(
            AgenteFinanceiro__c = 'FII',
            Enquadramento__c = 'HIS',
            Andar__c = 10,
            Coeficiente__c = 0,
            NumeroQuartos__c = 2,
            NumeroDeSuites__c = 1,
            NumeroDeVagasIncorporadas__c = 1,
            Name = 'Produto de Teste',
            ProductCode = 'Teste-1',
            isActive = true,
            NumeroDaUnidade__c = 777,
            Status__c = 'Reservada',
            ValorM2__C = 8,
            ExternalId = '10'
        );
        insert unidade;

        // Criar Opportunity
        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = account.Id,
            CloseDate = System.today().addDays(30),
            StageName = 'Negociação'
        );
        insert opportunity;

        // Criar Cotações
        List<Quote> quotes = new List<Quote>();

        // Criar cotação aprovada
        Quote approvedQuote = new Quote(
            Name = 'Test Quote Approved',
            OpportunityId = opportunity.Id,
            Status = 'Aprovada'
        );
        quotes.add(approvedQuote);

        // Criar cotação não aprovada
        Quote draftQuote = new Quote(
            Name = 'Test Quote Draft',
            OpportunityId = opportunity.Id,
            Status = 'Draft'
        );
        quotes.add(draftQuote);

        insert quotes;
    }

    @isTest
    static void testSyncQuote() {
        // Carrega dados configurados no testSetup
        Opportunity opp = [SELECT Id, CotacaoSincronizada__c, Empreendimento__c, Bloco__c, Amount FROM Opportunity LIMIT 1];
        Quote quote = [SELECT Id, Status FROM Quote WHERE OpportunityId = :opp.Id LIMIT 1];

        // Atualiza a cotação para "Aprovada"
        quote.Status = 'Aprovada';

        Test.startTest();
        update quote;
        Test.stopTest();

        
    }

    @isTest
    static void testUnsyncQuote() {
        // Carrega dados configurados no testSetup
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote quote = [SELECT Id, Status, OpportunityId FROM Quote WHERE OpportunityId = :opp.Id LIMIT 1];

        // Define cotação para "Aprovada" e depois desativa a aprovação
        quote.Status = 'Aprovada';
        update quote;

        quote.Status = 'Em Revisão';
        update quote;

        // Verifica se os campos da oportunidade foram redefinidos
        Opportunity updatedOpp = [SELECT CotacaoSincronizada__c, Empreendimento__c, Bloco__c, Amount FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(null, updatedOpp.CotacaoSincronizada__c, 'A Cotação não deve estar sincronizada com a Oportunidade');
        System.assertEquals(0, updatedOpp.Amount, 'Amount deve ser zerado quando a sincronização é removida');
        System.assertEquals(null, updatedOpp.Empreendimento__c, 'Empreendimento__c deve ser limpo');
        System.assertEquals(null, updatedOpp.Bloco__c, 'Bloco__c deve ser limpo');
    }
}