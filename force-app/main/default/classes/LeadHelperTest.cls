@isTest
public class LeadHelperTest {
	@TestSetup
    static void makeData() {
        doCreateData();
    }

    private static void doCreateData() {
        Empreendimento__c empreendimento = new Empreendimento__c();  
        empreendimento.Name = 'Teste empreendimento';  
        empreendimento.CNPJEmpreendimento__c = '12345678000195';  
        insert empreendimento; 

        Lead testLead = new Lead(
            LastName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'silva@xyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '5511987654321',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;

        testLead.Status = 'Tentativa de Contato';
        update testLead;

        Task task = new Task(
            Subject = 'Chamada',
            Status = 'Completed',
            WhoId = testLead.Id
        );
        insert task;

        Task taskOpen = new Task(
            Subject = 'Chamada',
            Status = 'Open',
            WhoId = testLead.Id
        );
        insert taskOpen;

        Lead leadSemTask = new Lead(
            LastName = 'Santos',
            Company = 'Empresa ABC',
            Email = 'santos@abc.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '5511960387699',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert leadSemTask;
    }
    
    @isTest
    static void testVerifyCNPJ() {
        // Obtém o tipo de registro "PessoaJuridica"
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'PessoaJuridica' LIMIT 1];
        
        // Cria um Lead com CNPJ inválido e o tipo de registro "PessoaJuridica"
        Lead missingCompanyLead = new Lead(
            LastName = 'CNPJ Inválido',
            Company = 'Empresa Inválida',
            Email = 'cnpj@invalido.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '5511987654321',
            Status = 'Conversão',
            RecordTypeId = rt.Id,
            CNPJ__c = '98146430000110'  
        );
        insert missingCompanyLead;

        List<Lead> leads = new list<Lead>();

        leads.add(missingCompanyLead);
        
        Test.startTest();
        LeadHelper.verifyCNPJ(leads);
        Test.stopTest();
    }
    
    @isTest
    static void testVerifyCompany() {
        // Obtém o tipo de registro "PessoaJuridica"
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'PessoaJuridica' LIMIT 1];
        
        // Cria um Lead sem o campo "Company" preenchido e com o tipo de registro "PessoaJuridica"
        Lead missingCompanyLead = new Lead(
            LastName = 'Sem Empresa',
            Email = 'semempresa@invalido.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '5511987654321',
            Status = 'Conversão',
            RecordTypeId = rt.Id,
            Company = 'Empresa Inválida'
        );
        insert missingCompanyLead;
        List<Lead> leads = new list<Lead>();

        leads.add(missingCompanyLead);
        
        Test.startTest();
        LeadHelper.verifyCompany(leads);
       Test.stopTest();
    }
    
    @isTest
    static void testGetMapTaskByWho() {
        // Consulta os leads criados em makeData para preparar o conjunto de IDs a serem testados
        List<Lead> leads = [SELECT Id FROM Lead];
        Set<Id> leadIds = new Set<Id>();
        for (Lead lead : leads) {
            leadIds.add(lead.Id);
        }
        // Chama o método a ser testado
        Map<Id, List<Task>> mapTaskByWho = LeadHelper.getMapTaskByWho(leadIds);
    }


    @IsTest
    static void testVerifyContactingStatus_Uncompleted() {
        Lead testLead = [SELECT Id, Status FROM Lead LIMIT 1];
        Task openTask = new Task(
            Subject = 'Chamada',
            Status = 'Não Concluído',
            WhoId = testLead.Id
        );
        insert openTask;
        Map<String, List<Lead>> statusToLeadsMap = new Map<String, List<Lead>>{
            'Open' => new List<Lead>{testLead}
        };
        Test.startTest();
        LeadHelper.verifyContactingStatus(statusToLeadsMap);
        Test.stopTest();
    }

    @IsTest
    static void testVerifyContactingStatus_Completed() {
        Lead testLead = [SELECT Id, Status FROM Lead LIMIT 1];
        Task completedTask = new Task(
            Subject = 'Email',
            Status = 'Concluído',
            WhoId = testLead.Id
        );
        insert completedTask;
        Map<String, List<Lead>> statusToLeadsMap = new Map<String, List<Lead>>{
            'Completed' => new List<Lead>{testLead}
        };
        Test.startTest();
        LeadHelper.verifyContactingStatus(statusToLeadsMap);
        Test.stopTest();
    }

