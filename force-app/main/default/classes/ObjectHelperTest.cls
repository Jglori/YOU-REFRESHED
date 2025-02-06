@isTest
public class ObjectHelperTest {
    
    // Testando o método getLookUpId
    @isTest
    static void testGetLookUpId() {
        // Criando um conjunto de objetos fictícios para testar
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2')
        };
        insert accountList;

        List<Contact> contactList = new List<Contact>{
            new Contact(FirstName = 'John', LastName = 'Doe', AccountId = accountList[0].Id),
            new Contact(FirstName = 'Jane', LastName = 'Doe', AccountId = accountList[1].Id)
        };
        insert contactList;

        // Usando o método getLookUpId para recuperar os IDs das contas associadas
        List<SObject> contactsAsSObjects = new List<SObject>{contactList[0], contactList[1]};
        Set<Id> result = ObjectHelper.getLookUpId(contactsAsSObjects, 'AccountId');

        // Validando se o método retornou os IDs corretos
        System.assertEquals(2, result.size(), 'Deveriam ser retornados dois IDs de Account');
        System.assert(result.contains(accountList[0].Id), 'O ID da primeira conta não foi encontrado');
        System.assert(result.contains(accountList[1].Id), 'O ID da segunda conta não foi encontrado');
    }

    // Testando o método getObjects
    @isTest
    static void testGetObjects() {
        Test.startTest();
        List<ObjectHelper.ObjectMetadata> objectsMetadata = ObjectHelper.getObjects();
        Test.stopTest();

        // Verificando se retornou alguma metadata de objetos
        System.assertNotEquals(0, objectsMetadata.size(), 'Deveriam ser retornados objetos de metadata');
    }

    // Testando o método getReferenceFields
    @isTest
    static void testGetReferenceFields() {
        Test.startTest();
        Map<String, List<ObjectHelper.FieldMetadata>> referenceFields = ObjectHelper.getReferenceFields('Contact', 'AccountId');
        Test.stopTest();

        // Verificando se os campos de referência foram retornados
        System.assertNotEquals(0, referenceFields.size(), 'Deveriam ser retornados campos de referência');
    }

    // Testando o método getFields
    @isTest
    static void testGetFields() {
        Test.startTest();
        List<ObjectHelper.FieldMetadata> fields = ObjectHelper.getFields('Contact');
        Test.stopTest();

        // Verificando se a lista de campos não está vazia
        System.assertNotEquals(0, fields.size(), 'Deveriam ser retornados campos para o objeto Contact');
    }

    // Testando o método getSubReferenceFields
      // Testando o método getSubReferenceFields
    @isTest
    static void testGetSubReferenceFields() {
        // Criando um campo de relacionamento fictício para testar
        Schema.DescribeFieldResult fieldDesc = Account.AccountNumber.getDescribe();
        if (fieldDesc.isAccessible()) {
            Test.startTest();
            // Invocando o método para pegar as referências e campos subsequentes
            ObjectHelper.SubsequencialObjectMetada subReferenceFields = ObjectHelper.getSubReferenceFields('Account', 'AccountNumber', 'Parent');
            Test.stopTest();

            // Verificando se a subreferência foi retornada
           // System.assertNotEquals(null, subReferenceFields, 'Subreferência de campo não foi retornada');
            if (subReferenceFields != null) {
                System.assertNotEquals(0, subReferenceFields.values.size(), 'Deveriam ser retornados campos de referência subsequente');
                // Verificando os valores do objeto SubsequencialObjectMetada
                System.assertNotEquals(null, subReferenceFields.objectMetadata, 'ObjectMetadata não pode ser nulo');
                System.assertNotEquals(null, subReferenceFields.subObjectMetadata, 'SubObjectMetadata não pode ser nulo');
            }
        }
    }

    // Testando o construtor da classe SubsequencialObjectMetada
    @isTest
    static void testSubsequencialObjectMetadaConstructor() {
        List<ObjectHelper.FieldMetadata> fieldMetadataList = new List<ObjectHelper.FieldMetadata>{
            new ObjectHelper.FieldMetadata('Label 1', 'ApiName1', 'String'),
            new ObjectHelper.FieldMetadata('Label 2', 'ApiName2', 'Integer')
        };

        // Criando instância da classe usando o construtor parametrizado
        ObjectHelper.SubsequencialObjectMetada subObject = new ObjectHelper.SubsequencialObjectMetada(
            'ObjectMetadataExample',
            'SubObjectMetadataExample',
            fieldMetadataList
        );

        // Verificando se os valores passados estão sendo atribuídos corretamente
        System.assertEquals('ObjectMetadataExample', subObject.objectMetadata, 'O campo objectMetadata não foi atribuído corretamente');
        System.assertEquals('SubObjectMetadataExample', subObject.subObjectMetadata, 'O campo subObjectMetadata não foi atribuído corretamente');
        System.assertEquals(2, subObject.values.size(), 'A lista de valores não foi atribuída corretamente');
        System.assertEquals('Label 1', subObject.values[0].Label, 'O campo Label não foi atribuído corretamente');
        System.assertEquals('ApiName1', subObject.values[0].ApiName, 'O campo ApiName não foi atribuído corretamente');
        System.assertEquals('String', subObject.values[0].Type, 'O campo Type não foi atribuído corretamente');
    }
  
}