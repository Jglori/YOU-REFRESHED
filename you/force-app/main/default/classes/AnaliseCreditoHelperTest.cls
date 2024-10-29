@IsTest
public with sharing class AnaliseCreditoHelperTest {

    @TestSetup
    static void setup() {
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE SobjectType = 'Contact' AND Name = 'Corretor'
        ];
        
        Account accTest = TestDataFactory.gerarConta('HouseImobiliaria');
        insert accTest;
        
        Contact cttTest = TestDataFactory.gerarContato(accTest, rt.Id);
        insert cttTest;
        
        Opportunity oppTest = TestDataFactory.gerarOportunidade(accTest, cttTest);
        insert oppTest;
    }

    @IsTest
    static void testHandleOpportunityFaseValid() {
        Opportunity oppTest = [
            SELECT Id, StageName
            FROM Opportunity
        ];
        oppTest.StageName = 'Pré-análise';
        update oppTest;
        
        Test.startTest();
        AnaliseCredito__c analise = TestDataFactory.gerarAnaliseCredito(oppTest);
        insert analise;
        Test.stopTest();

        AnaliseCredito__c analisesTestadas = [
            SELECT Id, Name, Opportunity__c, Status__c
            FROM AnaliseCredito__c
            WHERE Id = :analise.Id
        ];

        System.assertEquals(analise.Name, analisesTestadas.Name, 'O nome da análise deveria ser "Teste"');
        System.assertEquals(analise.Opportunity__c, analisesTestadas.Opportunity__c, 'A Oportunidade associada a análise está incorreta');
        System.assertEquals(analise.Status__c, analisesTestadas.Status__c, 'O status da análise deveria ser "Em Análise"');
    }

    @IsTest
    static void testHandleOpportunityFaseInvalid() {
        Opportunity oppTest = [
            SELECT Id, StageName
            FROM Opportunity
        ];
        oppTest.StageName = 'Negociação';
        update oppTest;
        
        Test.startTest();
        AnaliseCredito__c analise = TestDataFactory.gerarAnaliseCredito(oppTest);
        try {
            insert analise;
            System.assert(false, 'Deveria lançar um erro devido que a oportunidade não está na Fase "Pré-análise".');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Análise de Crédito pode ser criada somente na fase de Pré-análise da Oportunidade'));   
        }
        Test.stopTest();

        List<AnaliseCredito__c> analises = [
            SELECT Id, Name, Opportunity__c, Status__c
            FROM AnaliseCredito__c
        ];

        System.assertEquals(0, analises.size(), 'A lista de análise deveria estar vazia.');
    }

    @IsTest
    static void testHandleStatusForOpportunityValid() {
        Opportunity oppTest = [
            SELECT Id, StageName
            FROM Opportunity
        ];
        oppTest.StageName = 'Pré-análise';
        update oppTest;
        
        AnaliseCredito__c analise1 = TestDataFactory.gerarAnaliseCredito(oppTest);
        AnaliseCredito__c analise2 = TestDataFactory.gerarAnaliseCredito(oppTest);
        analise2.Status__c = 'Aprovada';
        
        List<AnaliseCredito__c> analises = new List<AnaliseCredito__c>{analise1, analise2};
        
        Test.startTest();
        insert analises;
        Test.stopTest();

        List<AnaliseCredito__c> analisesTestadas = [
            SELECT Id, Name, Opportunity__c, Status__c
            FROM AnaliseCredito__c
            WHERE Opportunity__c = :oppTest.Id
        ];

        System.assertEquals(2, analisesTestadas.size(), 'A lista de análise deveria ter 2 registro.');
    }

    @IsTest
    static void testHandleStatusForOpportunityInvalid_firstCondition() {
        Opportunity oppTest = [
            SELECT Id, StageName
            FROM Opportunity
        ];
        oppTest.StageName = 'Pré-análise';
        update oppTest;
        
        List<AnaliseCredito__c> analises = new List<AnaliseCredito__c>();
        for (Integer i = 0; i < 2; i++) {
            AnaliseCredito__c analise = TestDataFactory.gerarAnaliseCredito(oppTest);
            analise.Status__c = 'Aprovada';
            analises.add(analise);
        }

        Test.startTest();
        try {
            insert analises;
            System.assert(false, 'Deveria lançar um erro devido que a Oportunidade não pode ter duas Análises com Status "Aprovada".');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Não é permitido ter duas análises de crédito com status aprovada em uma oportunidade'));   
        }
        Test.stopTest();

        List<AnaliseCredito__c> analisesTestadas = [
            SELECT Id, Name, Opportunity__c, Status__c
            FROM AnaliseCredito__c
            WHERE Opportunity__c = :oppTest.Id
        ];

        System.assertEquals(0, analisesTestadas.size(), 'A lista de análise deveria ter 0 registro.');
    }

    @IsTest
    static void testHandleStatusForOpportunityInvalid_secondCondition() {
        Opportunity oppTest = [
            SELECT Id, StageName
            FROM Opportunity
        ];
        oppTest.StageName = 'Pré-análise';
        update oppTest;        
        
        AnaliseCredito__c analise1 = TestDataFactory.gerarAnaliseCredito(oppTest);
        analise1.Status__c = 'Aprovada';
        insert analise1;

        AnaliseCredito__c analise2 = TestDataFactory.gerarAnaliseCredito(oppTest);
        analise2.Status__c = 'Aprovada';
        
        Test.startTest();
        try {
            insert analise2;
            System.assert(false, 'Deveria lançar um erro devido que a Oportunidade não pode ter duas Análises com Status "Aprovada".');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Não é permitido ter duas análises de crédito com status aprovada em uma oportunidade'));   
        }
        Test.stopTest();

        List<AnaliseCredito__c> analisesTestadas = [
            SELECT Id, Name, Opportunity__c, Status__c
            FROM AnaliseCredito__c
            WHERE Opportunity__c = :oppTest.Id
        ];

        System.assertEquals(1, analisesTestadas.size(), 'A lista de análise deveria ter 1 registro.');
    }

}