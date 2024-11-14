@isTest
public class DocumentControllerTest {

    @TestSetup
    static void setup() {
        Account acc = TestDataFactory.gerarConta();
        insert acc;

        Contact contato = TestDataFactory.gerarContato(acc);
        insert contato;
        
        Opportunity opportunity = TestDataFactory.gerarOportunidade();
        opportunity.AccountId = acc.Id;
        opportunity.StageName = 'Pré-análise';
        insert opportunity;

        OpportunityContactRole ocr = TestDataFactory.gerarOpportunityContactRole(opportunity, contato);
        insert ocr;

        AnaliseCredito__c analise = TestDataFactory.gerarAnaliseCredito(opportunity);
        insert analise;

        ContentVersion content = TestDataFactory.gerarContentVersion();
        insert content;
        content = [
            SELECT Id, ContentDocumentId, Title, PathOnClient, VersionData
            FROM ContentVersion
        ];

        Documentacao__c documentacao = TestDataFactory.gerarDocumentacao(content);
        documentacao.Entregue__c = true;
        documentacao.Contato__c = contato.Id;
        insert documentacao;
        
        Checklist_de_Documentos__c checklist = TestDataFactory.gerarChecklistDocumentos(opportunity, documentacao, contato);
        insert checklist;
    }

    @IsTest
    static void testValidateDocument_Valid() {
        Documentacao__c documentacao = [
            SELECT Id, Validado__c
            FROM Documentacao__c
        ];
        documentacao.Validado__c = false;
        update documentacao;

        Test.startTest();
        List<Documentacao__c> results = DocumentController.validateDocument(documentacao.Id);
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Deveria conter ao menos uma Documentacao');
        
        Boolean expected = true;
        System.assertEquals(expected, results[0].Validado__c, 'O atributo "Validado__c" deveria ser true.');
    }

    @IsTest
    static void testInvalidateDocument_Valid() {
        Documentacao__c documentacao = [
            SELECT Id, Validado__c
            FROM Documentacao__c
        ];
        documentacao.Validado__c = true;
        update documentacao;

        Test.startTest();
        List<Documentacao__c> results = DocumentController.invalidateDocument(documentacao.Id);
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Deveria conter ao menos uma Documentacao');
        
        Boolean expected = false;
        System.assertEquals(expected, results[0].Validado__c, 'O atributo "Validado__c" deveria ser false');
    }

    @IsTest
    static void testGetDocumentosByAnaliseCredito_Valid(){
        AnaliseCredito__c analise = [
            SELECT Id, Name
            FROM AnaliseCredito__c
        ];

        Test.startTest();
        List<Documentacao__c> results = DocumentController.getDocumentosByAnaliseCredito(analise.Id);
        Test.stopTest();
        
        System.assert(!results.isEmpty(), 'Deveria conter ao menos uma Documentacao relacionada a Analise: '+ analise.Id);
    }
    
    @IsTest
    static void testRetornarPapeisDeContato_Valid() {
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
        ];

        Test.startTest();
        String result = DocumentController.retornarPapeisDeContato(opp.Id);
        Test.stopTest();

        OpportunityContactRole ocr = [
            SELECT Id, ContactId, Contact.Name, Role
            FROM OpportunityContactRole
        ];

        System.assertNotEquals(null, result, 'Resultado não deveria retornar null');

        List<Object> listExpected = (List<Object>) JSON.deserializeUntyped(result);
        System.assert(!listExpected.isEmpty(), 'Deveria retonar ao menos um valor na lista');

        for (Integer i = 0; i < listExpected.size(); i++) {
            Map<String, Object> mapExpected = (Map<String, Object>) listExpected[i];
            System.assertEquals(ocr.ContactId, mapExpected.get('ContactId'), 'O atributo "ContactId" deveria ser igual a: '+ ocr.ContactId);
            System.assertEquals(ocr.Contact.Name, mapExpected.get('ContactName'), 'O atributo "ContactName" deveria ser igual a: '+ ocr.Contact.Name);
            System.assertEquals(ocr.Role, mapExpected.get('Role'), 'O atributo "Role" deveria ser igual a: '+ ocr.Role);
        }
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
        List<String> papeis = new List<String> { 'Procurador', 'Outro' };

