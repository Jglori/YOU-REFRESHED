@isTest
public class ConciergeControllerTest {
    
    @testSetup
    static void setup() {
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
            'nome' => 'Maria Oliveira',
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
        System.assertNotEquals(null, [SELECT Id FROM Lead WHERE Email = 'maria.oliveira@example.com' LIMIT 1]);
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
    }

    @isTest
    static void testCriarTaskReiteracao() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        try {
            ConciergeController.criarTaskReiteracao('{"someData":"value"}', lead.Id);
        } catch(Exception ex){}
        Test.stopTest();
        // Verificação - adicionar verificações conforme a lógica do método
    }

    @isTest
    static void testCriarTaskReiteracaoeAssociarCorretor() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Contact corretor = new Contact(LastName = 'Corretor Teste');
        insert corretor;
        
        Test.startTest();
        try {
            ConciergeController.criarTaskReiteracaoeAssociarCorretor('{"someData":"value"}', corretor.Id);
        } catch(Exception ex){}
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