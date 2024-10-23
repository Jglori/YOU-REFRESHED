@isTest
public class ContatoTriggerHandlerTest {
    
    @isTest
    static void testValidCPFOnInsert() {
        // Cria um contato com um CPF válido
        Contact ctt = new Contact(
            LastName = 'Teste',
            CPF__c = '88637869092' // Substitua por um CPF válido conforme a lógica do seu método de validação
        );
        
        Test.startTest();
        insert ctt;
        Test.stopTest();
        
        // Verifica se o contato foi inserido com sucesso
        Contact insertedCtt = [SELECT Id, CPF__c FROM Contact WHERE Id = :ctt.Id LIMIT 1];
        System.assertEquals('88637869092', insertedCtt.CPF__c);
    }

    @isTest
    static void testInvalidCPFOnInsert() {
        // Cria um contato com um CPF inválido
        Contact ctt = new Contact(
            LastName = 'Teste',
            CPF__c = '12345678901' // CPF inválido conforme a lógica do seu método de validação
        );
        
        Test.startTest();
        try {
            insert ctt;
            System.assert(false, 'A inserção deveria ter falhado devido ao CPF inválido.');
        } catch (DmlException e) {
            // Verifica se a exceção ocorreu e se contém a mensagem esperada
            System.assert(e.getMessage().contains('CPF inválido. Por favor, insira um CPF válido. O CPF deve ser preenchido com 11 dígitos corridos'));
        }
        Test.stopTest();
    }

    @isTest
    static void testValidCPFOnUpdate() {
        // Insere um contato inicial
        Contact ctt = new Contact(
            LastName = 'Teste',
            CPF__c = '75075149006' // CPF válido
        );
        
        insert ctt;
        
        // Atualiza o contato com um CPF válido
        ctt.CPF__c = '33425620053'; // Substitua por outro CPF válido
        
        Test.startTest();
        update ctt;
        Test.stopTest();
        
        // Verifica se o contato foi atualizado com sucesso
        Contact updatedCtt = [SELECT Id, CPF__c FROM Contact WHERE Id = :ctt.Id LIMIT 1];
        System.assertEquals('33425620053', updatedCtt.CPF__c);
    }

    @isTest
    static void testInvalidCPFOnUpdate() {
        // Insere um contato inicial
        Contact ctt = new Contact(
            LastName = 'Teste',
            CPF__c = '15811570023' // CPF válido
        );
        
        insert ctt;
        
        // Tenta atualizar o contato com um CPF inválido
        ctt.CPF__c = '11111111111'; // CPF inválido
        
        Test.startTest();
        try {
            update ctt;
            System.assert(false, 'A atualização deveria ter falhado devido ao CPF inválido.');
        } catch (DmlException e) {
            // Verifica se a exceção ocorreu e se contém a mensagem esperada
            System.assert(e.getMessage().contains('CPF inválido. Por favor, insira um CPF válido. O CPF deve ser preenchido com 11 dígitos corridos'));
        }
        Test.stopTest();
    }
}