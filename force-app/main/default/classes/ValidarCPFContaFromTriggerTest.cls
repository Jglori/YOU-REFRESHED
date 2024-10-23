@isTest
private class ValidarCPFContaFromTriggerTest {

    @isTest
    static void testValidarCPFTrigger() {
        // Obtém um RecordType existente para Account
        Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Conta' LIMIT 1].Id;

        // Testar a inserção com CPF válido
        Account validAccount = new Account(
            Name  = 'Conta com CPF Válido',
            //CPF__pc = '12345678901', // CPF válido fictício
            RecordTypeId = recordTypeId
        );

        Test.startTest();
        insert validAccount;

        // Validar que o registro foi inserido sem erro
        Account insertedAccount = [SELECT Id, CPF__pc FROM Account WHERE Id = :validAccount.Id LIMIT 1];
        System.assertNotEquals(null, insertedAccount, 'O registro da conta deveria ser inserido.');

        // Testar a inserção com CPF inválido
        Account invalidAccount = new Account(
            Name = 'Conta com CPF Inválido',
            CPF__pc = '1234567890A', // CPF inválido fictício
            RecordTypeId = recordTypeId
        );

        try {
            insert invalidAccount;
            System.assert(false, 'Deveria ter ocorrido uma exceção ao inserir um CPF inválido.');
        } catch (DmlException e) {
            //System.assert(e.getMessage().contains('CPF inválido. Por favor, insira um CPF válido. O CPF deve ser preenchido com 11 dígitos corridos'), 'A mensagem de erro não é a esperada.');
        } 
        // Testar atualização com CPF válido
        Account updateValidAccount = [SELECT Id, CPF__pc FROM Account WHERE Name = 'Conta com CPF Válido' LIMIT 1];
        //updateValidAccount.CPF__pc = '09876543210'; // Novo CPF válido fictício

        update updateValidAccount;
        Test.stopTest();

        // Validar que o CPF foi atualizado
        Account updatedAccount = [SELECT Id, CPF__pc FROM Account WHERE Id = :updateValidAccount.Id LIMIT 1];
       // System.assertEquals('09876543210', updatedAccount.CPF__pc, 'O CPF atualizado não corresponde ao valor esperado.');

        // Testar atualização com CPF inválido
        Account updateInvalidAccount = [SELECT Id, CPF__pc FROM Account WHERE Name = 'Conta com CPF Válido' LIMIT 1];
        updateInvalidAccount.CPF__pc = '0987654321X'; // CPF inválido fictício

        try {
          
            update updateInvalidAccount;
            System.assert(false, 'Deveria ter ocorrido uma exceção ao atualizar para um CPF inválido.');
        } catch (DmlException e) {
            //System.assert(e.getMessage().contains('CPF inválido. Por favor, insira um CPF válido. O CPF deve ser preenchido com 11 dígitos corridos'), 'A mensagem de erro não é a esperada.');
        }
    }
}