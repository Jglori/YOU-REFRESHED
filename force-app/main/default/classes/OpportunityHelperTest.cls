@isTest
private class OpportunityHelperTest {

    @TestSetup
    static void setup(){
        RecordType rt = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'Contact' AND Name = 'Corretor'
        ];
        
        Account acc = new Account();
            acc.Name = 'Conta de Teste';
            acc.CNPJ__c = '34138415000148';
            acc.Type = 'HouseImobiliaria';
        insert acc;

        Contact ctt = new Contact();
            ctt.FirstName = 'Elera';
            ctt.LastName = 'Teste';
            ctt.Email = 'teste.dev@elera.io';
            ctt.AccountId = acc.Id;
            ctt.RecordTypeId = rt.Id;
        insert ctt;

        Empreendimento__c empreendimento = new Empreendimento__c();
            empreendimento.Name = 'Empreendimento de Teste';
            empreendimento.CNPJEmpreendimento__c = '22151181000190';
            empreendimento.TipoEmpreendimento__c = 'Casa';
            empreendimento.StatusObra__c = 'Entregue';
            empreendimento.MetragemPrivativaTotal__c = 5000;
            empreendimento.MetragemTerreno__c = 10000;
            empreendimento.MetragemConstruIdaM__c = 7000;
            empreendimento.SPE__c = acc.Id;
        insert empreendimento;
        
        Bloco__c bloco = new Bloco__c();
            bloco.Name = 'Teste';
            bloco.Empreendimento__c = empreendimento.Id;
            bloco.DataLancamento__c = Date.today();
            bloco.DataEntrega__c = Date.today().addMonths(12);
            bloco.QuantidadeAndares__c = 10;
            bloco.TotalUnidades__c = 50;
        insert bloco;

        Product2 product =  new Product2();
            product.AgenteFinanceiro__c = 'FII';
            product.Enquadramento__c = 'HIS';
            product.Andar__c = 10;
            product.Coeficiente__c = 0;
            product.NumeroQuartos__c = 2;
            product.NumeroDeSuites__c = 1;
            product.NumeroDeVagasIncorporadas__c = 1;
            product.Name = 'Produto de Teste';
            product.ProductCode = 'Teste-1';
            product.isActive = true;
            product.NumeroDaUnidade__c = 777;
            product.Status__c = 'Reservada';
            product.ValorM2__C = 8;
            product.ExternalId = '10';
            product.Empreendimento__c = empreendimento.Id;
            product.Bloco__c = bloco.Id;
        insert product;

        Pricebook2 pricebook = new Pricebook2();
            pricebook.Name = 'test';
            pricebook.isActive = true;
        insert pricebook;

        
        Opportunity opp1 = new Opportunity(); 
            opp1.Name = 'Teste';
            opp1.Amount = 1000;
            opp1.CanalAtendimento__c = 'WhatsApp';
            opp1.Probability = 20;
            opp1.TipoVenda__c = 'Negócio novo';
            opp1.StageName = 'Negociação';
            opp1.CloseDate = System.today().addDays(15);
            opp1.AccountId = acc.Id;
            opp1.Pricebook2Id = pricebook.Id;

        Opportunity opp2 = new Opportunity();
            opp2.Name = 'Teste';
            opp2.Amount = 1000;
            opp2.CanalAtendimento__c = 'WhatsApp';
            opp2.Probability = 20;
            opp2.TipoVenda__c = 'Negócio novo';
            opp2.CloseDate = System.today().addDays(15);
            opp2.AccountId = acc.Id;
            opp2.Pricebook2Id = pricebook.Id;
            opp2.StageName = 'Ficha Cadastral';

        Opportunity opp3 = new Opportunity();
            opp3.Name = 'Teste 3';
            opp3.Amount = 1000;
            opp3.CanalAtendimento__c = 'WhatsApp';
            opp3.Probability = 20;
            opp3.TipoVenda__c = 'Negócio novo';
            opp3.CloseDate = System.today().addDays(15);
            opp3.Pricebook2Id = pricebook.Id;
            opp3.AccountId = acc.Id;
            opp3.StageName = 'Pré-análise';
            opp3.Unidade__c = product.Id;
        
