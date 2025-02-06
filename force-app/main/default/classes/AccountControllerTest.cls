@isTest
private class AccountControllerTest {

    @TestSetup
    static void setup() {
        // Criando conta de teste
        Account acc = new Account(Name = 'Test Account');
        insert acc;
    
        // Criando oportunidade associada à conta
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert opp;        
    }

    @isTest
    static void testGetByOpportunityId() {
        Opportunity opp = [
            SELECT Id FROM Opportunity LIMIT 1
        ];
        
        // Teste: Verificar se retorna a conta correta
        Test.startTest();
        Account result = AccountController.getByOpportunityId(opp.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'A conta não deveria ser nula');
    }

    @isTest
    static void testGetByOpportunityId_Exception() {
        // Criando uma oportunidade inválida com um ID que não existe mais
        Opportunity invalidOpp = new Opportunity(
            Name = 'Invalid Opportunity',
            AccountId = null, // Não associada a nenhuma conta
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert invalidOpp;
        
       
        Test.startTest();
        try {
        
            AccountController.getByOpportunityId(invalidOpp.Id);
            System.assert(false, 'Deveria ter lançado uma exceção');
        } catch (AuraHandledException e) {
        }
        Test.stopTest();
    }
}