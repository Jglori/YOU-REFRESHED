@isTest
public with sharing class DocumentacaoHelperTest {
    
    @TestSetup
    static void setup() {        
        Opportunity opp = new Opportunity(
            Name = 'Teste Pré-análise',
            Amount = 1000,
            CanalAtendimento__c = 'Loja',
            Probability = 20,
            TipoVenda__c = 'Negócio novo',
            CloseDate = System.today().addDays(15),
            StageName = 'Ficha Cadastral'
        );

        Opportunity oppChck = new Opportunity(
            Name = 'Teste',
            Amount = 1000,
            CanalAtendimento__c = 'WhatsApp',
            Probability = 20,
            TipoVenda__c = 'Negócio novo',
            CloseDate = System.today().addDays(15),
            StageName = 'Ficha Cadastral'
        );

        Contact ctt = new Contact(
            FirstName = 'Elera',
            LastName = 'Teste',
            Email = 'teste.dev@elera.io'
        );

        Contact cttChk = new Contact(
            FirstName = 'Elera',
            LastName = 'Teste Check',
            Email = 'teste.dev@check.io'
        );

        List<SObject> recordsToInsert = new List<SObject>{opp, oppChck, ctt, cttChk};
        insert recordsToInsert;

        OpportunityContactRole contactRole = new OpportunityContactRole(
            OpportunityId = opp.Id,
            ContactId = ctt.Id,
            Role = 'Comprador'
        );

        OpportunityContactRole ctrCheck = new OpportunityContactRole(
            OpportunityId = oppChck.Id,
            ContactId = cttChk.Id,
            Role = 'Comprador'
        );

        insert new List<SObject>{contactRole, ctrCheck };

        ContentVersion contentVersion = new ContentVersion(
            Title = 'RG',
            PathOnClient = 'image/jpeg',
            VersionData = EncodingUtil.base64Decode('This is version data')
        );

        insert contentVersion;

        ContentVersion cv = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contentVersion.Id
        ];

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = opp.Id,
            ShareType = 'I', 
            Visibility = 'AllUsers'
        );

        insert contentDocumentLink;

        List<Documentacao__c> docsList = new List<Documentacao__c>{
            new Documentacao__c(
                Obrigatorio__c = true,
                Entregue__c = true,
                Name = 'RG',
                ContentDocumentId_c__c = cv.ContentDocumentId,
                DataEntrega__c = Date.today(),
                Contato__c = ctt.Id,
                Validado__c = false
            )
        };

        List<String> docsObrigatorios = new List<String>{'Comprovante de Renda', 'CPF', 'RG'};

        for (String docName : docsObrigatorios) {
            docsList.add(new Documentacao__c(
                Name = docName,
                Contato__c = ctrCheck.ContactId,
                Obrigatorio__c = true,
                Entregue__c = true,
                Validado__c = true
            ));
        }

        for (String docName : docsObrigatorios) {
            docsList.add(new Documentacao__c(
                Name = docName,
                Contato__c = contactRole.ContactId,
                Obrigatorio__c = true,
                Entregue__c = true,
                Validado__c = true
            ));
        }
        
        insert docsList;

        List<Checklist_de_Documentos__c> checklistList = new List<Checklist_de_Documentos__c>();


        for (Documentacao__c docChck : docsList) {
            checklistList.add(new Checklist_de_Documentos__c(
                Oportunidade__c = oppChck.Id,
                Documenta_o__c = docChck.Id,
                Contato__c = cttChk.Id
            ));
        }

        for (Documentacao__c docChck : docsList) {
            checklistList.add(new Checklist_de_Documentos__c(
                Oportunidade__c = opp.Id,
                Documenta_o__c = docChck.Id,
                Contato__c = ctt.Id
            ));
        }

        insert checklistList;
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
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE StageName = 'Ficha Cadastral' LIMIT 1];

        Contact contato = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
            Documentacao__c doc = DocumentacaoHelper.create(contato.Id, opportunity.Id, true, base64, title, 'Rg_template.jpeg', 'image/jpeg');
        Test.stopTest();

        System.assert(doc.Name == 'RG', 'Documento RG Criado');
    }
    
    @IsTest
    static void testGetByAnaliseCreditoValidate() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE CanalAtendimento__c = 'Loja' LIMIT 1];
        opp.FarolChecklistDocumento__c = 'Verde';
        opp.StageName = 'Pré-análise';
        update opp;

        AnaliseCredito__c analise = new AnaliseCredito__c(
            Name = 'Teste',
            Status__c = 'Em Análise',
            Opportunity__c = opp.Id,
            DataVencimento__c = Date.today()
        );

        insert analise;
        
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
            FROM Documentacao__c LIMIT 1
        ];
        doc.Validado__c = false;
        update doc;
        
        Test.startTest();
        List<Documentacao__c> docs = DocumentacaoHelper.validateDocuments(new Set<Id>{ doc.Id });
        Test.stopTest();
        
        List<Documentacao__c> expected = [
            SELECT Id, Name, Contato__c, ContentDocumentId_c__c, Entregue__c, Validado__c
        	FROM Documentacao__c LIMIT 1
        ];
        
        System.assertEquals(expected, docs, 'Deveria retornar uma lista de Documentos válidos.');
    }
    
    @IsTest
    static void testInvalidateDocuments() {
        Documentacao__c doc = [
            SELECT Id, Validado__c
            FROM Documentacao__c LIMIT 1
        ];
        doc.Validado__c = true;
        update doc;
        
        Test.startTest();
        List<Documentacao__c> docs = DocumentacaoHelper.invalidateDocuments(new Set<Id>{ doc.Id });
        Test.stopTest();
        
        List<Documentacao__c> expected = [
            SELECT Id, Name, Contato__c, ContentDocumentId_c__c, Entregue__c, Validado__c
        	FROM Documentacao__c LIMIT 1
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
        Opportunity opp = [SELECT Id FROM Opportunity WHERE StageName = 'Ficha Cadastral' LIMIT 1];

        System.debug(opp);

        Test.startTest();
            List<Map<String, Object>> docForEachContact = DocumentacaoHelper.getDocumentsFromOppToContactRoles(opp.Id);
        Test.stopTest();

        System.debug(docForEachContact);

        System.assert(!docForEachContact.isEmpty(), 'Encontrado documentos da oportunidade'); 
    }
    

    @IsTest
    static void testGetByOpportunityId() {
        Opportunity opps = [SELECT Id FROM Opportunity WHERE StageName = 'Ficha Cadastral' LIMIT 1];

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
        Opportunity opps = [SELECT Id FROM Opportunity WHERE StageName = 'Ficha Cadastral' LIMIT 1];

        Set<Id> oppsIds = new Set<Id>();
        oppsIds.add(opps.Id);

        Test.startTest();
        List<Documentacao__c> docs = DocumentacaoHelper.getByOpportunityIdFilteredByRole(oppsIds);
        Test.stopTest();


        System.assert(!docs.isEmpty(), 'Encontrado documentos da oportunidade'); 
    }
    
    
}