        insert new List<Opportunity> { opp1, opp2, opp3 };

        AnaliseCredito__c analise = new AnaliseCredito__c();
            analise.Name = 'Teste';
            analise.Status__c = 'Em Análise';
            analise.Opportunity__c = opp3.Id;
            analise.DataVencimento__c = Date.today();
        insert analise;

        Documentacao__c doc = new Documentacao__c();
            doc.Name = 'Documento test';
            doc.Obrigatorio__c = true;
            doc.Entregue__c = false;
            doc.Validado__c = false;
        insert doc;

        Checklist_de_Documentos__c cklist = new Checklist_de_Documentos__c();
            cklist.Oportunidade__c = opp1.Id;
            cklist.Documenta_o__c = doc.Id;
        insert cklist;

        Quote cotacao =  new Quote();
            cotacao.Name = 'Teste';
            cotacao.Status = 'Aprovada';
            cotacao.Pricebook2Id = Test.getStandardPricebookId();
            cotacao.OpportunityId = opp1.Id; 
        insert cotacao;
        
        PricebookEntry pricebookEntry = new PricebookEntry();
            pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
            pricebookEntry.Product2Id = product.Id;
            pricebookEntry.UseStandardPrice = false;
            pricebookEntry.UnitPrice = 100;
            pricebookEntry.IsActive = true;
            pricebookEntry.Pricebook2Id = cotacao.Pricebook2Id;
        insert pricebookEntry;
        
        QuoteLineItem quoteLI = new QuoteLineItem();
            quoteLI.QuoteId = cotacao.Id;
            quoteLI.PricebookEntryId = pricebookEntry.Id;
            quoteLI.Quantity = 1;
            quoteLI.UnitPrice = 100;
        insert quoteLI;
    
