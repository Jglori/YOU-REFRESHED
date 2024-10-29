@isTest
private class OpportunityHelperTest {

    @TestSetup
    static void setup(){
        RecordType rt = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'Contact' AND Name = 'Corretor'
        ];
        
        Account acc = TestDataFactory.gerarConta('HouseImobiliaria');
        insert acc;

        Contact ctt = TestDataFactory.gerarContato(acc, rt.Id);
        insert ctt;

        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento(acc);
        insert empreendimento;
        
        Bloco__c bloco = TestDataFactory.gerarBloco(empreendimento);
        insert bloco;

        Product2 product = TestDataFactory.gerarProduto(empreendimento, bloco);
        insert product;
        
        Opportunity opp1 = TestDataFactory.gerarOportunidade(acc, ctt);
        insert opp1;
        
        Opportunity opp2 = TestDataFactory.gerarOportunidade(acc, ctt);
        opp2.StageName = 'Ficha Cadastral';
        insert opp2;

        Quote cotacao = TestDataFactory.gerarCotacao(opp1);
        insert cotacao;

        PricebookEntry pricebookEntry = TestDataFactory.gerarPricebookEntry(product);
        insert pricebookEntry;
    
        QuoteLineItem quoteLI = TestDataFactory.gerarQuoteLineItem(cotacao, pricebookEntry);
        insert quoteLI;
    
        OpportunityContactRole ocr = TestDataFactory.gerarOpportunityContactRole(cotacao, ctt);
        insert ocr;
    }

    @isTest
    static void testSetDefaultCloseDate() {
        Opportunity opp = [
            SELECT Id, Name, StageName, CloseDate
            FROM Opportunity            
        ];
        opp.CloseDate = null;

        List<Opportunity> opps = new List<Opportunity>{ opp };
        OpportunityHelper.addDaysToCloseDateOnCreation(opps);

        for (Opportunity o : opps) {
            System.assertEquals(Date.today().addDays(5), o.CloseDate, 'CloseDate should be set to today + 5 days');
        }
    }

    @isTest
    static void testValidateTransitionToFichaCadastral_AllFieldsFilled() {        
        Quote cotacao = [
            SELECT Id
            FROM Quote
        ];

        Opportunity opp = [
            SELECT Id, Name, StageName, AccountId, SyncedQuoteId, Corretor__c
            FROM Opportunity
        ];
        opp.StageName = 'Ficha Cadastral';
        opp.SyncedQuoteId = cotacao.Id;
        update opp;

        List<Opportunity> opps = new List<Opportunity>{ opp };

        Test.startTest();
        OpportunityHelper.validateTransitionToFichaCadastral(opps, new Map<Id, Opportunity>{ opp.Id => opp });
        Test.stopTest();

        for (Opportunity o : opps) {
            System.assert(o.getErrors().isEmpty(), 'There should be no errors if all required fields are filled');
        }
    }

    @isTest
    static void testValidateTransitionToFichaCadastral_MissingRequiredFields() {
        Opportunity opp = [
            SELECT Id, Name, AccountId, Corretor__c, StageName, CloseDate
            FROM Opportunity
            WHERE StageName = 'Negociação'
        ];

        List<Opportunity> opps = new List<Opportunity>{ opp };
        
        Test.startTest();
        OpportunityHelper.validateTransitionToFichaCadastral(opps, new Map<Id, Opportunity>{ opp.Id => opp });
        Test.stopTest();
    }

    // AccountHelperTest
    // WhatsAppControllerTest
    // SorteioControllerTest
    // RoletaSchedulerTest
    // ReportingContactsControllerTest
    // EmpreendimentoHelpertest


    @IsTest
    static void testHandlePreAnaliseForAnaliseCreditoValid() {
        Opportunity opp = [
            SELECT Id, StageName
            FROM Opportunity
            WHERE StageName = 'Negociação'
        ];
        opp.StageName = 'Pré-análise';
        update opp;

        AnaliseCredito__c analise = TestDataFactory.gerarAnaliseCredito(opp);
        insert analise;

        opp.StageName = 'Geração de Contrato';
        Test.startTest();
        update opp;
        Test.stopTest();

        System.assertEquals('Geração de Contrato', opp.StageName, 'StageName da Oportunidade deveria ser "Geração de Contrato"');
    }

    @IsTest
    static void testHandlePreAnaliseForAnaliseCreditoInvalid() {
        Opportunity opp = [
            SELECT Id, StageName
            FROM Opportunity
            WHERE StageName = 'Negociação'
        ];
        opp.StageName = 'Pré-análise';
        update opp;

        opp.StageName = 'Geração de Contrato';
        Test.startTest();
        try {
            update opp;
            System.assert(false, 'Deveria lançar um erro devido que a oportunidade não tem Análise de Crédito associado.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Por favor, associe uma Análise de Crédito para avançar de fase.'));
        }
        Test.stopTest();

        Opportunity oppTestada = [
            SELECT Id, StageName 
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertEquals('Pré-análise', oppTestada.StageName, 'StageName da Oportunidade deveria ser "Pré-análise"');
    }
}