        Test.startTest();
        List<Documento__mdt> results = DocumentController.getDocumentosPorPapeis(papeis);
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Deveria conter ao menos um Documento como os papeis '+ papeis);    
    }

    @IsTest
    static void testGetDocumentosPorPapel_Valid() {
        String papel = 'Procurador';

        Test.startTest();
        List<Documento__mdt> results = DocumentController.getDocumentosPorPapel(papel);
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Deveria conter ao menos um Documento como o papel de '+ papel);
    }

    @isTest
    static void testSalvarImagem_Valid() {
        Contact ctt = [
            SELECT Id
            FROM Contact
        ];
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
        ];

        Boolean obrigatorio = true;
        String fileName = 'RG';
        String base64Data = 'SGVsbG8gd29ybGQ='; // "Hello World" em base64
        String tipoDocumento = 'application/pdf';

        Test.startTest();
        DocumentController.salvarImagem(ctt.Id, opp.Id, obrigatorio, fileName, base64Data, tipoDocumento);
        Test.stopTest();

        ContentVersion[] versions = [SELECT Title FROM ContentVersion WHERE Title = :fileName];
        System.assertEquals(1, versions.size(), 'ContentVersion should be inserted.');

        ContentDocumentLink[] links = [SELECT LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :ctt.Id];
        System.assertEquals(1, links.size(), 'ContentDocumentLink should be inserted.');

        Documentacao__c[] documentos = [SELECT Id, Contato__c FROM Documentacao__c WHERE Contato__c = :ctt.Id AND Name = :fileName];
        System.assertEquals(1, documentos.size(), 'Documentacao__c should be inserted.');

        // Verify Checklist_de_Documentos__c insertion
        Checklist_de_Documentos__c[] checklists = [SELECT Oportunidade__c FROM Checklist_de_Documentos__c WHERE Oportunidade__c = :opp.Id AND Documenta_o__c = :documentos[0].Id];
        System.assertEquals(1, checklists.size(), 'Checklist_de_Documentos__c should be inserted.');
    }


    @IsTest
    static void testSalvarImagemContato_Valid() {
        Contact ctt = [
            SELECT Id
            FROM Contact
        ];
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
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
    static void testDeletarDocumento_Valid() {
        String docName = 'Documento test';
        
        Contact ctt = [
            SELECT Id
            FROM Contact
        ];

        Test.startTest();
        DocumentController.deletarDocumento(ctt.Id, docName);
        Test.stopTest();

        Documentacao__c docRes = [
            SELECT Id, Name, Entregue__c
            FROM Documentacao__c
        ];

        Boolean expected = false;

        System.assertEquals(expected, docRes.Entregue__c, 'O atributo "Entregue__c" deveria estar false.');
    }

    @IsTest
    static void testRecuperar_Valid() {
        Checklist_de_Documentos__c checklist = [
            SELECT Id, Documenta_o__r.Name, Contato__c
            FROM Checklist_de_Documentos__c
        ];

        ContentVersion version = [
            SELECT Id, PathOnClient
            FROM ContentVersion
        ];

        Test.startTest();
        String result = DocumentController.recuperar(checklist.Contato__c, checklist.Documenta_o__r.Name);
        Test.stopTest();
        
        String expected = '/sfc/servlet.shepherd/version/download/' + version.Id;

        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(expected, resultMap.get('documentUrl'), 'Deveria retorar a url do documento: '+ expected);
    }

    @isTest
    static void testBaixarDocumento_Valid() {
        String docName = 'Documento test';

        Checklist_de_Documentos__c checklist = [
            SELECT Id, Contato__c, Documenta_o__r.Name
            FROM Checklist_de_Documentos__c
        ];

        // Chamar o método a ser testado
        Test.startTest();
        String resultado = DocumentController.baixarDocumento(checklist.Contato__c, docName);
        Test.stopTest();

        // Verificar o resultado
        System.debug('Resultado: ' + resultado);
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(resultado);
        System.assertNotEquals(null, resultMap.get('base64Data'), 'Base64 data should not be null');
        System.assertNotEquals(null, resultMap.get('mimeType'), 'MIME type should not be null');
        System.assertNotEquals(null, resultMap.get('fileName'), 'File name should not be null');
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