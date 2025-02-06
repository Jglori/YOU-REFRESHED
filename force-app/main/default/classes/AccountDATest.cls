@isTest
private class AccountDATest {
 
    @TestSetup
    static void setup() {
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
            SELECT Id FROM Opportunity
        ];
        
        Test.startTest();
        Account result = AccountDA.getByOpportunityId(opp.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'A conta não deveria ser nula');
    }
}