    @IsTest
    static void testVerifyContactingStatus_OpenNotPresent() {
        Lead testLead = [SELECT Id, Status FROM Lead LIMIT 1];
        Task completedTask = new Task(
            Subject = 'Email',
            Status = 'Concluído',
            WhoId = testLead.Id
        );
        insert completedTask;
        Map<String, List<Lead>> statusToLeadsMap = new Map<String, List<Lead>>{
            'Open' => new List<Lead>{testLead}
        };
        Test.startTest();
        LeadHelper.verifyContactingStatus(statusToLeadsMap);
        Test.stopTest();
    }

    @IsTest
    static void testVerifyContactingStatus_AdvanceFromAttemptToContact() {
        Lead testLead = [SELECT Id, Status FROM Lead LIMIT 1];
        testLead.Status = 'Tentativa de Contato';
        update testLead;
        Task uncompletedTask = new Task(
            Subject = 'Chamada',
            Status = 'Não Concluído',
            WhoId = testLead.Id
        );
        insert uncompletedTask;
        Map<String, List<Lead>> statusToLeadsMap = new Map<String, List<Lead>>{
            'Open' => new List<Lead>{testLead}
        };
        Test.startTest();
        LeadHelper.verifyContactingStatus(statusToLeadsMap);
        Test.stopTest();
    }

    @IsTest
    static void testVerifyContactingStatus_AdvanceFromContactMade() {
        Lead testLead = [SELECT Id, Status FROM Lead LIMIT 1];
        testLead.Status = 'Tentativa de Contato';
        update testLead;
        Task completedTask = new Task(
            Subject = 'Email',
            Status = 'Concluído',
            WhoId = testLead.Id
        );
        insert completedTask;
        Map<String, List<Lead>> statusToLeadsMap = new Map<String, List<Lead>>{
            'Completed' => new List<Lead>{testLead}
        };
        Test.startTest();
        LeadHelper.verifyContactingStatus(statusToLeadsMap);
        Test.stopTest();
    }

    @IsTest
    static void testVerifyContactingStatus_AdvanceFromAttemptToContactTask() {
        Lead testLead = [SELECT Id, Status FROM Lead LIMIT 1];
        testLead.Status = 'Tentativa de Contato';
        update testLead;
        Map<String, List<Lead>> statusToLeadsMap = new Map<String, List<Lead>>{
            'Open' => new List<Lead>{testLead}
        };
        Test.startTest();
        try {
            LeadHelper.verifyContactingStatus(statusToLeadsMap);
            Test.stopTest();
        } catch (DmlException e) {
            // Assert that the error message is as expected
            System.assert(e.getMessage().contains('É necessário ter pelo menos uma tarefa'), 'Expected error message not found');
        }
    }

    // @IsTest
    // static void testCheckAndUpdateLeadsWithTasks() {
    //     List<Lead> lstLead = [SELECT Id, Status FROM Lead];
    //     Test.startTest();
    //     lstLead[0].Status = 'Prospecção';
    //     LeadHelper.checkAndUpdateLeadsWithTasks(lstLead, new Map<Id, Lead>(new List<Lead>{new Lead(Id = lstLead[0].Id, Status = 'Nutrindo')}));
    //     delete [SELECT Id FROM Task];
    //     LeadHelper.checkAndUpdateLeadsWithTasks(lstLead, new Map<Id, Lead>(new List<Lead>{new Lead(Id = lstLead[0].Id, Status = 'Nutrindo')}));
    //     Test.stopTest();
    //     System.assertEquals(true, lstLead[0].hasErrors());
   
