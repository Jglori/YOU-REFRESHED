@isTest
private class LeadRestResourceTest {

    @TestSetup
    static void makeData(){
        Campaign camp = new Campaign(
            Name = 'Test',
            IsActive = TRUE
        );  
        insert camp;   
    }

    @isTest
    static void criacaoDeLeadComSucesso() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/Lead/';
        request.addHeader('Content-Type', 'application/json');
        request.httpMethod = 'POST';
       
        List<Map<String, Object>> leadDataList = new List<Map<String, Object>>{
            new Map<String, Object>{
                'LastName' => 'Ana beatriz',
                'Company' => 'Caixa',
                'Email' => 'anabeatriz@caixa.io',
                'MobilePhone' => '11974683648',
                'CanalAtendimento__c' => 'Fale conosco',
                'EmpreendimentoInteresse__c' => 'a01Dw00000OFidTIAT',
                'LeadSource' => 'Televisão',
                'Status' => 'Novo',
                'RecordTypeName' => 'Pessoa Física',
                'campaignName' => 'Test'
            }
        };
        
        String leadDataJson = JSON.serialize(leadDataList);
        request.requestBody = Blob.valueOf(leadDataJson);
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        LeadRestResource.doPost();
        Test.stopTest();
        
        // System.assertEquals(201, RestContext.response.statusCode);

        String responseBody = RestContext.response.responseBody.toString();
        //System.assertNotEquals(null, responseBody);

        //List<Object> responseList = (List<Object>) JSON.deserializeUntyped(responseBody);
        //Map<String, Object> responseMap = (Map<String, Object>) responseList[0];
        
        //Map<String, Object> leadResponse = (Map<String, Object>) responseMap.get('lead');
        // System.assertEquals('Novo', leadResponse.get('Status'));
        // System.assertEquals('11974683648', leadResponse.get('MobilePhone'));
        // System.assertEquals('Televisão', leadResponse.get('LeadSource'));
        // System.assertEquals('Ana beatriz', leadResponse.get('LastName'));
        // System.assertEquals('anabeatriz@caixa.io', leadResponse.get('Email'));
        // System.assertEquals('Caixa', leadResponse.get('Company'));
        // 
       	

 
        
    }
    @isTest
    static void leadDuplicado() {

        empreendimento__c emp = new empreendimento__c(CnpjEmpreendimento__c = '30411637000131', name = 'xpt');
        insert emp;

        Lead testLead = new Lead(
            Email = 'duplicate@example.com',
            LastName = 'TestLastName',
            Company = 'TestCompany',
            LeadSource = 'Web',
            CanalAtendimento__c = 'Fale conosco',
            EmpreendimentoInteresse__c = emp.id,
            MobilePhone = '123456789',
            Status = 'Novo'
        );
        insert testLead;
        
        LeadRestResource.LeadDto dtoLead = new LeadRestResource.LeadDto(testLead);
        LeadRestResource.CampaignDto dtoCamp = new LeadRestResource.CampaignDto([Select Name,Type,Status,IsActive from Campaign limit 1]);
		LeadRestResource.LeadCampaignDto ldCmpDto = new LeadRestResource.LeadCampaignDto(dtoLead, dtoCamp);
    
        testLead.Status = 'Tentativa de Contado';
        update testLead;
    
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/Lead/';
        request.addHeader('Content-Type', 'application/json');
        request.httpMethod = 'POST';
        
        // Preparando uma lista de leads
        List<Map<String, Object>> leadDataList = new List<Map<String, Object>>{
            new Map<String, Object>{
                'Email' => 'duplicate@example.com',
                'LastName' => 'TestLastName',
                'Company' => 'TestCompany',
                'LeadSource' => 'Web',
                'CanalAtendimento__c' => 'Fale conosco',
                'EmpreendimentoInteresse__c' => emp.id,
                'MobilePhone' => '123456789',
                'Status' => 'Novo',
                'RecordTypeName' => 'Pessoa Jurídica',
                'campaignName' => 'Test'
            }
        };
        
        // Enviando a lista de leads como corpo da requisição
        request.requestBody = Blob.valueOf(JSON.serialize(leadDataList));
        
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        // Iniciando o teste
        Test.startTest();
        LeadRestResource.doPost();
        Test.stopTest();
        
        //System.assertEquals(200, RestContext.response.statusCode);
    
       
    }
    
    

}