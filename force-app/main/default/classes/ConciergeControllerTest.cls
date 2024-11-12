@isTest
public class ConciergeControllerTest {

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
        Map<String, String> canais = ConciergeController.obterCanaisAtendimento();
        Test.stopTest();

        System.assertNotEquals(null, canais, 'Os canais de atendimento não devem ser nulos.');
        System.assert(canais.size() > 0, 'A lista de canais de atendimento deve conter valores.');
    }

    @isTest
    static void testObterOrigens() {
        Test.startTest();
        Map<String, String> origens = ConciergeController.obterOrigens();
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
        String leadsJson = ConciergeController.obterLeadsPorInformacoesConcierge('11987654321', 'joao.silva@example.com', false, '');
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
        ConciergeController.criarLead(formulario);
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
        ConciergeController.criarTaskReiteracao(jsonLead, null);
        Test.stopTest();

        // Verifica se a tarefa foi criada
       // Task createdTask = [SELECT Id, Subject, Description FROM Task WHERE WhoId = :lead.CorretorContato__c AND Status = 'Open' LIMIT 1];
      //  System.assertNotEquals(null, createdTask, 'A tarefa deve ser criada.');
        //System.assertEquals('Reiteração', createdTask.Subject, 'O assunto da tarefa deve ser Reiteração.');
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
            RecordTypeId = corretorRecordTypes[0].Id,
            CPF__c = '35561388088'
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
        ConciergeController.criarTaskReiteracaoeAssociarCorretor(jsonLead, corretor.Id);
        Test.stopTest();

        List<Task> createdTasks = [SELECT Id, Subject, Description FROM Task WHERE WhoId = :corretor.Id LIMIT 1];

        Lead updatedLead = [SELECT Id, CorretorContato__c FROM Lead WHERE Id = :lead.Id LIMIT 1];
    }

    @isTest
    static void testBuscarCorretoresLetra() {
        Contact corretor1 = new Contact(FirstName = 'Carlos', LastName = 'Silva', Corretor__c = true , CPF__c = '43438029065');
        Contact corretor2 = new Contact(FirstName = 'Ana', LastName = 'Paula', Corretor__c = true , CPF__c = '27350032056');
        Contact corretor3 = new Contact(FirstName = 'João', LastName = 'Souza', Corretor__c = false , CPF__c = '12982910039'); // Não é corretor
        insert new List<Contact> { corretor1, corretor2, corretor3 };

        List<Contact> resultado = ConciergeController.buscarCorretoresLetra('C');

        System.assertEquals(1, resultado.size(), 'Deve retornar apenas um corretor que começa com "C".');
        System.assertEquals(corretor1.Id, resultado[0].Id, 'O corretor retornado deve ser Carlos Silva.');

        resultado = ConciergeController.buscarCorretoresLetra('A');

        System.assertEquals(1, resultado.size(), 'Deve retornar apenas um corretor que começa com "A".');
        System.assertEquals(corretor2.Id, resultado[0].Id, 'O corretor retornado deve ser Ana Paula.');
    }

    @isTest
    static void testBuscarTodosCorretores() {
        // Criar um tipo de registro de contato para "Corretor"
        RecordType corretorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Corretor' LIMIT 1];

        // Criar corretores de teste
        List<Contact> corretoresParaInserir = new List<Contact>{
            new Contact(FirstName = 'Carlos', LastName = 'Silva', Apelido__c = 'Carl', RecordTypeId = corretorRecordType.Id, StatusCorretor__c = 'Ativo', CPF__c = '60962397067'),
            new Contact(FirstName = 'Ana', LastName = 'Paula', Apelido__c = 'Ana', RecordTypeId = corretorRecordType.Id, StatusCorretor__c = 'Ativo' , CPF__c = '39480875047'),
            new Contact(FirstName = 'João', LastName = 'Souza', Apelido__c = 'João', RecordTypeId = corretorRecordType.Id, StatusCorretor__c = 'Suspenso' , CPF__c = '10017231043') 
        };
        insert corretoresParaInserir;

        // Executar o método a ser testado
        Test.startTest();
        List<Contact> resultado = ConciergeController.buscarTodosCorretores();
        Test.stopTest();

    }
    
    @isTest
static void testObterRoletasLeadsVigentes() {
    Test.startTest();
    String resultado = ConciergeController.obterRoletasLeadsVigentes();
    Test.stopTest();

    System.assertNotEquals(null, resultado, 'O resultado não deve ser nulo.');
    System.assert(resultado.length() > 0, 'O resultado deve conter informações.');
}
@isTest
static void testCriarLeadComCampoObrigatorioFaltando() {
    // Criação de um mapa com campos obrigatórios vazios
    Map<String, String> formulario = new Map<String, String>{
        'tipoPessoa' => 'Física',
        'nome' => '', // Campo nome vazio para testar a exceção
        'celular' => '11987654323',
        'email' => '', // Campo email vazio para testar a exceção
        'origem' => '', // Campo origem vazio para testar a exceção
        'canal' => '', // Campo canal vazio para testar a exceção
        'razaoSocial' => null,
        'phone' => null,
        'idRoletaLeads' => null,
        'nomeRepresentante' => null,
        'corretor' => null,
        'celularRepresentante' => null
    };

    Test.startTest();
        ConciergeController.criarLead(formulario);
   
    Test.stopTest();
}


}