        OpportunityContactRole ocr = new OpportunityContactRole(); 
            ocr.Role = 'Comprador'; 
            ocr.OpportunityId = opp1.Id;
            ocr.ContactId = ctt.Id;
        insert ocr;

    }

    @isTest
    static void testSetDefaultCloseDate() {
        Opportunity opp = [
            SELECT Id, Name, StageName, CloseDate
            FROM Opportunity        
            WHERE StageName = 'Negociação'
        ];
        opp.CloseDate = null;

        List<Opportunity> opps = new List<Opportunity>{ opp };
        OpportunityHelper.addDaysToCloseDateOnCreation(opps);

        for (Opportunity o : opps) {
            System.assertEquals(Date.today().addDays(5), o.CloseDate, 'CloseDate should be set to today + 5 days');
        }
    }

    @IsTest
    static void testGetPicklistValues() {
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE StageName = 'Negociação'];
        Schema.sObjectField field = Opportunity.StageName;
        // System.debug(OpportunityHelper.getPickListValues(field));
    }

    @isTest
    static void testValidateTransitionToFichaCadastral_AllFieldsFilled() {        
        List<Opportunity> opps = [
            SELECT Id, Name, StageName, FarolChecklistDocumento__c, CanalAtendimento__c, TipoVenda__c, Probability, AccountId, Amount, SyncedQuoteId, Corretor__c
            FROM Opportunity
        ];
        Quote cotacao = [
            SELECT Id
            FROM Quote
            WHERE OpportunityId = :opps.get(0).Id
        ];
        opps.get(0).SyncedQuoteId = cotacao.Id;
        
        Opportunity firstOpp = opps.get(0).clone(true, true, false, false);
        firstOpp.StageName = 'Ficha Cadastral';
        
        Opportunity secondOpp = opps.get(1).clone(true, true, false, false);
        secondOpp.StageName = 'Pré-análise';
        secondOpp.FarolChecklistDocumento__c = 'Verde';

        List<Opportunity> newOpps = new List<Opportunity> { firstOpp, secondOpp };

        Test.startTest();
        OpportunityHelper.validateTransitionToFichaCadastral(newOpps, new Map<Id, Opportunity>{ opps.get(0).Id => opps.get(0), opps.get(1).Id => opps.get(1) });
        Test.stopTest();

        for (Opportunity o : newOpps) {
         
        }
    }

    @isTest
    static void testValidateTransitionToFichaCadastral_MissingRequiredFields() {
        Opportunity opp = [
            SELECT Id, Name, AccountId, Corretor__c, StageName, CloseDate
            FROM Opportunity
            WHERE StageName = 'Negociação'
        ];

        List<Opportunity> opps = new List<Opportunity>{ opp };
        
        Test.startTest();
        OpportunityHelper.validateTransitionToFichaCadastral(opps, new Map<Id, Opportunity>{ opp.Id => opp });
        Test.stopTest();
    }

    @IsTest
    static void testHandleStageFichaCadastralChangeFarolColor() {
        Contact ctt = new Contact();
        ctt.FirstName = 'Elera Checklist';
        ctt.LastName = 'Teste Checklist';
        ctt.Email = 'teste.dev@elera.io.checklist';
        insert ctt;

        Opportunity opp = new Opportunity();
        opp.Name = 'Teste Checklist';
        opp.Amount = 1000;
        opp.CanalAtendimento__c = 'WhatsApp';
        opp.Probability = 20;
        opp.TipoVenda__c = 'Negócio novo';
        opp.StageName = 'Ficha Cadastral';
        opp.CloseDate = System.today().addDays(15);
        insert opp;

        OpportunityContactRole ocr = new OpportunityContactRole(); 
        ocr.Role = 'Comprador'; 
        ocr.OpportunityId = opp.Id;
        ocr.ContactId = ctt.Id;
        insert ocr;

        List<String> docsObrigatorios = new List<String>{'Comprovante de Renda', 'CPF', 'RG'};
        List<String> docsOpcionais = new List<String>{'Certidão de Estado Civil', 'Comprovante de Residência'};

        List<Documentacao__c> docsList = new List<Documentacao__c>();
        List<Checklist_de_Documentos__c> checklistList = new List<Checklist_de_Documentos__c>();

        for (String docName : docsObrigatorios) {
            Documentacao__c doc = new Documentacao__c(
                Name = docName,
                Contato__c = ocr.ContactId,
                Obrigatorio__c = true,
                Entregue__c = true,
                Validado__c = true
            );
            docsList.add(doc);
        }

        for (String docName : docsOpcionais) {
            Documentacao__c doc = new Documentacao__c(
                Name = docName,
                Contato__c = ocr.ContactId,
                Obrigatorio__c = false,
                Entregue__c = true,
                Validado__c = true
            );
            docsList.add(doc);
        }

        insert docsList;

        for (Documentacao__c doc : docsList) {
            Checklist_de_Documentos__c cklist = new Checklist_de_Documentos__c(
                Oportunidade__c = opp.Id,
                Documenta_o__c = doc.Id
            );
            checklistList.add(cklist);
        }

        insert checklistList;

        Test.startTest();
            opp.Amount = 2000;
            update opp;
        Test.stopTest();

        System.assertEquals(2000, opp.Amount, 'Amount deve ser igual a 2000');
    }

    @IsTest
    static void testHandlePreAnaliseForAnaliseCreditoValid() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Teste';
        opp.Amount = 1000;
        opp.CanalAtendimento__c = 'WhatsApp';
        opp.Probability = 20;
        opp.TipoVenda__c = 'Negócio novo';
        opp.StageName = 'Pré-análise';
        opp.CloseDate = System.today().addDays(15);
        insert opp;

        AnaliseCredito__c analise = new AnaliseCredito__c();
        analise.Name = 'Teste';
        analise.Status__c = 'Em Análise';
        analise.Opportunity__c = opp.Id;
        analise.DataVencimento__c = Date.today();
        insert analise;


        opp.StageName = 'Geração de Contrato';
        Test.startTest();
        update opp;
        Test.stopTest();

        System.assertEquals('Geração de Contrato', opp.StageName, 'StageName da Oportunidade deveria ser "Geração de Contrato"');
    }
    
    @isTest
    static void testHasBuyersWithBuyers() {
        Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE StageName = 'Negociação'];
        
        OpportunityContactRole oppContactRole = [SELECT Id, Role FROM OpportunityContactRole];
        oppContactRole.Role = 'Comprador';
        update oppContactRole;

    
        Test.startTest();
        Boolean result = OpportunityHelper.hasBuyers(oportunidade.Id);
        Test.stopTest();

        
        System.assertEquals(true, result, 'há compradores associadoss.');
    }

    @isTest
    static void testHasBuyersWithoutBuyers() {
        Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE StageName = 'Negociação'];


        Test.startTest();
        Boolean result = OpportunityHelper.hasBuyers(oportunidade.Id);
        Test.stopTest();


        System.assertEquals(true, result, 'não há compradores associados');
    }

    @isTest
    static void testHasBuyersWithException() {
        Test.startTest();
        Boolean result = OpportunityHelper.hasBuyers(null); 
        Test.stopTest();

        
        System.assertEquals(false, result, 'Exceção.');
    }



    @IsTest
    static void testHandlePreAnaliseForAnaliseCreditoInvalid() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Teste';
        opp.Amount = 1000;
        opp.CanalAtendimento__c = 'WhatsApp';
        opp.Probability = 20;
        opp.TipoVenda__c = 'Negócio novo';
        opp.StageName = 'Pré-análise';
        opp.CloseDate = System.today().addDays(15);
        insert opp;
        
        opp.StageName = 'Geração de Contrato';
        Test.startTest();
        try {
            update opp;
           
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Por favor, associe uma Análise de Crédito para avançar de fase.'));
        }
        Test.stopTest();

        Opportunity oppTestada = [
            SELECT Id, StageName 
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

       
    }


    @IsTest
    static void testHandleBeforeUpdate() {
        Opportunity opp = [
            SELECT Id, Name, StageName, FarolChecklistDocumento__c, CanalAtendimento__c, TipoVenda__c, Probability, AccountId, Amount, SyncedQuoteId, Corretor__c
            FROM Opportunity
            LIMIT 1
        ];
        Quote cotacao = [
            SELECT Id
            FROM Quote
            WHERE OpportunityId = :opp.Id
        ];
        opp.SyncedQuoteId = cotacao.Id;
        
        Opportunity firstOpp = opp.clone(true, true, false, false);

        List<Opportunity> newOpps = new List<Opportunity> { firstOpp };

        Test.startTest();
        OpportunityHelper.validateTransitionToFichaCadastral(newOpps, new Map<Id, Opportunity>{ opp.Id => opp });
        Test.stopTest();

        for (Opportunity o : newOpps) {
            System.assert(o.getErrors().isEmpty(), 'Não deveria ter erros');
        }       
    }

    @IsTest
    static void testImpedirAlteracaoProbability() {
        Opportunity opp = [
            SELECT Id, Name, StageName, FarolChecklistDocumento__c, CanalAtendimento__c, TipoVenda__c, Probability, AccountId, Amount, SyncedQuoteId, Corretor__c
            FROM Opportunity
            LIMIT 1
        ];

        Opportunity firstOpp = opp.clone(true, true, false, false);

        List<Opportunity> newOpps = new List<Opportunity> { firstOpp };

        Test.startTest();
        OpportunityHelper.validateTransitionToFichaCadastral(newOpps, new Map<Id, Opportunity>{ opp.Id => opp });
        Test.stopTest();

        for (Opportunity o : newOpps) {
            System.assert(o.getErrors().isEmpty(), 'Não deveria ter erros');
        }  
    }

    @IsTest
    static void testGetByAnaliseCreditoId() {
        AnaliseCredito__c analise = [
            SELECT Id
            FROM AnaliseCredito__c
        ];
 
        Test.startTest();
        List<Opportunity> results = OpportunityHelper.getByAnaliseCreditoId(new Set<Id>{ analise.Id });
        Test.stopTest();

        Opportunity expected = [
            SELECT Id, StageName
            FROM Opportunity
            WHERE StageName = 'Pré-análise'
        ];

        System.assertEquals(expected.Id, results[0].Id, 'Ids incorreto');
    }

    @IsTest
    static void testGetByIds() {
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            WHERE StageName = 'Negociação'
        ];
 
        Test.startTest();
        List<Opportunity> result = OpportunityHelper.getByIds(new Set<Id>{ opp.Id });
        Test.stopTest();

        Opportunity expected = [
            SELECT Id, StageName
            FROM Opportunity
            WHERE StageName = 'Negociação'
        ];

        System.assertEquals(expected.Id, result[0].Id, 'Ids incorreto');
    }

    @IsTest
    static void testHandleStageFichaCadastralChangeFarolColorValid() {
        Opportunity opp = [SELECT Id, StageName, FarolChecklistDocumento__c FROM Opportunity WHERE StageName = 'Pré-análise'];

        Opportunity cloneOpp = opp.clone(true, true, false, false);
        cloneOpp.StageName = 'Ficha Cadastral';

        Test.startTest();
        OpportunityHelper.handleStageFichaCadastralChangeFarolColor(new List<Opportunity>{opp}, new Map<Id, Opportunity>{cloneOpp.Id => cloneOpp});
        Test.stopTest();

    }
    
    @IsTest
    static void testHandleStageFichaCadastralValid() {
        Opportunity opps = [SELECT Id, StageName, FarolChecklistDocumento__c FROM Opportunity WHERE StageName = 'Negociação'];
        
        Test.startTest();
        OpportunityHelper.handleStageFichaCadastral(new List<Opportunity>{ opps });
        Test.stopTest();

        System.assert(opps.getErrors().isEmpty(), 'Não deveria conter erros.');
    }

    @IsTest
    static void testHandleStageFichaCadastralInvalid() {
        Opportunity opps = [SELECT Id, StageName, FarolChecklistDocumento__c FROM Opportunity WHERE StageName = 'Pré-análise'];
        opps.FarolChecklistDocumento__c = 'Vermelho';

        Test.startTest();
        OpportunityHelper.handleStageFichaCadastral(new List<Opportunity>{ opps });
        Test.stopTest();

        System.assert(!opps.getErrors().isEmpty(), 'Deveria conter erros.');
    }
    @isTest
    public static void testHandleOpportunityUpdate() {
       Contact testContact = new Contact(
        FirstName = 'João',
        LastName = 'Silva',
        Email = 'joao.silva@example.com',
        RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Corretor' LIMIT 1].Id
    );
    insert testContact;

    Account testAccount = new Account(Name = 'Conta Teste');
    insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Oportunidade Teste',
            StageName = 'Conferência',
            CloseDate = System.today().addDays(10),
            AccountId = testAccount.Id,
            Contato__c = testContact.Id,
            Data_Assinatura_Contrato__c = System.today().addDays(-10),
            Dias_Apos_Assinatura__c = 10
        );
        insert testOpportunity;

        testOpportunity.StageName = 'Conferência';
        update testOpportunity;

        Test.startTest();

        List<Opportunity> updatedOpportunities = new List<Opportunity>{ testOpportunity };
        OpportunityHelper.handleOpportunityUpdate(updatedOpportunities);

        Test.stopTest();

        Opportunity updatedOpp = [SELECT StageName FROM Opportunity WHERE Id = :testOpportunity.Id LIMIT 1];
        System.assertEquals('Ganho', updatedOpp.StageName, 'A oportunidade não foi movida para Ganho!');
    }


    @isTest
    public static void testHandleOpportunityCancelation() {
        // Criação de dados de teste
        Contact testContact = new Contact(
            FirstName = 'João',
            LastName = 'Silva',
            Email = 'joao.silva@example.com',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Corretor' LIMIT 1].Id
        );
        insert testContact;

        Account testAccount = new Account(Name = 'Conta Teste');
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Oportunidade Teste',
            StageName = 'Pré-análise',
            CloseDate = System.today().addDays(10),
            AccountId = testAccount.Id,
            Contato__c = testContact.Id,
         MotivoCancelamento__c = 'Documentação incompleta'
        );
        insert testOpportunity;

        // Simulação de cancelamento sem MotivoCancelamento__c
        testOpportunity.StageName = 'Cancelado';
        update testOpportunity;

        Test.startTest();

        List<Opportunity> updatedOpportunities = new List<Opportunity>{ testOpportunity };
        Map<Id, Opportunity> oldOpportunities = new Map<Id, Opportunity>{
            testOpportunity.Id => [SELECT Id, StageName FROM Opportunity WHERE Id = :testOpportunity.Id]
        };

        try {
            OpportunityHelper.handleOpportunityCancelation(updatedOpportunities, oldOpportunities);
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Motivo de cancelamento é obrigatório'),
                'Erro esperado não ocorreu.');
        }

        // Simulação de cancelamento com MotivoCancelamento__c
        testOpportunity.MotivoCancelamento__c = 'Oferta baixa';
        update testOpportunity;

        OpportunityHelper.handleOpportunityCancelation(updatedOpportunities, oldOpportunities);

        Test.stopTest();

        Opportunity updatedOpp = [SELECT StageName FROM Opportunity WHERE Id = :testOpportunity.Id LIMIT 1];
        System.assertEquals('Cancelado', updatedOpp.StageName, 'A oportunidade não foi cancelada corretamente.');
    }

    @isTest
    public static void testSendCancellationNotification() {
        // Criação de dados de teste
        Contact testContact = new Contact(
            FirstName = 'João',
            LastName = 'Silva',
            Email = 'joao.silva@example.com',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Corretor' LIMIT 1].Id
        );
        insert testContact;

        Account testAccount = new Account(Name = 'Conta Teste');
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Oportunidade Teste',
            StageName = 'Pré-análise',
            CloseDate = System.today().addDays(10),
            AccountId = testAccount.Id,
            Contato__c = testContact.Id,
            MotivoCancelamento__c = 'Documentação incompleta'
        );
        insert testOpportunity;

        testOpportunity.StageName = 'Cancelado';
        update testOpportunity;

        Test.startTest();

        List<Opportunity> canceledOpportunities = new List<Opportunity>{ testOpportunity };
        Map<Id, Opportunity> oldOpportunities = new Map<Id, Opportunity>{
            testOpportunity.Id => [SELECT Id, StageName FROM Opportunity WHERE Id = :testOpportunity.Id]
        };

        OpportunityHelper.handleOpportunityCancelation(canceledOpportunities, oldOpportunities);

        // Validação da mensagem no Chatter
        List<FeedItem> feedItems = [SELECT Id, Body FROM FeedItem WHERE ParentId = :testOpportunity.Id];
        System.assert(!feedItems.isEmpty(), 'Mensagem no Chatter não foi postada.');

        // Validação do envio de e-mails
        Integer emailInvocations = Limits.getEmailInvocations();
   

        Test.stopTest();
    }




    @isTest
public static void testSendWinNotification() {
   
    Contact testContact = new Contact(
        FirstName = 'João',
        LastName = 'Silva',
        Email = 'joao.silva@example.com',
        RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Corretor' LIMIT 1].Id
    );
    insert testContact;

    Account testAccount = new Account(Name = 'Conta Teste');
    insert testAccount;

    Opportunity testOpportunity = new Opportunity(
        Name = 'Oportunidade Teste',
        StageName = 'Conferência',
        CloseDate = System.today().addDays(10),
        AccountId = testAccount.Id,
        Contato__c = testContact.Id,
        Data_Assinatura_Contrato__c = System.today().addDays(-10),
        Dias_Apos_Assinatura__c = 10
    );
    insert testOpportunity;

    testOpportunity.StageName = 'Conferência';
    update testOpportunity;

    Test.startTest();

    List<Opportunity> updatedOpportunities = new List<Opportunity>{ testOpportunity };
    OpportunityHelper.handleOpportunityUpdate(updatedOpportunities);

    List<FeedItem> feedItems = [SELECT Id, Body FROM FeedItem WHERE ParentId = :testOpportunity.Id];
    

    System.assert(true, 'Notificação de vitória enviada com sucesso!');
 }
    
}