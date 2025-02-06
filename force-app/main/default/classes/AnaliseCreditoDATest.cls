@IsTest
public with sharing class AnaliseCreditoDATest {
    
    @TestSetup
    static void setup() {
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE SobjectType = 'Contact' AND Name = 'Corretor'
        ];

        RecordType rtAcc = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'Account' AND Name = 'Conta pessoal'
        ];
        
        Account conta = new Account();
        conta.Name = 'Conta de Teste';
        conta.CNPJ__c = '34138415000148';
        conta.Type = 'HouseImobiliaria';
        
        Account acc = new Account();
        acc.Type = 'Cliente';
        acc.RecordTypeId = rtAcc.Id;
        acc.FirstName = 'teste';
        acc.LastName = 'teste';
        acc.PersonEmail = 'test.dev@elera.io';
        insert new List<Account> { conta, acc };
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Teste';
        opp.Amount = 1000;
        opp.CanalAtendimento__c = 'WhatsApp';
        opp.Probability = 20;
        opp.TipoVenda__c = 'Negócio novo';
        opp.CloseDate = System.today().addDays(15);
        opp.AccountId = conta.Id;
        opp.StageName = 'Pré-análise';
        opp.AccountId = acc.Id;
        insert opp;

        AnaliseCredito__c analise1 = new AnaliseCredito__c();
        analise1.Name = 'Teste';
        analise1.Status__c = 'Em Análise';
        analise1.Opportunity__c = opp.Id;
        analise1.DataVencimento__c = Date.today();

        AnaliseCredito__c analise2 = new AnaliseCredito__c();
        analise2.Name = 'Teste';
        analise2.Status__c = 'Aprovada';
        analise2.Opportunity__c = opp.Id;
        analise2.DataVencimento__c = Date.today();

        insert new List<AnaliseCredito__c> { analise1, analise2 };
    }

    @IsTest
    static void testGetById_Valid() {
        AnaliseCredito__c analise = [
            SELECT Id
            FROM AnaliseCredito__c
            LIMIT 1
        ];

        Test.startTest();
        List<AnaliseCredito__c> analiseRes = AnaliseCreditoDA.getById(new Set<Id> { analise.Id });
        Test.stopTest();

        System.assert(!analiseRes.isEmpty(), 'Deveria ao menos retornar uma análise.');
    }

    
    @IsTest
    static void testGetById_Invalid() {
        Test.startTest();
        List<AnaliseCredito__c> analiseRes = AnaliseCreditoDA.getById(new Set<Id>());
        Test.stopTest();

        System.assert(analiseRes.isEmpty(), 'Deveria retorar uma lista vazia.');
    }
}