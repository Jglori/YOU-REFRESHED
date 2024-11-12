@IsTest
public class MetadataServiceTest {
    private class MetadataServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><Response>Success</Response>');
            return res;
        }
    }

    class MetadataServiceErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody('Error: Bad Request');
            return res;
        }
    }

    @IsTest
    static void testCreateCustomMetadataSuccess() {
        Test.setMock(HttpCalloutMock.class, new MetadataServiceMock());
        
        String developerName = 'TestDeveloper';
        String label = 'TestLabel';
        String documentName = 'TestDocument';
        Boolean isMandatory = true;
        String role = 'TestRole';
        
        Test.startTest();
        
        MetadataService.createCustomMetadata(developerName, label, documentName, isMandatory, role);
        
        Test.stopTest();
        
    }
    
    @IsTest
    static void testCreateCustomMetadataError() {

        Test.setMock(HttpCalloutMock.class, new MetadataServiceErrorMock());

        String developerName = 'ErrorDeveloper';
        String label = 'ErrorLabel';
        String documentName = 'ErrorDocument';
        Boolean isMandatory = false;
        String role = 'ErrorRole';

        Test.startTest();
        
        MetadataService.createCustomMetadata(developerName, label, documentName, isMandatory, role);
        
        Test.stopTest();
    }
}