    // }
    @IsTest
    static void testHandleLeadReiteration() {
        Empreendimento__c empreendimento = new Empreendimento__c();  
    empreendimento.Name = 'Teste empreendimento';  
    empreendimento.CNPJEmpreendimento__c = '12345678000195'; // Insira um CNPJ válido
    insert empreendimento; 

        Lead testLead = new Lead(
            LastName = 'Elera Lima',
            Company = 'Empresa XYZ',
            Email = 'eleraLima@gmail.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '11985632415', // Ajustado para conter apenas números e 14 dígitos
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;

        Map<String, Object> params = new Map<String, Object>{
            'campaignName' => 'Test Campaign',
            'MobilePhone' => '5511985632478', // Adjusted to contain only numbers and 14 digits
            'Email' => 'joaosilva@gmail.com',
            'EmpreendimentoInteresse__c' => 'a01Dw00000OFimLIAT',
            'LeadSource' => 'Outdoor',
            'CanalAtendimento__c' => 'Chat'
        };

        Test.startTest();
        LeadHelper.handleLeadReiteration(testLead, params);
        Test.stopTest();

        Lead updatedLead = [SELECT MobilePhone, Email, EmpreendimentoInteresse__c, LeadSource, CanalAtendimento__c FROM Lead WHERE Id = :testLead.Id];
    }

   
 
        @IsTest
        static void testVerificarCampanhas() {
            // Criação do registro de Empreendimento
            Empreendimento__c empreendimento = new Empreendimento__c(
                Name = 'Teste Empreendimento',
                CNPJEmpreendimento__c = '12345678000195' // Insira um CNPJ válido
            );
            insert empreendimento;
    
            Lead testLead = new Lead(
                LastName = 'Elera Lima',
                Company = 'Empresa XYZ',
                Email = 'eleraLima@gmail.com',
                LeadSource = 'Chat',
                CanalAtendimento__c = 'Telefone',
                MobilePhone = '11987647487',
                Status = 'Novo',
                EmpreendimentoInteresse__c = empreendimento.Id
            );
            insert testLead;
    
            testLead.Status = 'Tentativa de Contato';
            update testLead;
    
            Task task = new Task(
                Subject = 'Chamada',
                Status = 'Completed',
                WhoId = testLead.Id
            );
            insert task;
    
            Campaign testCampaign = new Campaign(
                Name = 'Campanha Teste',
                IsActive = true
            );
            insert testCampaign;
    
            CampaignMember testCampaignMember = new CampaignMember(
                CampaignId = testCampaign.Id,
                LeadId = testLead.Id
            );
            insert testCampaignMember;
    
            Test.startTest();
            LeadHelper.verificarCampanhas(testLead.Id);
            Test.stopTest();
    
        }
    
    
  
    @IsTest
    static void testIsTaskCreatedAndOpenForAttemptToContact() {
          Empreendimento__c empreendimento = new Empreendimento__c();  
    empreendimento.Name = 'Teste empreendimento';  
    empreendimento.CNPJEmpreendimento__c = '12345678000195'; // Insira um CNPJ válido
    insert empreendimento; 
        Lead testLead = new Lead(
            LastName = 'Elera Lima',
            Company = 'Empresa XYZ',
            Email = 'eleraLima@gmail.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '11987647487',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;

        Task testTask = new Task(
            Subject = 'Email',
            Status = 'Open',
            WhoId = testLead.Id
        );
        insert testTask;

        LeadHelper.isTaskCreatedAndOpenForAttemptToContact(testLead.Id);
    }

    @IsTest
    static void testHasCompletedTaskForLead() {
       Empreendimento__c empreendimento = new Empreendimento__c();  
    empreendimento.Name = 'Teste empreendimento';  
    empreendimento.CNPJEmpreendimento__c = '12345678000195'; // Insira um CNPJ válido
    insert empreendimento; 
        Lead testLead = new Lead(
            LastName = 'Elera Lima',
            Company = 'Empresa XYZ',
            Email = 'eleraLima@gmail.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '11987647487',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;

        Task testTask = new Task(
            Subject = 'Email',
            Status = 'Completed',
            WhoId = testLead.Id
        );
        insert testTask;

       LeadHelper.hasCompletedTaskForLead(testLead.Id);
        
    }

    @IsTest
    static void testIsEventCreatedForVisits() {
       Empreendimento__c empreendimento = new Empreendimento__c();  
    empreendimento.Name = 'Teste empreendimento';  
    empreendimento.CNPJEmpreendimento__c = '12345678000195'; // Insira um CNPJ válido
    insert empreendimento; 
        Lead testLead = new Lead(
            LastName = 'Elera Lima',
            Company = 'Empresa XYZ',
            Email = 'eleraLima@gmail.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '11987647487',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;


        Event testEvent = new Event(
            Subject = 'Visit',
            StartDateTime = System.now(), // Defina a data/hora de início
            DurationInMinutes = 30, // Defina a duração em minutos
            WhoId = testLead.Id
        );
        insert testEvent;

       LeadHelper.isEventCreatedForVisits(testLead.Id);
    }
    

    @IsTest
static void testUpdateLeadPhoneNumber() {
    // Criar um lead de teste
    Lead testLead = new Lead(
        LastName = 'TestLastName',
        Company = 'TestCompany',
        Email = 'test@example.com',
        MobilePhone = '1234567890',
        CanalAtendimento__c = 'Telefone',
        Status = 'Novo'
    );
    insert testLead;

    // Parâmetros com o novo número de telefone
    Map<String, Object> params = new Map<String, Object>{
        'MobilePhone' => '11963251478'
    };

    // Chamar o método de atualização do número de telefone
    // Consultar o lead atualizado do banco de dados
    Lead updatedLead = [SELECT Id, MobilePhone FROM Lead WHERE Id = :testLead.Id];

    // Verificar se o número de telefone foi atualizado corretamente
   
}

@IsTest
static void reiterarLead() {
    // Criar uma campanha de teste
    Campaign testCampaign = new Campaign(Name = 'Test Campaign');
    insert testCampaign;

    // Criar um lead existente de teste
    Lead existingLead = new Lead(
        LastName = 'Existing Last Name',
        Company = 'Existing Company',
        Email = 'existing@example.com',
        MobilePhone = '12345678904',
        Status = 'Novo',
        CanalAtendimento__c = 'Telefone'
    );
    insert existingLead;

    // Parâmetros para a reiteração do lead
    Map<String, Object> params = new Map<String, Object>{
        'campaignName' => testCampaign.Name,
        'MobilePhone' => '11987563214' // Novo número de telefone
        // Outros parâmetros, se necessário
    };

    Test.startTest();
    // Chamar o método de reiteração do lead
    LeadHelper.handleLeadReiteration(existingLead, params);
    Test.stopTest();

    // Verificar se a campanha de membro foi criada
    List<CampaignMember> campaignMembers = [SELECT Id FROM CampaignMember WHERE LeadId = :existingLead.Id];
    System.assertEquals(1, campaignMembers.size());

    // Consultar o lead atualizado do banco de dados
    Lead updatedLead = [SELECT Id, MobilePhone FROM Lead WHERE Id = :existingLead.Id];

    // Verificar se o número de telefone foi atualizado corretamente
    System.assertEquals(params.get('MobilePhone'), updatedLead.MobilePhone);
}
    
@IsTest
static void testeContato() {
    // Criar alguns leads de teste
      Empreendimento__c empreendimento = new Empreendimento__c();  
    empreendimento.Name = 'Teste empreendimento';  
    empreendimento.CNPJEmpreendimento__c = '12345678000195'; // Insira um CNPJ válido
    insert empreendimento; 
    Lead openLead = new Lead(
        LastName = 'Elera Lima',
        Company = 'Empresa XYZ',
        Email = 'eleraLima@gmail.com',
        LeadSource = 'Chat',
        CanalAtendimento__c = 'Telefone',
        MobilePhone = '11987647487',
        Status = 'Novo',
        EmpreendimentoInteresse__c = empreendimento.Id
    );
    insert openLead;

    Lead completedLead = new Lead(
        LastName = 'Elera Lima',
        Company = 'Empresa XYZ',
        Email = 'eleraLima2@gmail.com',
        LeadSource = 'Chat',
        CanalAtendimento__c = 'Telefone',
        MobilePhone = '11987647488',
        Status = 'Novo',
        EmpreendimentoInteresse__c = empreendimento.Id
    );
    insert completedLead;

    // Mapear os leads pelos seus respectivos status
    Map<String, List<Lead>> statusToLeadsMap = new Map<String, List<Lead>>{
        'Open' => new List<Lead>{openLead},
        'Completed' => new List<Lead>{completedLead}
    };

    Test.startTest();
    // Chamar o método verifyContactingStatus
    LeadHelper.verifyContactingStatus(statusToLeadsMap);
    Test.stopTest();


}


@IsTest
static void reiterarNovoLead() {
    // Criar uma campanha de teste
    Campaign testCampaign = new Campaign(Name = 'Test Campaign');
    insert testCampaign;

    // Criar um lead existente de teste
    Lead existingLead = new Lead(
        LastName = 'Existing Last Name',
        Company = 'Existing Company',
        Email = 'existing@example.com',
        MobilePhone = '1234567890',
        Status = 'Novo',
        CanalAtendimento__c = 'Telefone'
    );
    insert existingLead;

    // Parâmetros para a reiteração do lead
    Map<String, Object> params = new Map<String, Object>{
        'campaignName' => testCampaign.Name,
        'MobilePhone' => '9876543210'
    };

    existingLead.QuantidadeDeReiteracoes__c = null;

    Test.startTest();
    LeadHelper.handleLeadReiteration(existingLead, params);
    Test.stopTest();

    List<CampaignMember> campaignMembers = [SELECT Id FROM CampaignMember WHERE LeadId = :existingLead.Id];
    System.assertEquals(1, campaignMembers.size());

    Lead updatedLead = [SELECT Id, MobilePhone, QuantidadeDeReiteracoes__c FROM Lead WHERE Id = :existingLead.Id];

    System.assertEquals(params.get('MobilePhone'), updatedLead.MobilePhone);
    System.assertEquals(1, updatedLead.QuantidadeDeReiteracoes__c, 'O campo QuantidadeDeReiteracoes__c não foi inicializado corretamente');
}
@IsTest
static void testSetInterestedEnterprise() {
     Empreendimento__c empreendimento = new Empreendimento__c();  
    empreendimento.Name = 'Teste empreendimento';  
    empreendimento.CNPJEmpreendimento__c = '12345678000195'; // Insira um CNPJ válido
    insert empreendimento; 

    Lead leadWithEmpreendimentoWeb = new Lead(
        LastName = 'Lead With EmpreendimentoWeb',
        Company = 'Test Company',
        Email = 'lead1@example.com',
        CanalAtendimento__c = 'Telefone',
        EmpreendimentoInteresseWeb__c = 'Test Web Empreendimento'
    );
    insert leadWithEmpreendimentoWeb;

    Lead leadWithoutEmpreendimentoWeb1 = new Lead(
        LastName = 'Lead Without EmpreendimentoWeb 1',
        Company = 'Test Company',
        CanalAtendimento__c = 'Telefone',
        Email = 'lead2@example.com'
    );
    Lead leadWithoutEmpreendimentoWeb2 = new Lead(
        LastName = 'Lead Without EmpreendimentoWeb 2',
        Company = 'Test Company',
        CanalAtendimento__c = 'Telefone',
        Email = 'lead3@example.com'
    );
    insert new List<Lead>{leadWithoutEmpreendimentoWeb1, leadWithoutEmpreendimentoWeb2};

    Test.startTest();
    List<Lead> leadsToUpdate = new List<Lead>{leadWithoutEmpreendimentoWeb1, leadWithoutEmpreendimentoWeb2};
    LeadHelper.setInterestedEnterprise(leadsToUpdate);
    Test.stopTest();

    // Verificar se os leads foram atualizados corretamente
    List<Lead> updatedLeads = [SELECT Id, EmpreendimentoInteresse__c FROM Lead WHERE Id IN :leadsToUpdate];
    for (Lead lead : updatedLeads) {
       
    }

    // Verificar se o lead com EmpreendimentoInteresseWeb__c preenchido não foi atualizado
    Lead updatedLeadWithEmpreendimentoWeb = [SELECT Id, EmpreendimentoInteresse__c FROM Lead WHERE Id = :leadWithEmpreendimentoWeb.Id];
    System.assertEquals(null, updatedLeadWithEmpreendimentoWeb.EmpreendimentoInteresse__c, 'Lead with EmpreendimentoWeb should not have been updated');
}

    @IsTest
    static void testCreateTaskForReiteration() {
        // Recupera o lead criado na configuração do teste
        Lead testLead = [SELECT Id, OwnerId,LastName, MobilePhone, Phone, Email, EmpreendimentoInteresse__c, EmpreendimentoInteresse__r.Name, LeadSource, Status, ltima_Reitera_o__c, QuantidadeDeReiteracoes__c, CanalAtendimento__c FROM Lead LIMIT 1];

        // Chama o método a ser testado
        LeadHelper.createTaskForReiteration(testLead,testLead.EmpreendimentoInteresse__c);

        // Verifica se uma tarefa de reiteração foi criada corretamente
        Task createdTask = [SELECT Id, WhoId, Subject, Status, ActivityDate, Description FROM Task WHERE WhoId = :testLead.Id AND Subject = 'Reiteração' LIMIT 1];
        
        System.assertNotEquals(null, createdTask, 'A tarefa de reiteração não foi criada.');
        System.assertEquals('Open', createdTask.Status, 'O status da tarefa está incorreto.');
        System.assertEquals('Reiteração', createdTask.Subject, 'O assunto da tarefa está incorreto.');
    }


}