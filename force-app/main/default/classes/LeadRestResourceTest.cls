@isTest
private class LeadRestResourceTest {

    

    @isTest static void testDoPost() {
        // Preparar
        Map<String, Object> leadMap = new Map<String, Object>{
            'LastName' => 'Sobrenome',
            'Company' => 'Empresa',
            'LeadSource' => 'Fonte do Lead',
            'CanalAtendimento__c' => 'Canal de Atendimento',
            'EmpreendimentoInteresse__c' => 'Empreendimento de Interesse',
            'MobilePhone' => 'Telefone Móvel',
            'Status' => 'Status',
            'RecordTypeName' => 'Pessoa Física'
        };

        List<Map<String, Object>> requestBodyList = new List<Map<String, Object>>{leadMap};

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestBody = Blob.valueOf(JSON.serialize(requestBodyList));
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/Lead';

        RestContext.request = req;
        RestContext.response = res;

        // Executar
        Test.startTest();
        LeadRestResource.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
      
    }

    @isTest static void testDoPostCampaingName() {
        // Preparar
        Map<String, Object> leadMap = new Map<String, Object>{
            'LastName' => 'Sobrenome',
            'Company' => 'Empresa',
            'LeadSource' => 'Fonte do Lead',
            'CanalAtendimento__c' => 'Canal de Atendimento',
            'EmpreendimentoInteresse__c' => 'Empreendimento de Interesse',
            'MobilePhone' => 'Telefone Móvel',
            'Status' => 'Status',
            'RecordTypeName' => 'Pessoa Física',
            'campaignName' => 'Campanha'
        };

        List<Map<String, Object>> requestBodyList = new List<Map<String, Object>>{leadMap};

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestBody = Blob.valueOf(JSON.serialize(requestBodyList));
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/Lead';

        RestContext.request = req;
        RestContext.response = res;

        // Executar
        Test.startTest();
        LeadRestResource.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
      
    }


    @isTest
    static void testePessoaJuridica(){
        // Preparar
        Map<String, Object> leadMap = new Map<String, Object>{
            'LastName' => 'Sobrenome',
            'Company' => 'Empresa',
            'LeadSource' => 'Fonte do Lead',
            'CanalAtendimento__c' => 'Canal de Atendimento',
            'EmpreendimentoInteresse__c' => 'Empreendimento de Interesse',
            'MobilePhone' => 'Telefone Móvel',
            'Status' => 'Status',
            'RecordTypeName' => 'Pessoa Jurídica'
        };

        List<Map<String, Object>> requestBodyList = new List<Map<String, Object>>{leadMap};

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestBody = Blob.valueOf(JSON.serialize(requestBodyList));
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/Lead';

        RestContext.request = req;
        RestContext.response = res;

        // Executar
        Test.startTest();
        LeadRestResource.doPost();
        Test.stopTest();

  
        System.assertEquals(400, RestContext.response.statusCode);
    }

    @isTest
    static void testeRegistroDesconhecido(){
        // Preparar
        Map<String, Object> leadMap = new Map<String, Object>{
            'LastName' => 'Sobrenome',
            'Company' => 'Empresa',
            'LeadSource' => 'Fonte do Lead',
            'CanalAtendimento__c' => 'Canal de Atendimento',
            'EmpreendimentoInteresse__c' => 'Empreendimento de Interesse',
            'MobilePhone' => 'Telefone Móvel',
            'Status' => 'Status',
            'RecordTypeName' => 'Registro Desconhecido'
        };

        List<Map<String, Object>> requestBodyList = new List<Map<String, Object>>{leadMap};

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestBody = Blob.valueOf(JSON.serialize(requestBodyList));
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/Lead';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LeadRestResource.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
    }


    @isTest
    static void testeComcampaignName(){
        Map<String, Object> leadMap = new Map<String, Object>{
            'LastName' => 'Sobrenome',
            'Company' => 'Empresa',
            'LeadSource' => 'Fonte do Lead',
            'CanalAtendimento__c' => 'Canal de Atendimento',
            'EmpreendimentoInteresse__c' => 'Empreendimento de Interesse',
            'MobilePhone' => 'Telefone Móvel',
            'Status' => 'Status',
            'RecordTypeName' => 'Pessoa Física',
            'CampaignName' => 'Campanha'
        };

        List<Map<String, Object>> requestBodyList = new List<Map<String, Object>>{leadMap};

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestBody = Blob.valueOf(JSON.serialize(requestBodyList));
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/Lead';

        RestContext.request = req;
        RestContext.response = res;

        // Executar
        Test.startTest();
        LeadRestResource.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
    }

    @isTest 
    static void potentialDuplicateLeadsTest(){
       
        Map<String, Object> leadMap = new Map<String, Object>{
            'LastName' => 'Sobrenome',
            'Company' => 'Empresa',
            'LeadSource' => 'Fonte do Lead',
            'CanalAtendimento__c' => 'Canal de Atendimento',
            'EmpreendimentoInteresse__c' => 'Empreendimento de Interesse',
            'MobilePhone' => 'Telefone Móvel',
            'Status' => 'Status',
            'RecordTypeName' => 'Pessoa Física',
            'CampaignName' => 'Campanha'
        };

        Map<String, Object> leadMap2 = new Map<String, Object>{
            'LastName' => 'Sobrenome',
            'Company' => 'Empresa',
            'LeadSource' => 'Fonte do Lead',
            'CanalAtendimento__c' => 'Canal de Atendimento',
            'EmpreendimentoInteresse__c' => 'Empreendimento de Interesse',
            'MobilePhone' => 'Telefone Móvel',
            'Status' => 'Status',
            'RecordTypeName' => 'Pessoa Física',
            'CampaignName' => 'Campanha'
        };

        List<Map<String, Object>> requestBodyList = new List<Map<String, Object>>{leadMap, leadMap2};

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();


        req.requestBody = Blob.valueOf(JSON.serialize(requestBodyList));

        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/Lead';

        RestContext.request = req;

        RestContext.response = res;

        Test.startTest();

        LeadRestResource.doPost();

        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);

    }

    @isTest
    static void testeDuplicado() {
        // Configuração do lead duplicado
        Map<String, Object> leadMap = new Map<String, Object>{
            'LastName' => 'Sobrenome',
            'Company' => 'Empresa',
            'LeadSource' => 'Fonte do Lead',
            'CanalAtendimento__c' => 'Canal de Atendimento',
            'EmpreendimentoInteresse__c' => 'Empreendimento de Interesse',
            'MobilePhone' => 'Telefone Móvel',
            'Status' => 'Status',
            'RecordTypeName' => 'Pessoa Física'
        };
    
        // Configuração da requisição
        List<Map<String, Object>> requestBodyList = new List<Map<String, Object>>{leadMap};
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(JSON.serialize(requestBodyList));
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/Lead';
        RestContext.request = req;
        RestContext.response = res;
    
        Test.startTest();
        LeadRestResource.doPost(); 
        System.assertEquals(400, RestContext.response.statusCode);
    
        // Segunda chamada
        LeadRestResource.doPost(); 
        System.assertEquals(400, RestContext.response.statusCode);
        String responseBody = RestContext.response.responseBody.toString();
    
        Test.stopTest();
    }
    @isTest
    static void erroRequisicao(){
        // fazer a requisição sem o corpo
        RestRequest req = new RestRequest();

        RestResponse res = new RestResponse();

        req.httpMethod = 'POST';

        req.requestURI = '/services/apexrest/Lead';

        RestContext.request = req;

        RestContext.response = res;

        Test.startTest();

        LeadRestResource.doPost();

        Test.stopTest();
    }
}