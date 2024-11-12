@isTest
public class ValidarCNPJFromTriggerTest {

    @isTest
    static void testTriggerCNPJValido() {
        // Criar um Lead com CNPJ válido
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Lead';
        lead.Company = 'Test Company';
        lead.CNPJ__c = '11084433000199'; // CNPJ válido

        Test.startTest();
        insert lead;
        Test.stopTest();

        // Verificar se o Lead foi inserido com sucesso
        System.assertNotEquals(null, lead.Id, 'O Lead com CNPJ válido deveria ser inserido.');
    }

    @isTest
    static void testTriggerCNPJInvalido() {
        // Criar um Lead com CNPJ inválido
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Lead';
        lead.Company = 'Test Company';
        lead.CNPJ__c = '1234567823'; // CNPJ inválido

        Test.startTest();
        try {
            insert lead;
        } catch (DmlException e) {
            // Verificar se a exceção contém a mensagem correta
            System.assert(e.getMessage().contains('CNPJ inválido'), 'A mensagem de erro esperada não foi encontrada.');
        }
        Test.stopTest();
    }
}