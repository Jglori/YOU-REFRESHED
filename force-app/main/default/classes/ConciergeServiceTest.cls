@isTest
public class ConciergeServiceTest {
    
    private static final String ALIAS_USUARIO_1 = 'standt';
    private static final String ALIAS_USUARIO_2 = 'teste';
    private static final String EMAIL_USUARIO_1 = 'standarduser@testorg.com';
    private static final String EMAIL_USUARIO_2 = 'teste@testorg.com';
    private static final String LAST_NAME_USUARIO_1 = 'Testing';
    private static final String LAST_NAME_USUARIO_2 = 'Testing1';
    private static final String USERNAME_USUARIO_1 = 'ksaoidsjadosajoidasjiokdaso@rsis.com';
    private static final String USERNAME_USUARIO_2 = 'a28301@rsis.com';
    
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
        String leadsJson = ConciergeService.obterLeadsPorInformacoesConcierge('11987654321', 'joao.silva@example.com', false, '');
        Test.stopTest();
        
        System.assertNotEquals(null, leadsJson, 'O JSON de leads não deve ser nulo.');
        System.assert(leadsJson.contains('joao.silva@example.com'), 'O JSON de leads deve conter o e-mail de João Silva.');
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
    
        // Verifica se o Lead foi inserido corretamente
        System.assertNotEquals(null, lead.Id, 'O Lead deve ser inserido com sucesso.');
    
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
        
        // Verifica se a tarefa foi criada
       // Task createdTask = [SELECT Id, Subject, Description FROM Task WHERE WhoId = :lead.CorretorContato__c AND Status = 'Open' LIMIT 1];
       // System.assertNotEquals(null, createdTask, 'A tarefa deve ser criada.');
       // System.assertEquals('Reiteração', createdTask.Subject, 'O assunto da tarefa deve ser Reiteração.');
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
    
     
        List<RecordType> corretorRecordTypes = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Corretor' LIMIT 1];
        System.assert(!corretorRecordTypes.isEmpty(), 'O tipo de registro "Corretor" deve existir.');
        
        Contact corretor = new Contact(
            FirstName = 'Corretor',
            LastName = 'Teste',
            CPF__c = '17407932000',
            RecordTypeId = corretorRecordTypes[0].Id
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
        
        List<Task> createdTasks = [SELECT Id, Subject, Description FROM Task WHERE WhoId = :corretor.Id LIMIT 1];
    
        Lead updatedLead = [SELECT Id, CorretorContato__c FROM Lead WHERE Id = :lead.Id LIMIT 1];
    }
    

    @isTest
    static void testBuscarCorretoresLetra() {
        Contact corretor1 = new Contact(FirstName = 'Carlos', LastName = 'Silva', Corretor__c = true , CPF__c = '82505301018');
        Contact corretor2 = new Contact(FirstName = 'Ana', LastName = 'Paula', Corretor__c = true , CPF__c = '83109354047');
        Contact corretor3 = new Contact(FirstName = 'João', LastName = 'Souza', Corretor__c = false , CPF__c = '47075903063'); // Não é corretor
        insert new List<Contact> { corretor1, corretor2, corretor3 };

        List<Contact> resultado = ConciergeService.buscarCorretoresLetra('C');
        
        System.assertEquals(1, resultado.size(), 'Deve retornar apenas um corretor que começa com "C".');
        System.assertEquals(corretor1.Id, resultado[0].Id, 'O corretor retornado deve ser Carlos Silva.');

        resultado = ConciergeService.buscarCorretoresLetra('A');
        
        System.assertEquals(1, resultado.size(), 'Deve retornar apenas um corretor que começa com "A".');
        System.assertEquals(corretor2.Id, resultado[0].Id, 'O corretor retornado deve ser Ana Paula.');
    }
    
