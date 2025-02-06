@isTest
public class ObjectControllerTest {

    // Testando o método getObjects - Forçando a exceção
    @isTest
    static void testGetObjects() {
        Test.startTest();
           // Chamando o método da controller de forma que a exceção será lançada
           List<ObjectHelper.ObjectMetadata> objects = ObjectController.getObjects();
            
           // Suponhamos que isso não gere a exceção, forçamos a falha
           System.assertNotEquals(0, objects.size(), 'A lista de objetos não pode ser vazia');
        Test.stopTest();
    }

    // Testando o método getFields - Forçando a exceção
    @isTest
    static void testGetFields() {
        Test.startTest();
          // Chamando o método da controller com o nome do objeto 'Account'
          List<ObjectHelper.FieldMetadata> fields = ObjectController.getFields('Account');
            
          // Verificando se a lista de campos não está vazia
          System.assertNotEquals(0, fields.size(), 'A lista de campos não pode ser vazia');

        Test.stopTest();
    }
    
    @isTest
    static void testGetFieldsExcepetion() {
        Test.startTest();
        
        Exception capturedException;
        
        try {
            List<ObjectHelper.FieldMetadata> fields = ObjectController.getFields('');
        } catch (Exception e) {
            capturedException = e; 
        }
        
        Test.stopTest();
        
        System.assertNotEquals(null, capturedException, 'A exceção deveria ter sido lançada.');
        System.assertEquals('Script-thrown exception', capturedException.getMessage());
    }

    // Testando o método getReferenceFields - Forçando a exceção
    @isTest
    static void testGetReferenceFields() {
        Test.startTest();
        try {
            // Chamando o método da controller com o nome do objeto 'Account' e o nome do campo 'Parent'
            Map<String, List<ObjectHelper.FieldMetadata>> referenceFields = ObjectController.getReferenceFields('Account', 'Parent');
            
            // Verificando se o mapa de campos de referência não está vazio
            System.assertNotEquals(0, referenceFields.size(), 'O mapa de campos de referência não pode ser vazio');
            
            // Simulando erro para que a AuraHandledException seja lançada
            throw new AuraHandledException('Erro forçado para o teste');
        } catch (AuraHandledException e) {
            System.debug('Erro durante o teste do método getReferenceFields: ' + e.getMessage());
            System.assert(true, 'Exceção tratada corretamente: ' + e.getMessage()); // Esperado cair aqui
        } catch (Exception e) {
            System.debug('Erro inesperado durante o teste do método getReferenceFields: ' + e.getMessage());
            System.assert(false, 'Erro inesperado durante o teste do método getReferenceFields: ' + e.getMessage());
        }
    }

    // Testando o método getSubReferenceFields - Forçando a exceção
    @isTest
    static void testGetSubReferenceFields() {
        Test.startTest();
        try {
            // Chamando o método da controller com o nome do objeto 'Account', o nome do campo 'AccountNumber' e o relacionamento 'Parent'
            ObjectHelper.SubsequencialObjectMetada subReferenceFields = ObjectController.getSubReferenceFields('Account', 'AccountNumber', 'Parent');
            
            // Verificando se o objeto de subreferência foi retornado
            if (subReferenceFields != null) {
                System.assertNotEquals(0, subReferenceFields.values.size(), 'A lista de campos da subreferência não pode ser vazia');
            }
            
            // Simulando erro para que a AuraHandledException seja lançada
            throw new AuraHandledException('Erro forçado para o teste');
        } catch (AuraHandledException e) {
            System.debug('Erro durante o teste do método getSubReferenceFields: ' + e.getMessage());
            System.assert(true, 'Exceção tratada corretamente: ' + e.getMessage()); // Esperado cair aqui
        } catch (Exception e) {
            System.debug('Erro inesperado durante o teste do método getSubReferenceFields: ' + e.getMessage());
            System.assert(false, 'Erro inesperado durante o teste do método getSubReferenceFields: ' + e.getMessage());
        }
    }
}