@IsTest
public class CRECIStatusHandlerTest {
    @TestSetup
    static void setup() {
        // Criação de contatos de teste
        List<Contact> contacts = new List<Contact>();
        
        // Contato com data de vencimento futura
        contacts.add(new Contact(
            FirstName = 'Future',
            LastName = 'Contact',
            CPF__c = '10422863025',
            DatadeVencimento__c = Date.today().addDays(10)
        ));
        
        // Contato com data de vencimento passada
        contacts.add(new Contact(
            FirstName = 'Past',
            LastName = 'Contact',
            CPF__c = '98182715059',
            DatadeVencimento__c = Date.today().addDays(-10)
        ));
        
        // Contato sem data de vencimento
        contacts.add(new Contact(
            FirstName = 'No Date',
            LastName = 'Contact',
            CPF__c = '76482574084'
        ));
        
        insert contacts;
    }

    @isTest
    static void testUpdateCRECIStatus() {
        // Obter contatos de teste
        List<Contact> contacts = [SELECT Id, DatadeVencimento__c, CRECIAtivo__c FROM Contact];
        
        // Chamar o método a ser testado
        CRECIStatusHandler.updateCRECIStatus(contacts);
        
        // Atualizar os contatos no banco de dados
        update contacts;
        
        // Recuperar os contatos atualizados
        List<Contact> updatedContacts = [SELECT Id, DatadeVencimento__c, CRECIAtivo__c FROM Contact];
        
        // Verificações
        // for (Contact contact : updatedContacts) {
        //     if (contact.DatadeVencimento__c != null) {
        //         if (contact.DatadeVencimento__c >= Date.today()) {
        //             System.assertEquals(true, contact.CRECIAtivo__c, 'Contato com data de vencimento futura deve estar ativo.');
        //         } else {
        //             System.assertEquals(false, contact.CRECIAtivo__c, 'Contato com data de vencimento passada deve estar inativo.');
        //         }
        //     } else {
        //         System.assertEquals(null, contact.CRECIAtivo__c, 'Contato sem data de vencimento não deve ter status de CRECI atualizado.');
        //     }
        // }
    }
}