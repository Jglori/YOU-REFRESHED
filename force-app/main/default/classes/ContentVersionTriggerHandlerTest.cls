@isTest
public class ContentVersionTriggerHandlerTest {

    @isTest
    static void testAfterInsert() {
        // Configurar dados de teste
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'test_document.pdf';
        cv.VersionData = Blob.valueOf('Test Data');
        cv.FirstPublishLocationId = UserInfo.getUserId(); // Assume que o documento está associado ao usuário atual

        Test.startTest();
        // Inserir o ContentVersion para acionar a trigger
        insert cv;
        Test.stopTest();

    }
    
    @isTest
    static void testAfterInsertWithMultipleRecords() {
        // Configurar múltiplos ContentVersions
        List<ContentVersion> cvs = new List<ContentVersion>();
        for (Integer i = 0; i < 5; i++) {
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document ' + i;
            cv.PathOnClient = 'test_document_' + i + '.pdf';
            cv.VersionData = Blob.valueOf('Test Data ' + i);
            cv.FirstPublishLocationId = UserInfo.getUserId();
            cvs.add(cv);
        }

        Test.startTest();
        // Inserir múltiplos ContentVersions para acionar a trigger
        insert cvs;
        Test.stopTest();

    }
}