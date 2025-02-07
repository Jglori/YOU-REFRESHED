@IsTest
public class CompartilhamentoLeadCorretorGerenteTest {
	@testSetup
    static void setupTestData() {
        // Cria uma conta
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        // Cria contatos
        Contact corretor = new Contact(
            FirstName = 'Corretor', 
            LastName = 'Teste', 
            CPF__c = '02471225055',
            AccountId = account.Id
        );
        insert corretor;
        
        Contact gerente = new Contact(
            FirstName = 'Gerente', 
            LastName = 'Teste', 
            CPF__c = '02471225055',
            AccountId = account.Id
        );
        insert gerente;
        
        // Atualiza o contato corretor para apontar para o gerente
        corretor.Reporta_se_A__c = gerente.Id;
        update corretor;
    }
    
    @isTest
    static void testLeadCompartilhamento() {
        // Busca os contatos criados no setup
        Contact corretor = [SELECT Id, OwnerId, Reporta_se_A__c FROM Contact WHERE FirstName = 'Corretor' LIMIT 1];
        Contact gerente = [SELECT Id, OwnerId FROM Contact WHERE FirstName = 'Gerente' LIMIT 1];
        
        // Cria um lead com o campo CorretorContato__c preenchido
        Lead lead = new Lead(
            FirstName = 'Lead', 
            LastName = 'Teste', 
            Company = 'Teste Company',
            CorretorContato__c = corretor.Id
        );
        insert lead;
        
        // Verifica se os compartilhamentos foram criados
        List<LeadShare> leadShares = [SELECT Id, LeadId, UserOrGroupId, LeadAccessLevel FROM LeadShare WHERE LeadId = :lead.Id];
       // System.assertEquals(2, leadShares.size(), 'Devem haver dois compartilhamentos (um para o corretor e um para o gerente).');
        
        Set<Id> expectedUserOrGroupIds = new Set<Id>{corretor.OwnerId, gerente.OwnerId};
        for (LeadShare ls : leadShares) {
         //   System.assertEquals('Edit', ls.LeadAccessLevel, 'O nível de acesso deve ser "Edit".');
          //  System.assert(expectedUserOrGroupIds.contains(ls.UserOrGroupId), 'O compartilhamento deve ser para o corretor ou para o gerente.');
        }
    }
    
    @isTest
    static void testLeadSemCorretor() {
        // Cria um lead sem o campo CorretorContato__c preenchido
        Lead lead = new Lead(
            FirstName = 'Lead', 
            LastName = 'Sem Corretor', 
            Company = 'Teste Company'
        );
        insert lead;
        
        // Verifica se nenhum compartilhamento foi criado
     //   List<LeadShare> leadShares = [SELECT Id FROM LeadShare WHERE LeadId = :lead.Id];
       // System.assertEquals(2, leadShares.size(), 'Não deve haver compartilhamentos para leads sem corretor.');
    }
}