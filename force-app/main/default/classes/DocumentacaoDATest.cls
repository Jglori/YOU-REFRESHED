@IsTest
public with sharing class DocumentacaoDATest {
    
    @TestSetup
    static void setup() {
        Documentacao__c doc1 = new Documentacao__c();
        doc1.Name = 'Documento test';
        doc1.Obrigatorio__c = true;
        doc1.Entregue__c = false;
        doc1.Validado__c = false;

        Documentacao__c doc2 = new Documentacao__c();
        doc2.Name = 'Documento test 2';
        doc2.Obrigatorio__c = true;
        doc2.Entregue__c = false;
        doc2.Validado__c = false;
        

        List<Opportunity> testOpps = new List<Opportunity>();

        for (Integer i = 0; i < 2; i++) {
            testOpps.add(new Opportunity(
                Name = 'Opp'+i,
                StageName = 'Negociação',
                Amount = 1000 + i,
                CanalAtendimento__c = 'WhatsApp',
                Probability = 20,
                TipoVenda__c = 'Negócio novo',
                CloseDate = System.today().addDays(15)
            ));
        }

        Contact ctt = new Contact();
        ctt.FirstName = 'Elera';
        ctt.LastName = 'Teste';
        ctt.Email = 'teste.dev@elera.io';

        doc1.Contato__c = ctt.Id;
        doc2.Contato__c = ctt.Id;

        insert ctt;

        insert testOpps;

        insert new List<Documentacao__c> { doc1, doc2 };     
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

    @IsTest
    static void testGetById() {
        Documentacao__c doc = [
            SELECT Id
            FROM Documentacao__c
            LIMIT 1
        ];

        Test.startTest();
            Documentacao__c docMethod = DocumentacaoDA.getById(doc.Id);
        Test.stopTest();

        System.assert(docMethod != null, 'Retornar registro');
    }

    @IsTest 
    static void testGetMetadasByName() {
        Set<String> names = new Set<String>{'RG'};

        Test.startTest();
            List<Documento__mdt> docsMdt = DocumentacaoDA.getMetadasByName(names);
        Test.stopTest();

        System.assert(docsMdt.size() > 0, 'Contem metadados de documentação');
    }


    @IsTest 
    static void testGetMetadasByPapers() {
        Set<String> papers = new Set<String>{'Comprador', 'Sócio'};

        Test.startTest();
            List<Documento__mdt> docsMdt = DocumentacaoDA.getMetadasByPapers(papers);
        Test.stopTest();

        System.assert(docsMdt.size() > 0, 'Contem metadados de documentação');
    }

    @IsTest 
    static void testGetAllDocumentsFromChecklist() {
        List<Opportunity> listOpps = [SELECT Id FROM Opportunity LIMIT 2];
        Contact ctt = [SELECT Id FROM Contact LIMIT 1];

        System.debug(ctt);
        
        Set<Id> idsOpps = new Set<Id>();

        for (Opportunity opp : listOpps) {
            idsOpps.add(opp.Id);
        }

        List<Checklist_de_Documentos__c> checklistDocs = new List<Checklist_de_Documentos__c>();
        for (Opportunity opp : listOpps) {
            checklistDocs.add(new Checklist_de_Documentos__c(
                Oportunidade__c = opp.Id,
                Contato__c = ctt.Id,
                Documenta_o__c = [SELECT Id FROM Documentacao__c LIMIT 1].Id
            ));
        }
        insert checklistDocs;
        
        Test.startTest();
            List<Documentacao__c> documents = DocumentacaoDA.getAllDocumentsFromChecklist(idsOpps);
        Test.stopTest();

        System.assert(!documents.isEmpty(), 'Retornar lista de documentos');
    }

    @IsTest 
    static void testGetAllDocumentsFromChecklistBlank() {
        Set<Id> idsOpps = new Set<Id>();
        Test.startTest();
            List<Documentacao__c> documents = DocumentacaoDA.getAllDocumentsFromChecklist(idsOpps);
        Test.stopTest();

        System.assert(documents.isEmpty(), 'Retornar lista vazia');
    }
}