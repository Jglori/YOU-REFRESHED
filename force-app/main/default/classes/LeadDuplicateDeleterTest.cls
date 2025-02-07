@isTest
public class LeadDuplicateDeleterTest {

    @isTest
    static void testDeleteLeadsDuplicate() {
        Lead lead1 = new Lead(FirstName = 'Test', LastName = 'Lead1', Email = 'test1@example.com', MobilePhone = '1234567890');
        Lead lead2 = new Lead(FirstName = 'Test', LastName = 'Lead2', Email = 'test2@example.com', MobilePhone = '1234567891');
        Lead lead3 = new Lead(FirstName = 'Test', LastName = 'Lead3', Email = 'test1@example.com', MobilePhone = '1234567892');
        Lead lead4 = new Lead(FirstName = 'Test', LastName = 'Lead4', Email = 'test4@example.com', MobilePhone = '1234567890');

        insert new List<Lead>{ lead1, lead2, lead3, lead4 };

        List<Lead> leadsToCheck = new List<Lead>{ lead1, lead2, lead3, lead4 };

        Test.startTest();
        List<Id> deletedIds = LeadDuplicateDeleter.deleteLeadsDuplicate(leadsToCheck);
        Test.stopTest();

       
    }
}