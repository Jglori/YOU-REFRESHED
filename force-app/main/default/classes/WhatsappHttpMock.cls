@isTest
global class WhatsappHttpMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint().contains('graph.facebook.com') && 'POST' == req.getMethod()) {
            HTTPResponse res = new HTTPResponse();
            
            res.setBody('{"messages": [{"type": "text", "text": {"body": "Olá"}, "timestamp": "' + getTimeStamp() + '", "id": "wamid.HBgNNTUxMTk0NzgwNzY5MBUCABIYFjNFQjA3MDBCMkExQTRFNDFEMjg2N0QA", "from": "5511910434006"}]}');
            res.setStatusCode(200);
    
            return res; 
        }

        return null;
    }

    public static Long getTimeStamp() {
        DateTime dt = DateTime.now();
        return dt.getTime();
    }
}