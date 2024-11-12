@isTest
public class ValidarCNPJFromContaTriggerTest {

    @isTest
    static void testTriggerCNPJValido() {
   
        // Criar uma conta com CNPJ válido
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.CNPJ__c = '11084433000199';
      
        
        Test.startTest();
        insert acc;
        Test.stopTest();
        
        // Verificar se a conta foi inserida com sucesso
        System.assertNotEquals(null, acc.Id);
    }

    @isTest
    static void testTriggerCNPJInvalido() {
   

        // Criar uma conta com CNPJ inválido
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.CNPJ__c = '12345678901234'; // CNPJ inválido
       

        Test.startTest();
        try {
            insert acc;
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('CNPJ inválido. Por favor, insira um CNPJ válido. O CNPJ deve ser preenchido com 14 dígitos corridos'));
        }
        Test.stopTest();
    }

    @isTest
    static void testTriggerCNPJInvalidoVazio() {
        // Criar uma conta com CNPJ vazio
        Account acc = TestDataFactory.gerarConta();
        acc.CNPJ__c = ''; // CNPJ vazio
    
        Test.startTest();
        try {
            insert acc;
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('CNPJ inválido. Por favor, insira um CNPJ válido. O CNPJ deve ser preenchido com 14 dígitos corridos'));
        }
        Test.stopTest();
    
    }
    
}