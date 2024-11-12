@isTest
public class ValidarCPFFromContatoTriggerTest {

    @isTest
    static void testTriggerCPFValido() {
        Contact ctt = new Contact();
        ctt.FirstName = 'Test';
        ctt.LastName = 'Contato';
        ctt.CPF__c = '12345678909';
        insert ctt;
        System.assertNotEquals(null, ctt.Id);
    }

    @isTest
    static void testTriggerCPFInvalido() {
        Contact ctt = new Contact();
        ctt.FirstName = 'Test';
        ctt.LastName = 'Contato';
        ctt.CPF__c = '12345678901';
        Test.startTest();
        try {
            insert ctt;
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('CPF inválido'));
        }
        Test.stopTest();
        System.assertEquals(null, ctt.Id);
    }

}