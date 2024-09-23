@isTest
public class LeadHelperTest {
    @TestSetup
    static void makeData(){
        doCreateData();
    }
    
    private static void doCreateData(){
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento',CNPJEmpreendimento__c ='07135796000139');
       insert empreendimento;
        
     
        Lead testLeadNovo = new Lead(
            LastName = 'Silva',
            Company = 'Empresa XYZSantiago', 
            Email = 'silva@xyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '11960387699',
            Status = 'Novo', 
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLeadNovo;

    
        testLeadNovo.Status = 'Tentativa de Contato';
        update testLeadNovo;

       
        Task taskNovo = new Task(
            Subject = 'Chamada',
            Status = 'Not Started',
            WhoId = testLeadNovo.Id
        );
        insert taskNovo;

       
        Lead leadSemTask = new Lead(
            LastName = 'Santos',
            Company = 'Empresa ABC',
            Email = 'santos@abc.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11965478599',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert leadSemTask;
    }

    
    @isTest
    static void testUpdateLeadStatusOnTaskCompletion() {
        Lead testLead = new Lead(
            LastName = 'Contato',
            Company = 'EmpresFa Teste',
            Email = 'conFFtato@teste.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '11960387699',
            Status = 'Novo'
        );
        insert testLead;
             
        
        testLead.Status = 'Tentativa de Contato';
        update testLead;
        Task taskToComplete = new Task(
            Subject = 'Chamada',
            Status = 'Completed',
            WhoId = testLead.Id
        );
        insert taskToComplete;

        
        
        List<SObject> newTasks = new List<SObject>{taskToComplete};
        Map<Id, SObject> oldTasks = new Map<Id, SObject>{
            taskToComplete.Id => new Task(
                Id = taskToComplete.Id,
                Status = 'Not Started'
            )
        };

        Test.startTest();
       
        Test.stopTest();

        testLead = [SELECT Id, Status FROM Lead WHERE Id = :testLead.Id];
        
    }
    
    
@isTest
static void testHandleLeadReiteration() {
    // Criação de um lead de teste
    Lead testLead = new Lead(
        LastName = 'TestLead',
        Company = 'TestCompany',
        Email = 'test@example.com',
        LeadSource = 'Web',
        CanalAtendimento__c = 'Telefone',
        MobilePhone = '11960387699',
        Status = 'Novo'
    );
    insert testLead;

   
    Campaign testCampaign = new Campaign(
        Name = 'Test Campaign',
        IsActive = true
    );
    insert testCampaign;

    
    Map<String, Object> params = new Map<String, Object>{
        'LastName' => 'UpdatedLastName',
        'LeadSource' => 'Telefone'
    };

    Test.startTest();
   
    LeadHelper.handleLeadReiteration(testLead, params);
    Test.stopTest();

    
    Lead updatedLead = [SELECT QuantidadeDeReiteracoes__c FROM Lead WHERE Id = :testLead.Id];
    System.assertEquals(1, updatedLead.QuantidadeDeReiteracoes__c);

    List<Task> tasks = [SELECT Id FROM Task WHERE WhoId = :testLead.Id];
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
   
    Lead testLead = new Lead(
        LastName = 'Silvfggererea',
        Company = 'Empresa XYeerZaaa',
        Email = 'testeagrge@xyz.com',
        LeadSource = 'Chat',
        CanalAtendimento__c = 'Telefone',
        MobilePhone = '11960387699',
        Status = 'Novo'
    );
    insert testLead;

    testLead.Status = 'Tentativa de Contato';
        update testLead;
    
   
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
    Lead testLead1 = [SELECT Id, Status FROM Lead LIMIT 1];
    testLead1.Status = 'Tentativa de Contato';
    update testLead1;
    
    Task uncompletedTask = new Task(
        Subject = 'Chamada',
        Status = 'Não Concluído',
        WhoId = testLead1.Id
    );
    insert uncompletedTask;
    
    Map<String, List<Lead>> statusToLeadsMap = new Map<String, List<Lead>>{
        'Open' => new List<Lead>{testLead1}
    };
    
    Test.startTest();
    LeadHelper.verifyContactingStatus(statusToLeadsMap);
    Test.stopTest();
    
    Lead updatedLead = [SELECT Id, Status FROM Lead WHERE Id = :testLead1.Id];
   
}




    @IsTest
    static void testVerifyLeadControlSLA() {
     
        Lead testLead = new Lead(
            LastName = 'Teste',
            Company = 'Empresa Teste',
            Email = 'teste@teste.com',
            LeadSource = 'Teste',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11960387699',
            Status = 'Novo'
        );
        insert testLead;
           
        testLead.Status = 'Tentativa de Contato';
        update testLead;
        
        
       
        Task emailTask = new Task(
            Subject = 'Email',
            Status = 'Completed',
            WhoId = testLead.Id
        );
        insert emailTask;

     

       
        testLead = [SELECT Id, Status, ConfiguracaoDeSLA__c, DataHoraVencimento__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(null, testLead.ConfiguracaoDeSLA__c);
        System.assertEquals(null, testLead.DataHoraVencimento__c);
    }

    @IsTest
    static void testVerifyLeadControlSLA2() {
      
        Lead testLead = new Lead(
            LastName = 'Teste',
            Company = 'Empresa Teste',
            Email = 'teste@teste.com',
            LeadSource = 'Teste',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11960387699',
            Status = 'Novo'
        );
        insert testLead;

        testLead.Status = 'Tentativa de Contato';
        update testLead;
       
        Task emailTask = new Task(
            Subject = 'Email',
            Status = 'Completed',
            WhoId = testLead.Id
        );
        insert emailTask;

       
    
        
       
        testLead = [SELECT Id, Status, ConfiguracaoDeSLA__c, DataHoraVencimento__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(null, testLead.ConfiguracaoDeSLA__c);
        System.assertEquals(null, testLead.DataHoraVencimento__c);
    }

    @IsTest
    static void testSetInterestedEnterprise() {
      
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento');
      

       
        Lead testLead1 = new Lead(
            LastName = 'Silvfggererea',
            Company = 'Empresa XYeerZaaa',
            Email = 'testeagrge@xyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '11985478599',
            Status = 'Novo',
            EmpreendimentoInteresseWeb__c = empreendimento.Name
        );
        Lead testLead2 = new Lead(
            LastName = 'Santosijtej',
            Company = 'Empresa ABuiiC',
            Email = 'santosjtyjrirjs@abc.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11960369699',
            Status = 'Novo',
            EmpreendimentoInteresseWeb__c = empreendimento.Name
        );
        insert new List<Lead>{testLead1, testLead2};

     
        Test.startTest();
        LeadHelper.setInterestedEnterprise(new List<Lead>{testLead1, testLead2});
        Test.stopTest();

      
        testLead1 = [SELECT Id,EmpreendimentoInteresse__c FROM Lead WHERE Id = :testLead1.Id];
        testLead2 = [SELECT Id,EmpreendimentoInteresse__c FROM Lead WHERE Id = :testLead2.Id];
    
  
    }


    
    @IsTest
static void testIsTaskCreatedAndOpenForAttemptToContact() {
    
    Lead testLead = new Lead(
        LastName = 'Silvfggererea',
        Company = 'Empresa XYeerZaaa',
        Email = 'testeagrge@xyz.com',
        LeadSource = 'Chat',
        CanalAtendimento__c = 'Telefone',
        MobilePhone = '11960387599',
        Status = 'Novo'
    );
    insert testLead;

     testLead.Status = 'Tentativa de Contato';
    update testLead;
    
 
    Task openTask = new Task(
        Subject = 'Chamada',
        Status = 'Not Started',
        WhoId = testLead.Id
    );
    insert openTask;

   
    
}
@IsTest
static void testHasCompletedTaskForLead() {
  
    Lead testLead = new Lead(
        LastName = 'Silvfggererea',
        Company = 'Empresa XYeerZaaa',
        Email = 'testeagrge@xyz.com',
        LeadSource = 'Chat',
        CanalAtendimento__c = 'Telefone',
        MobilePhone = '11960388699',
        Status = 'Novo'
    );
    insert testLead;

  
    testLead.Status = 'Tentativa de Contato';
    update testLead;

    
    Task completedTask = new Task(
        Subject = 'Chamada',
        Status = 'Completed',
        WhoId = testLead.Id
    );
    
    insert completedTask;
}
@IsTest
static void testHasCompletedTaskForLeads() {
 
    Lead testLead = new Lead(
        LastName = 'Silvfggererea',
        Company = 'Empresa XYeerZaaa',
        Email = 'testeagrge@xyz.com',
        LeadSource = 'Chat',
        CanalAtendimento__c = 'Telefone',
        MobilePhone = '11960387699',
        Status = 'Novo'
    );
    insert testLead;

  
    testLead.Status = 'Tentativa de Contato';
    update testLead;

    
    Task completedTask = new Task(
        Subject = 'Chamada',
        Status = 'Completed',
        WhoId = testLead.Id
    );
    

    insert completedTask;
}

   @IsTest
    static void testUpdateLeadStatusOnTaskCompletionTask() {
        List<Lead> testLeads = new List<Lead>{
            new Lead(
                LastName = 'Contato1',
                Company = 'Empresa Teste1',
                Email = 'contato1@teste.com',
                LeadSource = 'Chat',
                CanalAtendimento__c = 'Telefone',
                MobilePhone = '11960387699',
                Status = 'Novo'
            ),
            new Lead(
                LastName = 'Contato2',
                Company = 'Empresa Teste2',
                Email = 'contato2@teste.com',
                LeadSource = 'Chat',
                CanalAtendimento__c = 'Telefone',
                MobilePhone = '11985478599',
                Status = 'Novo'
            )
        };

        insert testLeads;

        Test.startTest();

       
        for (Lead lead : testLeads) {
            lead.Status = 'Tentativa de Contato';
        }
        update testLeads;

       
        List<Task> tasksToInsert = new List<Task>();
        for (Lead lead : testLeads) {
            tasksToInsert.add(new Task(
                Subject = 'Chamada',
                Status = 'Completed',
                WhoId = lead.Id
            ));
        }
        insert tasksToInsert;

        Test.stopTest();

        
        for (Lead lead : [SELECT Id, Status FROM Lead WHERE Id IN :testLeads]) {
          
        }
    }
   

@IsTest
static void testUpdateLeadStatusOnTaskCompletionLead() {
   
    Lead testLead = new Lead(
        LastName = 'Silvfggererea',
        Company = 'Empresa XYeerZaaa',
        Email = 'testeagrge@xyz.com',
        LeadSource = 'Chat',
        CanalAtendimento__c = 'Telefone',
        MobilePhone = '11965748599',
        Status = 'Novo'
    );
    insert testLead;

    testLead.Status = 'Tentativa de Contato';
    update testLead;

    
    Task completedTask = new Task(
        Subject = 'Chamada',
        Status = 'Completed',
        WhoId = testLead.Id
    );
    insert completedTask;

  
    Task uncompletedTask = new Task(
        Subject = 'Email',
        Status = 'Not Started',
        WhoId = testLead.Id
    );
    insert uncompletedTask;

  
    Test.startTest();
    Test.stopTest();

    
    testLead = [SELECT Id, Status FROM Lead WHERE Id = :testLead.Id];
 }
}