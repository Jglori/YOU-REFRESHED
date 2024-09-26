@isTest
public class ConciergeServiceTest {
    
    @isTest
    static void testObterCanaisAtendimento() {
        Test.startTest();
        Map<String, String> canais = ConciergeService.obterCanaisAtendimento();
        Test.stopTest();
        
        System.assertNotEquals(null, canais, 'Os canais de atendimento não devem ser nulos.');
        System.assert(canais.size() > 0, 'A lista de canais de atendimento deve conter valores.');
    }
    
    
    
    @isTest
    static void testObterOrigens() {
        Test.startTest();
        Map<String, String> origens = ConciergeService.obterOrigens();
        Test.stopTest();
        
        System.assertNotEquals(null, origens, 'As origens não devem ser nulas.');
        System.assert(origens.size() > 0, 'A lista de origens deve conter valores.');
    }
    
    @isTest
    static void testObterLeadsPorInformacoesConcierge() {
        // Setup de dados de teste
        Lead lead = new Lead(
            FirstName = 'João',
            LastName = 'Silva',
            Email = 'joao.silva@example.com',
            MobilePhone = '11987654321',
            LeadSource = 'Internet',
            CanalAtendimento__c = 'Telefone',
            Status = 'Novo'
        );
        insert lead;
        
        Test.startTest();
        String leadsJson = ConciergeService.obterLeadsPorInformacoesConcierge('11987654321', 'joao.silva@example.com', false , '');
        Test.stopTest();
        
        System.assertNotEquals(null, leadsJson, 'O JSON de leads não deve ser nulo.');
        System.assert(leadsJson.contains('joao.silva@example.com'), 'O JSON de leads deve conter o e-mail de João Silva.');
    }
    
   @isTest
    static void testAtualizarLead() {
        // Setup de dados de teste
        Lead lead = new Lead(
            FirstName = 'Maria',
            LastName = 'Oliveira',
            Email = 'maria.oliveira@example.com',
            MobilePhone = '11987654322',
            LeadSource = 'Instagram',
            CanalAtendimento__c = 'Telefone',
            Status = 'Novo'
        );
        insert lead;
    
        // Criando um registro de RoletaLeads__c para usar no teste
        RoletaLeads__c roletaLead = new RoletaLeads__c(Name = 'Roleta Teste');
        insert roletaLead;
    
        // Preenchendo os dados do formulário
        Map<String, Object> leadData = new Map<String, Object>();
        leadData.put('id', lead.Id);
        leadData.put('idRoleta', roletaLead.Id);
        List<Map<String, Object>> formulario = new List<Map<String, Object>> { leadData };
    
        // Executando o método a ser testado
        Test.startTest();
        ConciergeService.atualizarLead(formulario);
        Test.stopTest();
    
        // Verificando se o campo RoletaLeads__c foi atualizado corretamente
        Lead updatedLead = [SELECT Id, RoletaLeads__c FROM Lead WHERE Id = :lead.Id LIMIT 1];
        System.assertEquals(roletaLead.Id, updatedLead.RoletaLeads__c, 'O campo RoletaLeads__c deve ser atualizado.');
    }

    
    @isTest
    static void testCriarLead() {
        Map<String, String> formulario = new Map<String, String>{
            'tipoPessoa' => 'Física',
            'nome' => 'Ana Souza',
            'celular' => '11987654323',
            'email' => 'ana.souza@example.com',
            'origem' => 'Web',
            'canal' => 'Telefone',
            'razaoSocial' => null,
            'phone' => null,
            'idRoletaLeads' => null,
            'nomeRepresentante' => null,
            'corretor' => null,
            'celularRepresentante' => null
        };

        Test.startTest();
        ConciergeService.criarLead(formulario);
        Test.stopTest();
        
        Lead createdLead = [SELECT Id, FirstName, LastName, Email, MobilePhone FROM Lead WHERE Email = 'ana.souza@example.com' LIMIT 1];
        System.assertNotEquals(null, createdLead, 'O Lead deve ser criado.');
        System.assertEquals('Ana', createdLead.FirstName, 'O primeiro nome deve ser Ana.');
        System.assertEquals('Souza', createdLead.LastName, 'O sobrenome deve ser Souza.');
    }
    
    
    
    @isTest
    static void testCriarTaskReiteracao() {
        // Setup de dados de teste
        Lead lead = new Lead(
            FirstName = 'Pedro',
            LastName = 'Silva',
            Email = 'pedro.silva@example.com',
            MobilePhone = '11987654324',
            LeadSource = 'Telefone',
            Status = 'Novo',
            CanalAtendimento__c = 'Telefone'
        );
        insert lead;
        
        String jsonLead = JSON.serialize(new Map<String, Object>{
            'lead' => new Map<String, Object>{
                'id' => lead.Id,
                'nomeCorretor' => 'João Corretor',
                'empreendimentoInteresse' => 'Imóvel A'
            }
        });

        Test.startTest();
        ConciergeService.criarTaskReiteracao(jsonLead, null);
        Test.stopTest();
        
        Task createdTask = [SELECT Id, Subject, Description FROM Task WHERE WhoId = :lead.Id AND Status = 'Open' LIMIT 1];
        System.assertNotEquals(null, createdTask, 'A tarefa deve ser criada.');
        System.assertEquals('Reiteração', createdTask.Subject, 'O assunto da tarefa deve ser Reiteração.');
    }

    @isTest
    static void testCriarTaskReiteracaoeAssociarCorretor() {
        // Setup de dados de teste
        Lead lead = new Lead(
            FirstName = 'Lucas',
            LastName = 'Costa',
            Email = 'lucas.costa@example.com',
            MobilePhone = '11987654325',
            LeadSource = 'Radio',
            CanalAtendimento__c = 'Telefone',
            Status = 'Novo'
        );
        insert lead;

        Contact corretor = new Contact(
            FirstName = 'Corretor',
            LastName = 'Teste',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Corretor' LIMIT 1].Id
        );
        insert corretor;

        String jsonLead = JSON.serialize(new Map<String, Object>{
            'lead' => new Map<String, Object>{
                'id' => lead.Id,
                'nomeCorretor' => 'Corretor Teste',
                'empreendimentoInteresse' => 'Imóvel B'
            }
        });

        Test.startTest();
        ConciergeService.criarTaskReiteracaoeAssociarCorretor(jsonLead, corretor.Id);
        Test.stopTest();
        
        Task createdTask = [SELECT Id, Subject, Description FROM Task WHERE WhoId = :lead.Id AND Status = 'Open' LIMIT 1];
        System.assertNotEquals(null, createdTask, 'A tarefa deve ser criada.');
        System.assertEquals('Reiteração', createdTask.Subject, 'O assunto da tarefa deve ser Reiteração.');

        Lead updatedLead = [SELECT Id, CorretorContato__c FROM Lead WHERE Id = :lead.Id LIMIT 1];
        System.assertEquals(corretor.Id, updatedLead.CorretorContato__c, 'O corretor deve estar associado ao lead.');
    }
}