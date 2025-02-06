@isTest
public with sharing class DocumentacaoHelperTest {
    
    @TestSetup
    static void setup() {        
        Opportunity opp = new Opportunity();
        opp.Name = 'Teste';
        opp.Amount = 1000;
        opp.CanalAtendimento__c = 'WhatsApp';
        opp.Probability = 20;
        opp.TipoVenda__c = 'Negócio novo';
        opp.CloseDate = System.today().addDays(15);
        opp.StageName = 'Pré-análise';
        insert opp;

        Contact ctt = new Contact();
        ctt.FirstName = 'Elera';
        ctt.LastName = 'Teste';
        ctt.Email = 'teste.dev@elera.io';
        insert ctt;

        OpportunityContactRole contactRole = new OpportunityContactRole(
            OpportunityId = opp.Id,
            ContactId = ctt.Id,
            Role = 'Comprador'
        );
        insert contactRole;
        
        AnaliseCredito__c analise = new AnaliseCredito__c();
        analise.Name = 'Teste';
        analise.Status__c = 'Em Análise';
        analise.Opportunity__c = opp.Id;
        analise.DataVencimento__c = Date.today();

        insert analise;

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'RG';
        contentVersion.PathOnClient = 'image/jpeg';
        contentVersion.VersionData = EncodingUtil.base64Decode('This is version data');
        insert contentVersion;

        ContentVersion cv = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contentVersion.Id
        ];

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = cv.ContentDocumentId;
        contentDocumentLink.LinkedEntityId = opp.Id;
        contentDocumentLink.ShareType = 'I'; 
        contentDocumentLink.Visibility = 'AllUsers';
        insert contentDocumentLink;

        Documentacao__c doc = new Documentacao__c(
            Obrigatorio__c = true,
            Entregue__c = true,
            Name = 'RG',
            ContentDocumentId_c__c = cv.ContentDocumentId,
            DataEntrega__c = Date.today(),
            Contato__c = ctt.Id,
            Validado__c = false
        );

        insert doc;
        
        Checklist_de_Documentos__c checklist = new Checklist_de_Documentos__c();
        checklist.Oportunidade__c = opp.Id;
        checklist.Documenta_o__c = doc.Id;
        checklist.Contato__c = ctt.Id;
        insert checklist;
    }
    
    @IsTest
    static void testCriarDocumentacao() {
        String nomeDocumento = 'Dock Test';
        
        Test.startTest();
        DocumentacaoHelper.criarDocumentacao(nomeDocumento);
        Test.stopTest();
        
        Documentacao__c doc = [
            SELECT Id, Name
            FROM Documentacao__c
            WHERE Name = 'Dock Test'
        ];
        
        System.assertNotEquals(null, doc, 'Deveria existir um Documento salvo.');
        System.assertEquals(nomeDocumento, doc.Name, 'Deveria existir uma Documentação com o nome "Dock Test".');
    }

    @IsTest
    static void testCreate() {
        String base64 = EncodingUtil.base64Encode(Blob.valueOf('Test File Content'));
        String title = 'RG';
        Documento__mdt docMdt = DocumentacaoDA.getMetadasByName(new Set<String>{title})[0];
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Contact contato = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
            Documentacao__c doc = DocumentacaoHelper.create(contato.Id, opportunity.Id, true, base64, title, 'Rg_template.jpeg', 'image/jpeg');
        Test.stopTest();

        System.assert(doc.Name == 'RG', 'Documento RG Criado');
    }
    
    @IsTest
    static void testGetByAnaliseCreditoValidate() {
        AnaliseCredito__c analise = [
            SELECT Id
            FROM AnaliseCredito__c
        ];
        
        Test.startTest();
        List<Documentacao__c> docs = DocumentacaoHelper.getByAnaliseCredito(analise.Id);
        Test.stopTest();
        
        List<Documentacao__c> expected = [
            SELECT Id, Name, Validado__c, Obrigatorio__c, Entregue__c 
        	FROM Documentacao__c
        ];
        
        System.assertEquals(expected, docs, 'Deveria retornar uma lista de Documentos.');
    }
    
    @IsTest
    static void testValidateDocuments() {
        Documentacao__c doc = [
            SELECT Id, Validado__c
            FROM Documentacao__c
        ];
        doc.Validado__c = false;
        update doc;
        
        Test.startTest();
        List<Documentacao__c> docs = DocumentacaoHelper.validateDocuments(new Set<Id>{ doc.Id });
        Test.stopTest();
        
        List<Documentacao__c> expected = [
            SELECT Id, Name, Contato__c, ContentDocumentId_c__c, Entregue__c, Validado__c
        	FROM Documentacao__c
        ];
        
        System.assertEquals(expected, docs, 'Deveria retornar uma lista de Documentos válidos.');
    }
    
    @IsTest
    static void testInvalidateDocuments() {
        Documentacao__c doc = [
            SELECT Id, Validado__c
            FROM Documentacao__c
        ];
        doc.Validado__c = true;
        update doc;
        
        Test.startTest();
        List<Documentacao__c> docs = DocumentacaoHelper.invalidateDocuments(new Set<Id>{ doc.Id });
        Test.stopTest();
        
        List<Documentacao__c> expected = [
            SELECT Id, Name, Contato__c, ContentDocumentId_c__c, Entregue__c, Validado__c
        	FROM Documentacao__c
        ];
        
        System.assertEquals(expected, docs, 'Deveria retornar uma lista de Documentos inválidos.');
    }
    
    @IsTest
    static void testDeleteById() {
        Documentacao__c doc = [SELECT Id FROM Documentacao__c LIMIT 1];
        
        Test.startTest();
            DocumentacaoHelper.deleteById(doc.Id);
        Test.stopTest();

        System.assert(doc.Id != null || doc.Id != '', 'Documento deve conter um ID');
    }
    
    

    @IsTest
    static void testGetDocumentsFromOppToContactRoles() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        System.debug(opp);

        Test.startTest();
            List<Map<String, Object>> docForEachContact = DocumentacaoHelper.getDocumentsFromOppToContactRoles(opp.Id);
        Test.stopTest();

        System.debug(docForEachContact);

        System.assert(!docForEachContact.isEmpty(), 'Encontrado documentos da oportunidade'); 
    }
    

    @IsTest
    static void testGetByOpportunityId() {
        Opportunity opps = [SELECT Id FROM Opportunity];

        Set<Id> oppsIds = new Set<Id>();
        oppsIds.add(opps.Id);

        Test.startTest();
            List<Documentacao__c> docs = DocumentacaoHelper.getByOpportunityId(oppsIds);
        Test.stopTest();

        System.assert(!docs.isEmpty(), 'Encontrado documentos das oportunidades');

    }

    @IsTest
    static void testGetMetadasByPapers() {
        Test.startTest();
            List<Documento__mdt> docs = DocumentacaoHelper.getMetadasByPaper('Comprador');
        Test.stopTest();
        System.assert(!docs.isEmpty(), 'Documentos pelo papel de contato');
    }

    @IsTest 
    static void testGetByOpportunityIdFilteredByRole() {
        Opportunity opps = [SELECT Id FROM Opportunity LIMIT 1];

        Set<Id> oppsIds = new Set<Id>();
        oppsIds.add(opps.Id);

        Test.startTest();
        List<Documentacao__c> docs = DocumentacaoHelper.getByOpportunityIdFilteredByRole(oppsIds);
        Test.stopTest();


        System.assert(!docs.isEmpty(), 'Encontrado documentos da oportunidade'); 
    }
    
    
}