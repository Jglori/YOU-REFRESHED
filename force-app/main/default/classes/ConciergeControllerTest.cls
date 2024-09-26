@isTest
public class ConciergeControllerTest {
    
    @testSetup
    static void setup() {
        // Configuração de dados para os testes
        // Criar um Lead como exemplo
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
    }

    @isTest
    static void testObterCanaisAtendimento() {
        Test.startTest();
        Map<String, String> result = ConciergeController.obterCanaisAtendimento();
        Test.stopTest();
        // Verificação
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testObterOrigens() {
        Test.startTest();
        Map<String, String> result = ConciergeController.obterOrigens();
        Test.stopTest();
        // Verificação
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testObterLeadsPorInformacoesConcierge() {
        Test.startTest();
        String result = ConciergeController.obterLeadsPorInformacoesConcierge('11987654321', 'joao.silva@example.com', false, '11987654321');
        Test.stopTest();
        // Verificação
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testObterRoletasLeadsVigentes() {
        Test.startTest();
        String result = ConciergeController.obterRoletasLeadsVigentes();
        Test.stopTest();
        // Verificação
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testCriarLead() {
        Test.startTest();
        Map<String, String> formulario = new Map<String, String>{
            'FirstName' => 'Maria',
            'LastName' => 'Oliveira',
            'Email' => 'maria.oliveira@example.com',
            'MobilePhone' => '11987654322',
            'LeadSource' => 'Internet',
            'CanalAtendimento__c' => 'Telefone',
            'Status' => 'Novo'
        };
        ConciergeController.criarLead(formulario);
        Test.stopTest();
        // Verificação
        Lead createdLead = [SELECT Id FROM Lead WHERE Email = 'maria.oliveira@example.com' LIMIT 1];
        System.assertNotEquals(null, createdLead);
    }

    @isTest
    static void testAtualizarLead() {
        Lead lead = [SELECT Id FROM Lead WHERE Email = 'joao.silva@example.com' LIMIT 1];
        
        Test.startTest();
        List<Map<String, Object>> formulario = new List<Map<String, Object>>{
            new Map<String, Object>{
                'Id' => lead.Id,
                'FirstName' => 'João Atualizado',
                'LastName' => 'Silva Atualizado'
            }
        };
        ConciergeController.atualizarLead(formulario);
        Test.stopTest();
        // Verificação
        Lead updatedLead = [SELECT FirstName, LastName FROM Lead WHERE Id = :lead.Id];
        System.assertEquals('João Atualizado', updatedLead.FirstName);
        System.assertEquals('Silva Atualizado', updatedLead.LastName);
    }

    @isTest
    static void testCriarTaskReiteracao() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        ConciergeController.criarTaskReiteracao('{"someData":"value"}', lead.Id);
        Test.stopTest();
        // Verificação - adicionar verificações conforme a lógica do método
    }

    @isTest
    static void testCriarTaskReiteracaoeAssociarCorretor() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Contact corretor = new Contact(LastName = 'Corretor Teste');
        insert corretor;
        
        Test.startTest();
        ConciergeController.criarTaskReiteracaoeAssociarCorretor('{"someData":"value"}', corretor.Id);
        Test.stopTest();
        // Verificação - adicionar verificações conforme a lógica do método
    }

    @isTest
    static void testBuscarTodosCorretores() {
        Test.startTest();
        List<Contact> corretores = ConciergeController.buscarTodosCorretores();
        Test.stopTest();
        // Verificação
        System.assertNotEquals(null, corretores);
    }

    @isTest
    static void testBuscarCorretoresLetra() {
        Test.startTest();
        List<Contact> corretores = ConciergeController.buscarCorretoresLetra('C');
        Test.stopTest();
        // Verificação
        System.assertNotEquals(null, corretores);
    }
}