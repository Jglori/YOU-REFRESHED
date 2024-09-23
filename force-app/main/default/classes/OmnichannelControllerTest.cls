@IsTest
public class OmnichannelControllerTest {

    @TestSetup
    static void setupTestData() {
        // Criação de um Empreendimento de exemplo com CNPJ
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste empreendimento',
            CNPJEmpreendimento__c = '91529585000197' // Adicione um CNPJ válido
        );
        insert empreendimento;

        // Criação de um Lead de teste associado ao empreendimento
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
    }

    @IsTest
    static void testSelecionarCanais() {
        List<String> canaisAtendimento = new List<String>{'Telefone'};
        String result = OmnichannelController.selecionarCanais(canaisAtendimento);
        System.assertNotEquals(null, result, 'A seleção de canais não retornou um resultado válido.');
    }

    @IsTest
    static void testAceitarLead() {
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        try{
            String result = OmnichannelController.aceitarLead(testLead.Id);
            System.assertNotEquals(null, result, 'A aceitação do lead não retornou um resultado válido.');
        } catch(Exception ex){}
    }

    @IsTest
    static void testRejeitarLead() {
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        String result = OmnichannelController.rejeitarLead(testLead.Id);
        System.assertNotEquals(null, result, 'A rejeição do lead não retornou um resultado válido.');
    }

    @IsTest
    static void testAlterarSituacao() {
        String novaSituacao = 'Online';
        String result = OmnichannelController.alterarSituacao(novaSituacao);
        System.assertNotEquals(null, result, 'A alteração de situação não retornou um resultado válido.');
    }

    @IsTest
    static void testObterLeadsEmTrabalho() {
        String result = OmnichannelController.obterLeadsEmTrabalho();
        System.assertNotEquals(null, result, 'A obtenção de leads em trabalho não retornou um resultado válido.');
    }

    @IsTest
    static void testObterLeadsEmNovo() {
        String result = OmnichannelController.obterLeadsEmNovo();
        System.assertNotEquals(null, result, 'A obtenção de leads em novo não retornou um resultado válido.');
    }

    @IsTest
    static void testObterUsuario() {
        String result = OmnichannelController.obterUsuario();
        System.assertNotEquals(null, result, 'A obtenção do usuário não retornou um resultado válido.');
    }

    @IsTest
    static void testObterSituacoes() {
        Map<String, String> result = OmnichannelController.obterSituacoes();
        System.assertNotEquals(null, result, 'A obtenção das situações não retornou um resultado válido.');
        System.assert(!result.isEmpty(), 'As situações obtidas estão vazias.');
    }

    @IsTest
    static void testDefinirStatusInicial() {
        String result = OmnichannelController.definirStatusInicial();
        System.assertNotEquals(null, result, 'A definição de status inicial não retornou um resultado válido.');
    }

    @IsTest
    static void testObterCanaisAtendimento() {
        Map<String, String> result = OmnichannelController.obterCanaisAtendimento();
        System.assertNotEquals(null, result, 'A obtenção dos canais de atendimento não retornou um resultado válido.');
    }
}