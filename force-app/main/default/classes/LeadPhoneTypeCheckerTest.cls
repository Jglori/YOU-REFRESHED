@isTest
public class LeadPhoneTypeCheckerTest {

    @isTest
    static void testCheckPhoneType() {
        Test.startTest();
        // Chamar o método que verifica o tipo do campo Phone
        String result = LeadPhoneTypeChecker.checkPhoneType();
        Test.stopTest();

        // Verificar se o resultado está correto
        System.assertEquals('Phone', result, 'O tipo do campo Phone deveria ser "Phone"');
    }
}