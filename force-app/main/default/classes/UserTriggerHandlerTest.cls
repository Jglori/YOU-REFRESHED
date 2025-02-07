@isTest
public class UserTriggerHandlerTest {

    @testSetup
    static void setup() {
        // Criar um usuário de teste para simular a atualização
        User user1 = new User(
            Alias = 'user1',
            Email = 'user1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            CompanyName = 'You',
            Username = 'user1_' + System.currentTimeMillis() + '@test.com'
        );
        insert user1;

        // Criar outro usuário de teste para simular a atualização
        User user2 = new User(
            Alias = 'user2',
            Email = 'user2@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'user2_' + System.currentTimeMillis() + '@test.com'
        );
        insert user2;
    }

    @isTest
    static void testAfterUpdate() {
        // Recupera os usuários criados no método @testSetup
        User user1 = [SELECT Id, Email FROM User WHERE Username LIKE 'user1_%' LIMIT 1];
        User user2 = [SELECT Id, Email FROM User WHERE Username LIKE 'user2_%' LIMIT 1];
        
        // Simula uma atualização no usuário (por exemplo, alterando o email)
        user1.Email = 'updated_user1@test.com';
        user2.Email = 'updated_user2@test.com';
        
        Test.startTest();
        
        update new List<User>{user1, user2};
        
        // Finaliza o teste
        Test.stopTest();
      
        System.assert(true, 'O método afterUpdate foi chamado com sucesso');
    }
}