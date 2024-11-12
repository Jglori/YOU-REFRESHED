@IsTest
public with sharing class AnaliseCreditoTriggerHandlerTest {
    
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
        
        Opportunity opp1 = TestDataFactory.gerarOportunidade(accTest, cttTest);
        opp1.StageName = 'Pré-análise';
        insert opp1;
    }
    
    @IsTest
    static void testBeforeInsert() {
        Opportunity oppTest = [
            SELECT Id, StageName
            FROM Opportunity
        ];
        
        AnaliseCredito__c analise1 = TestDataFactory.gerarAnaliseCredito(oppTest);
        AnaliseCredito__c analise2 = TestDataFactory.gerarAnaliseCredito(oppTest);
        analise2.Status__c = 'Aprovada';
        
        Test.startTest();
        insert new List<AnaliseCredito__c> { analise1, analise2 };
        Test.stopTest();
    }

    @IsTest
    static void testBeforeUpdate() {
        Opportunity oppTest = [
            SELECT Id, StageName
            FROM Opportunity
        ];
        
        AnaliseCredito__c analise1 = TestDataFactory.gerarAnaliseCredito(oppTest);
        AnaliseCredito__c analise2 = TestDataFactory.gerarAnaliseCredito(oppTest);
        insert new List<AnaliseCredito__c> { analise1, analise2 };

        analise1.Status__c = 'Aprovada';
        analise2.Name = 'SIRRRRR';

        Test.startTest();
        update new List<AnaliseCredito__c> { analise1, analise2 };
        Test.stopTest();
    }


}