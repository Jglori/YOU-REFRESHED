@isTest
private class EmpreendimentoHelperTest {

    @isTest
    static void insertCnpjValidoTest() {
        Empreendimento__c validEmp = new Empreendimento__c();
        validEmp.Name = 'Empreendimento de Teste';
        validEmp.CNPJEmpreendimento__c = '37629040000107';

        Test.startTest();
        insert validEmp;
        Test.stopTest();
        
        Empreendimento__c insertedEmp = [SELECT Id, CNPJEmpreendimento__c FROM Empreendimento__c WHERE Id = :validEmp.Id];
        System.assertNotEquals(null, insertedEmp);
        System.assertEquals('37629040000107', insertedEmp.CNPJEmpreendimento__c);
    }

    @isTest
    static void insertCnpjInvalidoTest() {
        Empreendimento__c invalidEmp = new Empreendimento__c();
        invalidEmp.Name = 'Empreendimento de Teste';
        invalidEmp.CNPJEmpreendimento__c = '32222220000000';

        Test.startTest();
        try {
            insert invalidEmp;
            System.assert(false, 'Esperava uma exceção devido ao CNPJ inválido na atualização.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('CNPJ inválido. Por favor, insira um CNPJ válido.'));
        }
        Test.stopTest();
        
    }

    @isTest
    static void updateCnpjValidoTest() {

        Empreendimento__c validEmp = new Empreendimento__c();
        validEmp.Name = 'Empreendimento de Teste';
        validEmp.CNPJEmpreendimento__c = '37629040000107';
        insert validEmp;

        Test.startTest();
        EmpreendimentoHelper.verifyEmpreendimentoCNPJ(new List<Empreendimento__c>{validEmp});
        Test.stopTest();

        Empreendimento__c empAfterTest = [SELECT Id, CNPJEmpreendimento__c FROM Empreendimento__c WHERE Id = :validEmp.Id];
        System.assertNotEquals(null, empAfterTest);
    }

    @isTest
    static void updateCnpjInvalidoTest() {
        Empreendimento__c invalidEmp = new Empreendimento__c();
        invalidEmp.Name = 'Empreendimento de Teste';
        invalidEmp.CNPJEmpreendimento__c = '37629040000107';
        insert invalidEmp;

        invalidEmp.CNPJEmpreendimento__c = '32222220000000';
        Test.startTest();
        try {
            update invalidEmp;
            System.assert(false, 'Esperava uma exceção devido ao CNPJ inválido na atualização.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('CNPJ inválido. Por favor, insira um CNPJ válido.'));
        }
        Test.stopTest();
        
    }
}