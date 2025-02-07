@isTest
private class ContractHelperTest {

    @testSetup
    static void setup() {
        Account conta = new Account();
        conta.Name = 'Conta de Teste';
        conta.CNPJ__c = '34138415000148';
        conta.Type = 'HouseImobiliaria';
        insert conta;

        Empreendimento__c empreendimento = new Empreendimento__c();
        empreendimento.Name = 'Empreendimento de Teste';
        empreendimento.CNPJEmpreendimento__c = '22151181000190';
        empreendimento.TipoEmpreendimento__c = 'Casa';
        empreendimento.StatusObra__c = 'Entregue';
        empreendimento.MetragemPrivativaTotal__c = 5000;
        empreendimento.MetragemTerreno__c = 10000;
        empreendimento.MetragemConstruIdaM__c = 7000;
        insert empreendimento;

        Opportunity oportunidade = new Opportunity();
        oportunidade.Name = 'Teste';
        oportunidade.Amount = 1000;
        oportunidade.CanalAtendimento__c = 'WhatsApp';
        oportunidade.Probability = 20;
        oportunidade.TipoVenda__c = 'Negócio novo';
        oportunidade.StageName = 'Negociação';
        oportunidade.CloseDate = System.today().addDays(15);
        oportunidade.Empreendimento__c = empreendimento.Id; 
        insert oportunidade;

        TemplateDocumento__c template = new TemplateDocumento__c();
        template.Name = 'Template Test';
        template.TipoTemplate__c = 'Contrato';
        template.Empreendimento__c = oportunidade.Empreendimento__c;
        insert template;

        Contract contract = new Contract(
            AccountId = conta.Id,
            Oportunidade__c = oportunidade.Id,
            DataInicioContrato__c = Date.today(),
            Status = 'Rascunho',
            Name = 'Contrato Test',
            DataEnvioAssinatura__c = Date.today(),
            DataAssinaturaClienteDocuSign__c = Date.today(),
            Template__c = template.Id
        );
        insert contract;

        Contact contato = new Contact();
        contato.FirstName = 'Elera';
        contato.LastName = 'Teste';
        contato.Email = 'teste@gmail.com';
        contato.AccountId = conta.Id;
        insert contato;


        ContractContactRole ccr = new ContractContactRole(
            ContactId = contato.Id,
            ContractId = contract.Id,
            Role = 'Comprador'
        );
        insert ccr;
            
        String ctrName = 'Contract: '+ contract.Id;
        ContentVersion contVersion = new ContentVersion();
        contVersion.ContentLocation = 'S'; // Indíca que será armazenado diretamente no Salesforce 
        contVersion.Title = ctrName;
        contVersion.PathOnClient = ctrName + '.pdf';
        contVersion.VersionData = Blob.valueOf('TEXT');
        insert contVersion;

        ContentVersion contentVersion_1 = [SELECT Id,  ContentDocumentId, Title FROM ContentVersion WHERE Id = :contVersion.Id LIMIT 1];
        ContentDocumentLink contDocumentLink = new ContentDocumentLink();
        contDocumentLink.ContentDocumentId = contentVersion_1.ContentDocumentId;
        contDocumentLink.LinkedEntityId = contract.Id;
        contDocumentLink.shareType = 'V';
        insert contDocumentLink;

    }

    @isTest
    static void testCreate() {
        // Obter dados criados na configuração
        Account account = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        TemplateDocumento__c template = [SELECT Id FROM TemplateDocumento__c LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 2];

        // Mapear dados de entrada para o método
        Map<String, Object> data = new Map<String, Object>{
            'status' => 'Rascunho',
            'dataInicioContrato' => String.valueOf(Date.today()),
            'dataEnvioParaAssinatura' => String.valueOf(Date.today().addDays(1)),
            'dataAssinaturaCliente' => String.valueOf(Date.today().addDays(2)),
            'conta' => new Map<String, String>{ 'Id' => account.Id, 'Name' => account.Name },
            'template' => template.Id,
            'signatarios' => new List<Map<String, String>>{
                new Map<String, String>{ 'value' => contacts[0].Id, 'role' => 'Signatário 1' }
            },
            'oportunidade' => opp.Id
        };

        // Testar o método de criação
        Test.startTest();
        Contract contract = ContractHelper.create(data);
        Test.stopTest();

        // Verificar resultados
        System.assertNotEquals(null, contract, 'O contrato não deve ser nulo');
        System.assertEquals('ContratoGerado', contract.Status, 'O status do contrato deve ser "ContratoGerado"');

        // Verificar papel de contatos
        List<ContractContactRole> ccrs = [SELECT Id, Role, ContactId FROM ContractContactRole WHERE ContractId = :contract.Id];
        System.assertEquals(1, ccrs.size(), 'Devem existir um papél de contato associado ao contrato');
        System.assertEquals('Signatário 1', ccrs[0].Role, 'O papel do primeiro contato deve ser "Signatário 1"');

        // Verificar versão de conteúdo
        ContentDocumentLink contentLink = [SELECT ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :contract.Id LIMIT 1];
        String titleExpected = 'Contract: ' + contract.Id;
        System.assertEquals(contentLink.ContentDocument.Title, titleExpected, 'O título do conteúdo deve começar com "Contrato"');
    }

    @isTest
    static void testDeleteById() {
        Contract ctr = [
            SELECT Id FROM Contract
        ];
        
        Test.startTest();
        ContractHelper.deleteById(ctr.Id);
        Test.stopTest();

        List<Contract> result = [
            SELECT Id FROM Contract
        ];
        System.assertEquals(0, result.size(), 'Deveria ter nenhum item na lista.');
    }

    @IsTest
    static void testGetByOpportunityId() {
        Opportunity opp = [
            SELECT Id FROM Opportunity
        ];

        Test.startTest();
        List<Contract> result = ContractHelper.getByOpportunityId(opp.Id);
        Test.stopTest();

        List<Contract> expected = [
            SELECT Id FROM Contract
        ];

        System.assertEquals(expected.size(), result.size(), 'Deveria conter um contrato na lista.');
    }

    @IsTest
    static void testSendNotification() {
        List<Contract> ctrs = [
            SELECT Id FROM Contract
        ];
        
        Test.startTest();
        ContractHelper.sendNotification(ctrs);
        Test.stopTest();

        Contact ctt = [
            SELECT Id FROM Contact
        ];

        
        List<FeedItem> feeds = [
            SELECT Id, ParentId, Body
            FROM FeedItem
        ];

        System.debug(ctt);

        System.debug(feeds);

        String messageExpected = 'O contrato foi assinado dentro do prazo estipulado.';

        System.assertEquals(messageExpected, feeds[0].Body, 'Deveria conter mensagem de Contrato assinado.');
    }

}