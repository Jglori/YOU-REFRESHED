@isTest
public class DocumentControllerTest {

    @isTest
    static void testeSalvarImagem() {
        // Setup test data
        String contatoId = createTestContact().Id; // Create a test contact
        String opportunityId = createTestOpportunity().Id; // Create a test opportunity
        Boolean obrigatorio = true;
        String fileName = 'RG';
        String base64Data = '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'; // Mock base64 data
        String tipoDocumento = 'application/pdf';

        // Create test Documentacao__c and Checklist_de_Documentos__c records
        createTestDocumentacao(fileName, obrigatorio, contatoId);
        createTestChecklist(opportunityId, contatoId);

      
        Test.startTest();
        DocumentController.salvarImagem(contatoId, opportunityId, obrigatorio, fileName, base64Data, tipoDocumento);
        Test.stopTest();

        ContentVersion[] versions = [SELECT Title FROM ContentVersion WHERE Title = :fileName];
        System.assertEquals(1, versions.size(), 'ContentVersion should be inserted.');

        ContentDocumentLink[] links = [SELECT LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :contatoId];
        System.assertEquals(1, links.size(), 'ContentDocumentLink should be inserted.');

        Documentacao__c[] documentos = [SELECT Contato__c FROM Documentacao__c WHERE Contato__c = :contatoId];
        System.assertEquals(1, documentos.size(), 'Documentacao__c should be inserted.');

        // Verify Checklist_de_Documentos__c insertion
        Checklist_de_Documentos__c[] checklists = [SELECT Oportunidade__c FROM Checklist_de_Documentos__c WHERE Oportunidade__c = :opportunityId];
        System.assertEquals(1, checklists.size(), 'Checklist_de_Documentos__c should be inserted.');
    }

    // Method to create a test Contact
    private static Contact createTestContact() {
        Contact testContact = new Contact(LastName='Test Contact', Email='test@example.com');
        insert testContact;
        return testContact;
    }

    // Method to create a test Opportunity
    private static Opportunity createTestOpportunity() {
        Opportunity testOpportunity = new Opportunity(Name='Test Opportunity', StageName='Prospecting', CloseDate=Date.today().addDays(30));
        insert testOpportunity;
        return testOpportunity;
    }

    // Method to create a test Documentacao__c record
    private static void createTestDocumentacao(String fileName, Boolean obrigatorio, String contatoId) {
        Documentacao__c doc = new Documentacao__c(
            Contato__c = contatoId,
            Obrigatorio__c = obrigatorio,
            Entregue__c = true,
            Name = fileName,
            ContentDocumentId_c__c = '069be000000BHwnAAG'
        );
        insert doc;
    }

private static void createTestChecklist(String opportunityId, String contatoId) {
    // Create a new Documentacao__c record
    Documentacao__c documentacao = new Documentacao__c(
        Obrigatorio__c = true,
        Entregue__c = true,
        Name = 'MockDocumentacaoId',
        ContentDocumentId_c__c = '069be000000DFhBAAW'
    );
    insert documentacao;

    Checklist_de_Documentos__c checklist = new Checklist_de_Documentos__c(
        Oportunidade__c = opportunityId,
        Contato__c = contatoId,
        Documenta_o__c = documentacao.Id
    );
    insert checklist;
}
    @isTest
    static void testBaixarDocumento() {
        // Criar um novo ContentDocument e ContentVersion
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'testdocument.pdf';
        cv.VersionData = Blob.valueOf('Test content');
        insert cv;

        // Associar o ContentVersion ao ContentDocument
        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id = :cv.ContentDocumentId LIMIT 1];

        // Criar um Checklist_de_Documentos__c para associar ao ContentDocument
        Checklist_de_Documentos__c checklistDoc = new Checklist_de_Documentos__c();
        checklistDoc.Contato__c = 'someContactId'; // Substitua pelo ID real
        // checklistDoc.Entregue__c = true; // Comente ou ajuste conforme a existência do campo
        insert checklistDoc;

        // Chamar o método a ser testado
        Test.startTest();
        String resultado = DocumentController.baixarDocumento('someContactId', 'Test Document');
        Test.stopTest();

        // Verificar o resultado
        System.debug('Resultado: ' + resultado);
        Map<String, String> resultMap = (Map<String, String>) JSON.deserializeUntyped(resultado);
        System.assertNotEquals(null, resultMap.get('base64Data'), 'Base64 data should not be null');
        System.assertNotEquals(null, resultMap.get('mimeType'), 'MIME type should not be null');
        System.assertNotEquals(null, resultMap.get('fileName'), 'File name should not be null');
    }


}