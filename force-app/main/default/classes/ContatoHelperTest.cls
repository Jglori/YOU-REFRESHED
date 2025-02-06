@isTest
public class ContatoHelperTest {

    private static Contact createContact(String cpf, String statusUsuarioCorretor, Date dataVencimento, String recordTypeName) {
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        
        Contact contact = new Contact(
            LastName = 'Test', 
            RecordTypeId = recordTypeId,
            CPF__c = cpf,
            StatusUsuarioCorretor__c = statusUsuarioCorretor,
            DatadeVencimento__c = dataVencimento
        );
        return contact;
    }

    @isTest
    public static void testVerifyCPF() {
        Contact contactValido = createContact('55238106068', 'Ativo', Date.today(), 'Cliente');
        Contact contactInvalido = createContact('44138926070', 'Ativo', Date.today(), 'Cliente');
        Contact contactSemCpf = createContact('', 'Ativo', Date.today(), 'Cliente');
        
        insert new List<Contact>{contactValido, contactInvalido, contactSemCpf};

        Test.startTest();
        
        ContatoHelper.verifyCPF(new List<Contact>{contactValido, contactInvalido, contactSemCpf});
        
        Test.stopTest();
        
        List<Contact> contacts = [SELECT CPF__c, Id FROM Contact WHERE Id IN :new List<Id>{contactValido.Id, contactInvalido.Id, contactSemCpf.Id}];
        
      
        Boolean erroValido = false;
        for (Contact cont : contacts) {
            if (cont.Id == contactInvalido.Id && cont.hasErrors()) {
                erroValido = true;
                break;
            }
        }
    }

    @isTest
    public static void testHandleStatusCorretor() {
        // Criar contatos de teste
        Contact contactCongelado = createContact('37233412090', 'Congelado', Date.today(), 'Cliente');
        Contact contactDesativado = createContact('65618395010', 'Desativado', Date.today(), 'Cliente');
        
        insert new List<Contact>{contactCongelado, contactDesativado};
        
        Test.startTest();
        
        ContatoHelper.handleStatusCorretor(new List<Contact>{contactCongelado, contactDesativado});
        
        Test.stopTest();
        
        contactCongelado = [SELECT StatusCorretor__c FROM Contact WHERE Id = :contactCongelado.Id LIMIT 1];
        contactDesativado = [SELECT StatusCorretor__c FROM Contact WHERE Id = :contactDesativado.Id LIMIT 1];
        
  }

    @isTest
    public static void testHandleCRECIStatus() {
        Contact contactAtivo = createContact('75824708002', 'Ativo', Date.today().addDays(1), 'Cliente');
        Contact contactInativo = createContact('77140699020', 'Ativo', Date.today().addDays(-1), 'Cliente');
        
        insert new List<Contact>{contactAtivo, contactInativo};
        
        Test.startTest();
        
        ContatoHelper.handleCRECIStatus(new List<Contact>{contactAtivo, contactInativo});
        
        Test.stopTest();
        
        contactAtivo = [SELECT CRECIAtivo__c FROM Contact WHERE Id = :contactAtivo.Id LIMIT 1];
        contactInativo = [SELECT CRECIAtivo__c FROM Contact WHERE Id = :contactInativo.Id LIMIT 1];
        
       }
}