     @isTest
    static void testBuscarTodosCorretores() {
        // Criar um tipo de registro de contato para "Corretor"
        RecordType corretorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Corretor' LIMIT 1];
        
        // Criar corretores de teste
        List<Contact> corretoresParaInserir = new List<Contact>{
            new Contact(FirstName = 'Carlos', LastName = 'Silva', Apelido__c = 'Carl', RecordTypeId = corretorRecordType.Id, StatusCorretor__c = 'Ativo', 
            CPF__c = '54480146075'),
            new Contact(FirstName = 'Ana', LastName = 'Paula', Apelido__c = 'Ana', RecordTypeId = corretorRecordType.Id, StatusCorretor__c = 'Ativo' , CPF__c = '73777010057'),
            new Contact(FirstName = 'João', LastName = 'Souza', Apelido__c = 'João', RecordTypeId = corretorRecordType.Id, StatusCorretor__c = 'Suspenso' , CPF__c = '12676067036') // Este não deve ser retornado
        };
        insert corretoresParaInserir;

        // Executar o método a ser testado
        Test.startTest();
        List<Contact> corretoresAtivos = ConciergeService.buscarTodosCorretores();
        Test.stopTest();
        

        Set<String> nomesEsperados = new Set<String>{'Carlos Silva', 'Ana Paula'};
        for (Contact corretor : corretoresAtivos) {
            System.assert(nomesEsperados.contains(corretor.FirstName + ' ' + corretor.LastName), 'O corretor deve ser um dos corretores esperados.');
        }
    }


    @isTest
    static void testSepararNomes() {
        String nomeCompleto = 'Carlos Silva';
        Map<String, String> resultado = ConciergeService.separarNomes(nomeCompleto);
        System.assertEquals('Carlos', resultado.get('firstName'), 'O primeiro nome deve ser "Carlos".');
        System.assertEquals('Silva', resultado.get('lastName'), 'O sobrenome deve ser "Silva".');

        // Teste 2: Nome apenas com sobrenome
        String nomeSobrenome = 'Silva';
        resultado = ConciergeService.separarNomes(nomeSobrenome);
        System.assertEquals('', resultado.get('firstName'), 'O primeiro nome deve ser vazio.');
        System.assertEquals('Silva', resultado.get('lastName'), 'O sobrenome deve ser "Silva".');

        // Teste 3: Nome vazio
        String nomeVazio = '';
        resultado = ConciergeService.separarNomes(nomeVazio);
        System.assertEquals('', resultado.get('firstName'), 'O primeiro nome deve ser vazio.');
        System.assertEquals('', resultado.get('lastName'), 'O sobrenome deve ser vazio.');

        // Teste 4: Nome com múltiplos espaços
        String nomeMultiploEspacos = '   Carlos Silva   ';
        resultado = ConciergeService.separarNomes(nomeMultiploEspacos.trim()); // Usando trim() para remover espaços
        System.assertEquals('Carlos', resultado.get('firstName'), 'O primeiro nome deve ser "Carlos".');
        System.assertEquals('Silva', resultado.get('lastName'), 'O sobrenome deve ser "Silva".');

        // Teste 5: Nome com um único nome
        String nomeUnico = 'Carlos';
        resultado = ConciergeService.separarNomes(nomeUnico);
        System.assertEquals('', resultado.get('firstName'), 'O primeiro nome deve ser vazio.');
        System.assertEquals('Carlos', resultado.get('lastName'), 'O sobrenome deve ser "Carlos".');
    }
    
    
  

