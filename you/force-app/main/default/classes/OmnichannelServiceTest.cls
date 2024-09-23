@IsTest
public class OmnichannelServiceTest {
    
    @TestSetup
    static void setup() {
        // Criação de um Empreendimento de teste
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste Empreendimento',
            CNPJEmpreendimento__c = '91529585000197' // CNPJ válido
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
        
        // Criação de um usuário para o teste (se necessário)
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }
    
    @IsTest
    static void testSelecionarCanais() {
        List<String> canaisAtendimento = new List<String>{'Chat', 'WhatsApp'};
        Test.startTest();
        String result = OmnichannelService.selecionarCanais(canaisAtendimento);
        Test.stopTest();
        
    }
    
    @IsTest
    static void testAceitarLead() {
        Lead testLead;
        try {
            testLead = [SELECT Id FROM Lead WHERE LastName = 'Silva' LIMIT 1];
        } catch (QueryException e) {
            System.assert(false, 'Lead não encontrado. Verifique se o lead foi criado corretamente.');
            return;
        }
        
        Test.startTest();
        try{
            String result = OmnichannelService.aceitarLead(testLead.Id);
        } catch (Exception ex){}
        Test.stopTest();
        
    }
    
    @IsTest
    static void testRejeitarLead() {
        Lead testLead;
        try {
            testLead = [SELECT Id FROM Lead WHERE LastName = 'Silva' LIMIT 1];
        } catch (QueryException e) {
            System.assert(false, 'Lead não encontrado. Verifique se o lead foi criado corretamente.');
            return;
        }
        
        Test.startTest();
        String result = OmnichannelService.rejeitarLead(testLead.Id);
        Test.stopTest();
        
    }
    
    @IsTest
    static void testAlterarSituacao() {
        Test.startTest();
        String result = OmnichannelService.alterarSituacao('Online');
        Test.stopTest();
        
    }
    
    @IsTest
    static void testObterLeadsEmTrabalho() {
        Test.startTest();
        String result = OmnichannelService.obterLeadsEmTrabalho();
        Test.stopTest();
        
    }
    
    @IsTest
    static void testObterUsuario() {
        Test.startTest();
        String result = OmnichannelService.obterUsuario();
        Test.stopTest();
        
    }
}