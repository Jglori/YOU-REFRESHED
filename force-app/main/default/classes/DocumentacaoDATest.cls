@IsTest
public with sharing class DocumentacaoDATest {
    
    @TestSetup
    static void setup() {
        Documentacao__c doc1 = TestDataFactory.gerarDocumentacao();
        Documentacao__c doc2 = TestDataFactory.gerarDocumentacao();
        insert new List<Documentacao__c> { doc1, doc2 };
    }

    @IsTest
    static void testGetById() {
        Documentacao__c doc = [
            SELECT Id
            FROM Documentacao__c
            LIMIT 1
        ];

        Test.startTest();
        List<Documentacao__c> results = DocumentacaoDA.getById(doc.Id);
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Deveria ao menos retornar um registro de documentação.');
    }

    @IsTest
    static void testGetAllById() {
        Documentacao__c doc = [
            SELECT Id
            FROM Documentacao__c
            LIMIT 1
        ];

        Test.startTest();
        List<Documentacao__c> results = DocumentacaoDA.getAllById(new Set<Id> { doc.Id });
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Deveria ao menos retornar um registro de documentação.');
    }
}