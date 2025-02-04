@isTest
public class UserDomainTest {

    @testSetup
    static void setup() {
        User user1 = new User(Alias = 'user1', Email = 'user1@test.com', 
            EmailEncodingKey = 'UTF-8', LastName = 'Test', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', ProfileId = UserInfo.getProfileId(), 
            TimeZoneSidKey = 'America/Los_Angeles', 
            CompanyName = 'You',
            Username = 'user1_' + System.currentTimeMillis() + '@test.com',
            Situacao__c = 'Online');
                
        User user2 = new User(Alias = 'user2', Email = 'user2@test.com', 
            EmailEncodingKey = 'UTF-8', LastName = 'Test', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', ProfileId = UserInfo.getProfileId(), 
            TimeZoneSidKey = 'America/Los_Angeles', 
            Username = 'user2_' + System.currentTimeMillis() + '@test.com',
            CompanyName = 'You',
            Situacao__c = 'Offline');
        
        insert new List<User>{user1, user2};
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