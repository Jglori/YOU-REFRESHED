@isTest
public class ValidarCPFContaFromTriggerTest {
    
    
    @isTest
    static void testValidarCPFBeforeUpdate() {
        // Cenário de teste para a atualização de registros Account

        // Criar uma conta com CPF válido inicialmente
        Account acc = new Account(Name = 'Conta Teste' , Cnpj__c = '56522497000162'); // CPF fictício válido
        insert acc;
        
        // Atualizar a conta com um CPF inválido
        acc.Cnpj__c = '55466587000110'; // CPF fictício inválido
        
        Test.startTest();
       // try {
            update acc;
         //   System.assert(false, 'A conta com CPF inválido deveria lançar exceção');
       // } catch (DmlException e) {
        //    System.assert(e.getDmlMessage(0).contains('CPF inválido. Por favor, insira um CPF válido. O CPF deve ser preenchido com 11 dígitos corridos'), 'A mensagem de erro do CPF inválido não está correta');
        
        Test.stopTest();
    }
    
    @isTest
    static void testCPFEmBranco() {
        // Cenário de teste para CPF em branco

        // Criar uma conta com CPF em branco
        Account acc = new Account(Name = 'Conta Teste');
        
        Test.startTest();
       // try {
            insert acc;
        /// catch (DmlException e) {
          //  System.assert(false, 'A conta com CPF em branco não deveria lançar exceção');
        //
        Test.stopTest();
    }
    
    @isTest
    static void testCPFNulo() {
        // Cenário de teste para CPF nulo

        // Criar uma conta com CPF nulo
        Account acc = new Account(Name = 'Conta Teste');
        
        Test.startTest();
        //try {
            insert acc;
        //
        Test.stopTest();
    }
}