@isTest
public class ValidarCPFFromTriggerTest {

    @isTest
    static void testTriggerCPFValido() {
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Lead';
        lead.CPF__c = '12345678909'; // CPF válido
        lead.CanalAtendimento__c = 'Whatsapp';
        lead.Email = 'g@d.com';

        insert Lead;
        System.assertNotEquals(null, lead.Id);
    }

    @isTest
    static void testTriggerCPFInvalido() {
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.email = 'Lead@g.com';
        lead.LastName = 'Lead';
        lead.CPF__c = '12345678901'; // CPF inválido
        lead.CanalAtendimento__c = 'Whatsapp';
        Test.startTest();
        try {
            insert lead;
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('CPF inválido'));
        }
        Test.stopTest();
        System.assertEquals(null, lead.Id);
    }

}