@isTest
public class ValidarCPFFromContaTriggerTest {

    @isTest
    static void testTriggerCPFValido() {

        Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Conta' LIMIT 1].Id;


        Account acc = new Account();
        acc.Name = 'Test Conta';
        //acc.CPF__pc = '12345678909'; // CPF válido
        acc.RecordTypeId = recordTypeId;
        insert acc;
    }

    @isTest
    static void testTriggerCPFInvalido() {

        Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Conta' LIMIT 1].Id;


        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Conta';
        //acc.CPF__pc = '12345678901'; // CPF inválido
        acc.RecordTypeId = recordTypeId;
        Test.startTest();
        try {
            insert acc;
        } catch (DmlException e) {
            //System.assert(e.getMessage().contains('CPF inválido'));
        }
        Test.stopTest();
        System.assertEquals(null, acc.Id);
    }

}