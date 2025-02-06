@isTest
public class DocumentControllerTest {

    @TestSetup
    static void setup() {
        Account acc = new Account();
        acc.Name = 'Conta de Teste';
        acc.CNPJ__c = '34138415000148';
        acc.Type = 'HouseImobiliaria';
        insert acc;

        Contact contato = new Contact();
        contato.FirstName = 'Elera';
        contato.LastName = 'Teste';
        contato.Email = 'teste.dev@elera.io';
        contato.AccountId = acc.Id;
        insert contato;
        
        Opportunity oportunidade = new Opportunity();
        oportunidade.Name = 'Teste';
        oportunidade.Amount = 1000;
        oportunidade.CanalAtendimento__c = 'WhatsApp';
        oportunidade.Probability = 20;
        oportunidade.TipoVenda__c = 'Negócio novo';
        oportunidade.CloseDate = System.today().addDays(15);
        oportunidade.AccountId = acc.Id;
        oportunidade.StageName = 'Ficha Cadastral';
        insert oportunidade;

        Opportunity oportunidadeAnalise = new Opportunity();
        oportunidadeAnalise.Name = 'Teste';
        oportunidadeAnalise.Amount = 1000;
        oportunidadeAnalise.CanalAtendimento__c = 'WhatsApp';
        oportunidadeAnalise.Probability = 20;
        oportunidadeAnalise.TipoVenda__c = 'Negócio novo';
        oportunidadeAnalise.CloseDate = System.today().addDays(15);
        oportunidadeAnalise.AccountId = acc.Id;
        oportunidadeAnalise.StageName = 'Pré-análise';
        insert oportunidadeAnalise;

        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.Role = 'Comprador';
        ocr.OpportunityId = oportunidade.Id;
        ocr.ContactId = contato.Id;
        insert ocr;

        AnaliseCredito__c analise = new AnaliseCredito__c();
        analise.Name = 'Teste';
        analise.Status__c = 'Em Análise';
        analise.Opportunity__c = oportunidadeAnalise.Id;
        analise.DataVencimento__c = Date.today();
        insert analise;

        ContentVersion content = new ContentVersion();
        content.Title = 'Test Document';
        content.PathOnClient = 'testdocument.pdf';
        content.VersionData = Blob.valueOf('Test content');
        insert content;

        content = [
            SELECT Id, ContentDocumentId, Title, PathOnClient, VersionData
            FROM ContentVersion
        ];

        Documentacao__c documentacao = new Documentacao__c();
        documentacao.Name = 'Documento test';
        documentacao.Obrigatorio__c = true;
        documentacao.Entregue__c = true;
        documentacao.Validado__c = false;
        documentacao.Contato__c = contato.Id;
        documentacao.ContentDocumentId_c__c = content.ContentDocumentId;
        insert documentacao;
        
        Checklist_de_Documentos__c checklist = new Checklist_de_Documentos__c();
        checklist.Oportunidade__c = oportunidade.Id;
        checklist.Documenta_o__c = documentacao.Id;
        checklist.Contato__c = contato.Id;
        insert checklist;
    }

    @IsTest
    static void testValidateDocument() {
        Documentacao__c doc = [SELECT Id FROM Documentacao__c LIMIT 1];

        Test.startTest();
            List<Documentacao__c> docs = DocumentController.validateDocument(doc.Id);
        Test.stopTest();

        System.assert(!docs.isEmpty(), 'Documentos validados');
    }

    @IsTest
    static void testInValidateDocument() {
        Documentacao__c doc = [SELECT Id FROM Documentacao__c LIMIT 1];

        Test.startTest();
            List<Documentacao__c> docs = DocumentController.invalidateDocument(doc.Id);
        Test.stopTest();

        System.assert(!docs.isEmpty(), 'Documentos invalidados');
    }


    @IsTest
    static void testGetDocumentsForEachContactRole() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
            List<Map<String, Object>> docForEachContact = DocumentController.getDocumentsForEachContactRole(opp.Id);
        Test.stopTest();

