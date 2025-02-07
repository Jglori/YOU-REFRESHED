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
    
     @isTest
    static void testBuscarPerfil() {
        // Cria um perfil de teste
        Profile perfil = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        // Cria um usuário de teste com esse perfil
          User usuarioTeste = new User(Alias = 'user1', Email = 'user1@test.com', 
            EmailEncodingKey = 'UTF-8', LastName = 'Test', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', ProfileId = UserInfo.getProfileId(), 
            TimeZoneSidKey = 'America/Los_Angeles', 
            CompanyName = 'You',
            Username = 'user1_' + System.currentTimeMillis() + '@test.com',
            Situacao__c = 'Online');
        
        // Insere o usuário de teste
        insert usuarioTeste;
        
        // Chama o método que estamos testando
        String perfilNome = ConciergeService.buscarPerfil(usuarioTeste.Id);
        
    }
 
   
}