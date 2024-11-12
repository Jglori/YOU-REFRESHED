@isTest
public class ValidarCNPJFromEmpreendimentoTriggerTest {

    @isTest
    static void testTriggerCNPJValido() {
        Empreendimento__c emp = new Empreendimento__c ();
        emp.Name = 'Test';
        emp.CNPJEmpreendimento__c= '11084433000199';
        insert emp;
        System.assertNotEquals(null, emp.Id);
    }

    @isTest
    static void testTriggerCNPJInvalido() {
        Empreendimento__c emp= new Empreendimento__c ();
        emp.Name = 'Test';
        emp.CNPJEmpreendimento__c = '12345678901234';
        Test.startTest();
        try {
            insert emp;
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('CNPJ inválido'));
        }
        Test.stopTest();
        System.assertEquals(null, emp.Id);
    }

}