        System.assert(!docForEachContact.isEmpty(), 'Encontrado documentos da oportunidade');
    }

    @IsTest
    static void testGetOpportunityContactRoleByOpportunityId() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
            List<OpportunityContactRole> contactRoles = DocumentController.getOpportunityContactRoleByOpportunityId(opp.Id);
        Test.stopTest();

        System.assert(!contactRoles.isEmpty(), 'Encontrado papéis de contato da oportunidade');
    }

    @IsTest
    static void testGetByOpportunity() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
            List<Documentacao__c> docs = DocumentController.getByOpportunity(opp.Id);
        Test.stopTest();

        System.assert(!docs.isEmpty(), 'Encontrado documentos da oportunidade');
    }

    @isTest
    static void testSalvarImagem() {
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Negociação', CloseDate = Date.today().addDays(30));
        insert testOpportunity;


        Boolean obrigatorio = true;
        String title = 'RG';
        String fileName = 'imagem_teste.png';
        String base64 = 'iVBORw0KGgoAAAANSUhEUgAAAAUA';
        String fileType = 'image/jpeg';

        Test.startTest();
        Documentacao__c documento = DocumentController.salvarImagem(
            testContact.Id,
            testOpportunity.Id,
            obrigatorio,
            title,
            fileName,
            base64,
            fileType
        );
        Test.stopTest();

        System.assertNotEquals(null, documento, 'Documento não foi criado corretamente.');
        System.assertEquals(testContact.Id, documento.Contato__c, 'O contato associado está incorreto.');
        System.assertEquals(true, documento.Entregue__c, 'O documento deveria estar marcado como entregue.');

        ContentDocumentLink link = [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :testOpportunity.Id LIMIT 1];
        System.assertNotEquals(null, link, 'O ContentDocumentLink não foi criado.');
    }

    @IsTest
    static void testRecuperar() {
        Documentacao__c doc = [SELECT Id FROM Documentacao__c LIMIT 1];

        Test.startTest();
            Map<String, String> rec = DocumentController.recuperar(doc.Id);
        Test.stopTest();

        System.assert(!rec.isEmpty(), 'Documentos recuperados');
    }

    @IsTest
    static void testBaixarDocumento() {
        Documentacao__c doc = [SELECT Id FROM Documentacao__c LIMIT 1];

        Test.startTest();
            Map<String, String> rec = DocumentController.baixarDocumento(doc.Id);
        Test.stopTest();

        System.assert(!rec.isEmpty(), 'Documentos recuperados');
    }

    @IsTest
    static void testGetContactRoles_Valid() {
        Contact ctt = [
            SELECT Id
            FROM Contact
        ];

        Test.startTest();
        List<OpportunityContactRole> results = DocumentController.getContactRoles(ctt.Id);
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Deveria conter ao menos um OpportunityContactRole.');
    }

    @IsTest
    static void testGetContactsByAccountId_Valid() {
        Account acc = [
            SELECT Id
            FROM Account
        ];

        Test.startTest();
        List<Contact> results = DocumentController.getContactsByAccountId(acc.Id);
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Deveria conter ao menos um Contato.');
    }

    @IsTest
    static void testDocumentosEntregues_Valid() {
        Contact ctt = [
            SELECT Id
            FROM Contact
        ];

        Test.startTest();
        List<Checklist_de_Documentos__c> results = DocumentController.documentosEntregues(ctt.Id);
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Deveria conter ao menos um Checklist_de_Documentos.');
    }

    @IsTest 
    static void testBuscarDocumento_Valid() {
        String papel = 'qualquer coisa pois só está verificando se está vazio dentro do metodo buscarDocumento';
        
        Test.startTest();
        List<Documentacao__c> results = DocumentController.buscarDocumento(papel);
        Test.stopTest();
        
        System.assert(!results.isEmpty(), 'Deveria conter ao menos uma Documentação.');    
    }

    @IsTest
    static void testGetDocumentosPorPapeis_Valid() {
        List<String> papeis = new List<String> { 'Comprador', 'Sócio' };

        Test.startTest();
        List<Documento__mdt> results = DocumentController.getDocumentosPorPapeis(papeis);
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Deveria conter ao menos um Documento como os papeis '+ papeis);    
    }

    @IsTest
    static void testGetDocumentosPorPapel_Valid() {
        String papel = 'Comprador';

        Test.startTest();
        List<Documento__mdt> results = DocumentController.getDocumentosPorPapel(papel);
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Deveria conter ao menos um Documento como o papel de '+ papel);
    }

    @IsTest
    static void testSalvarImagemContato_Valid() {
        Contact ctt = [
            SELECT Id
            FROM Contact
        ];
        Opportunity opp = [
            SELECT Id
            FROM Opportunity WHERE StageName = 'Ficha Cadastral'
        ];

        Boolean obrigatorio = true;
        String fileName = 'RG';
        String base64Data = 'SGVsbG8gd29ybGQ='; // "Hello World" em base64
        
        Test.startTest();
        DocumentController.salvarImagemContato(ctt.Id, obrigatorio, fileName, base64Data);
        Test.stopTest();
        
        ContentVersion version = [
            SELECT Id, Title, PathOnClient, ContentDocumentId
            FROM ContentVersion
            WHERE Title =: fileName AND PathOnClient =: fileName
        ];
        System.assertNotEquals(null, version, 'Deveria conter um registro de ContentVersion.');
            
        ContentDocumentLink contentDocumentLink = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId =: version.ContentDocumentId AND LinkedEntityId =: ctt.Id
        ];
        System.assertNotEquals(null, contentDocumentLink, 'Deveria conter um registro de ContentDocumentLink');

        Documentacao__c documentacao = [
            SELECT Id, Contato__c, Name, ContentDocumentId_c__c
            FROM Documentacao__c
            WHERE Contato__c =: ctt.Id AND Name =: fileName AND ContentDocumentId_c__c =: version.ContentDocumentId
        ];
        System.assertNotEquals(null, documentacao, 'Deveria conter um registro de Documentacao.');

        Checklist_de_Documentos__c checklist = [
            SELECT Id, Contato__c, Documenta_o__c
            FROM Checklist_de_Documentos__c
            WHERE Contato__c =: ctt.Id AND Documenta_o__c =: documentacao.Id
        ];
        System.assertNotEquals(null, checklist, 'Deveria conter um registro de Checklist_de_Documentos.');
    }

    @IsTest
    static void testVerificarDocumentosEntregues_Valid() {
        Contact ctt = [
            SELECT Id
            FROM Contact
        ];

        Test.startTest();        
        Map<Id, List<DocumentController.DocumentStatus>> result = DocumentController.verificarDocumentosEntregues(new List<Id> { ctt.Id });
        Test.stopTest();

        Documentacao__c doc = [
            SELECT Name, Entregue__c, CreatedDate
            FROM Documentacao__c
            WHERE Contato__c = :ctt.Id
        ];

        System.assertEquals(doc.Name, result.get(ctt.Id)[0].nomeDoDocumento, 'O atributo "nomeDoDocumento" deveria ser igual a: '+ doc.Name);
        System.assertEquals(doc.Entregue__c, result.get(ctt.Id)[0].entregue, 'O atributo "entregue" deveria ser igual a: '+ doc.Entregue__c);
        System.assertEquals(doc.CreatedDate, result.get(ctt.Id)[0].dataEntrega, 'O atributo "dataEntrega" deveria ser igual a: '+ doc.CreatedDate);
    }

    @IsTest
    static void testVerificarDocumentosEntreguesIndividuais_Valid() {
        Contact ctt = [
            SELECT Id
            FROM Contact
        ];

        Test.startTest();
        Map<Id, List<DocumentController.DocumentStatus>> result = DocumentController.verificarDocumentosEntreguesIndividuais(ctt.Id);
        Test.stopTest();

        Documentacao__c doc = [
            SELECT Name, Entregue__c
            FROM Documentacao__c
            WHERE Contato__c = :ctt.Id
        ];

        System.assertEquals(doc.Name, result.get(ctt.Id)[0].nomeDoDocumento, 'O atributo "nomeDoDocumento" deveria ser igual a: '+ doc.Name);
        System.assertEquals(doc.Entregue__c, result.get(ctt.Id)[0].entregue, 'O atributo "entregue" deveria ser igual a: '+ doc.Entregue__c);
    }

    @IsTest
    static void testGetDeliveredDocumentsByAccountId_Valid() {
        Account acc = [
            SELECT Id
            FROM Account
        ];

        Test.startTest();
        List<Map<String, Object>> results = DocumentController.getDeliveredDocumentsByAccountId(acc.Id);
        Test.stopTest();

        Checklist_de_Documentos__c checklist = [
            SELECT Nome_do_Documento__c, IsDelivered__c, Contato__c
            FROM Checklist_de_Documentos__c
        ];

        System.assert(!results.isEmpty(), 'Deveria retornar ao menos um valor.');
        for (Integer i = 0; i < results.size(); i++) {
            System.assertEquals(checklist.Nome_do_Documento__c, results.get(i).get('DocumentName'), 'Deveria conter DocumentName no retorno');
            System.assertEquals(checklist.IsDelivered__c, results.get(i).get('IsDelivered'), 'Deveria conter IsDelivered no retorno');
            System.assertEquals(checklist.Contato__c, results.get(i).get('ContactId'), 'Deveria conter ContactId no retorno');
        }
    }


}