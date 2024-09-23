@isTest
public class UserDomainTest {

    @testSetup
    static void setup() {
        // Criação de um usuário de teste
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Usuário Padrão' LIMIT 1];
        User usuario = new User(
            Alias = 'testusr',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser11321321@example.com',
            // Preenchendo o campo obrigatório `UserRoleId` com um valor válido, se necessário
            UserRoleId = null // Use um ID válido ou `null` se não for necessário
        );
        insert usuario;
    }

    @isTest
    static void testObterUsuarioPorId() {
        // Obtenção do ID do usuário criado
        User usuario = [SELECT Id FROM User LIMIT 1];
        
        Test.startTest();
        
        // Chamando o método a ser testado
        User resultado = UserDomain.obterUsuarioPorId(usuario.Id);
        
        Test.stopTest();
        
        // Verificação se o usuário retornado é o mesmo que foi inserido
        System.assertNotEquals(null, resultado, 'O usuário retornado não deve ser nulo.');
        System.assertEquals(usuario.Id, resultado.Id, 'O usuário retornado deve ter o mesmo ID que o usuário inserido.');
    }
}