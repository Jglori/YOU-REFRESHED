@isTest
public class ValidarCNPJFromContaTriggerTest {

    @isTest
    static void testTriggerCNPJValido() {
        Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Conta' LIMIT 1].Id;

        // Criar uma conta com CNPJ válido
        Account acc = new Account(RecordTypeId = recordTypeId);
        acc.Name = 'Test Account';
        acc.CNPJ__c = '11084433000199';
      
        
        Test.startTest();
        insert acc;
        Test.stopTest();
        
        // Verificar se a conta foi inserida com sucesso
    }

    @isTest
    static void testTriggerCNPJInvalido() {
        Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Conta' LIMIT 1].Id;


        // Criar uma conta com CNPJ inválido
        Account acc = new Account(RecordTypeId = recordTypeId);
        acc.Name = 'Test Account';
        acc.CNPJ__c = '12345678901234'; // CNPJ inválido
       

        Test.startTest();
        try {
            insert acc;
        } catch (DmlException e) {
            // Verificar se a exceção contém a mensagem correta
            System.assert(e.getMessage().contains('CNPJ inválido'));
        }
        Test.stopTest();
    }
}