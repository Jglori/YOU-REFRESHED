@isTest
private class QueryHelperTest {
    
    @TestSetup
    static void setupTestData() {
        Account account = new Account(Name = 'Test Account');
        insert account;
    }
    
    @isTest
    static void testSelectAllFields() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        SObject result = QueryHelper.selectAllFields('Account', account.Id);
        
        System.assertNotEquals(null, result);
        
        System.assert(result instanceof Account);
        
        Account retrievedAccount = (Account) result;
        System.assertEquals(account.Name, retrievedAccount.Name);
        System.assertEquals(account.Id, retrievedAccount.Id);
    }
}