    @isTest
    static void testCriarTarefaReiteracaoSeNecessario() {
         Id perfilAdministradorSistema = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator'].id;
		
        Contact ctt = new Contact(LastName = 'jorge',DatadeVencimento__c = Date.Today(), CPF__c = '17407932000');
        insert ctt;
        
        update ctt;
        
        List<User> proprietario = new List<User>{
            new User(
                Alias = ALIAS_USUARIO_1,
                Email = EMAIL_USUARIO_1,
                EmailEncodingKey = 'UTF-8',
                LastName = LAST_NAME_USUARIO_1,
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = USERNAME_USUARIO_1,
                ProfileId = perfilAdministradorSistema,
                Situacao__c = 'Online'
            ),
            new User(
                Alias = ALIAS_USUARIO_2,
                Email = EMAIL_USUARIO_2,
                EmailEncodingKey = 'UTF-8',
                LastName = LAST_NAME_USUARIO_2,
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = USERNAME_USUARIO_2,
                ProfileId = perfilAdministradorSistema,
                Situacao__c = 'Online'
            )
        };
        insert proprietario;

        Contact corretor = new Contact(
            FirstName = 'Corretor',
            LastName = 'Teste',
            Email = 'corretor@teste.com',
            CPF__c = '92546486047'
        );
        insert corretor;

        // Criar lead existente
        Lead leadExistente = new Lead(
            FirstName = 'Lead',
            LastName = 'Existente',
            Email = 'lead@teste.com',
            Company = 'Empresa Teste',
            MobilePhone = '1234567890',
            LeadSource = 'Web',
            CorretorContato__c = corretor.Id
        );
        insert leadExistente;

        // Criar tarefa aberta existente
        Task tarefaExistente = new Task(
            WhoId = leadExistente.Id,
            Subject = 'Tarefa Existente',
            Status = 'Open'
        );
        insert tarefaExistente;

        // Criar novo lead com o mesmo email
        Lead novoLead = new Lead(
            FirstName = 'Novo',
            LastName = 'Lead',
            Email = 'lead@teste.com',
            Company = 'Nova Empresa',
            MobilePhone = '0987654321',
            LeadSource = 'Phone'
        );
        insert novoLead;


        // Executar o método a ser testado
        Test.startTest();
        ConciergeService.criarTarefaReiteracaoSeNecessario(novoLead);
        Test.stopTest();

        // Verificar atualizações no lead existente
        Lead leadAtualizado = [SELECT Id, MobilePhone, LeadSource, QuantidadeDeReiteracoes__c FROM Lead WHERE Id = :leadExistente.Id];
        System.assertEquals('0987654321', leadAtualizado.MobilePhone, 'O número de telefone deve ser atualizado');
        System.assertEquals('Phone', leadAtualizado.LeadSource, 'A origem do lead deve ser atualizada');
        System.assertEquals(1, leadAtualizado.QuantidadeDeReiteracoes__c, 'A quantidade de reiterações deve ser incrementada');

        // Verificar se a tarefa existente foi completada
        Task tarefaCompletada = [SELECT Id, Status FROM Task WHERE Id = :tarefaExistente.Id];
        System.assertEquals('Completed', tarefaCompletada.Status, 'A tarefa existente deve ser marcada como completada');

        // Verificar se uma nova tarefa foi criada
        List<Task> novasTarefas = [SELECT Id, Subject, Status, WhoId, ActivityDate, Description FROM Task WHERE WhoId = :corretor.Id AND Subject = 'Reiteração'];
        System.assertEquals(1, novasTarefas.size(), 'Uma nova tarefa de reiteração deve ser criada');
        Task novaTarefa = novasTarefas[0];
        System.assertEquals('Open', novaTarefa.Status, 'A nova tarefa deve estar aberta');
        System.assertEquals(Date.today().addDays(1), novaTarefa.ActivityDate, 'A data da atividade deve ser amanhã');
      //  System.assert(novaTarefa.Description.contains('Empreendimento Teste'), 'A descrição deve conter o nome do empreendimento');

        // Verificar se o email foi enviado
        //System.assertEquals(1, Limits.getEmailInvocations(), 'Um email deve ser enviado');

    }

    // Classe mock para simular o método notifyUsers
    public class ConciergeServiceMock implements System.StubProvider {
        public Integer notifyUsersCalls = 0;

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, 
                                       Type returnType, List<Type> listOfParamTypes, 
                                       List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'notifyUsers') {
                notifyUsersCalls++;
            }
            return null;
        }
    }

   
}