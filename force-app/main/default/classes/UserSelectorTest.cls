@IsTest
public class UserSelectorTest {

    @testSetup
    static void setup() {
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
            Username = 'user1_' + System.currentTimeMillis() + '@test.com',
            Situacao__c = 'Online',
            CanaisAtendimento__c = 'WhatsApp'
        );
                
        User user2 = new User(
            Alias = 'user2', 
            Email = 'user2@test.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Test', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = UserInfo.getProfileId(), 
            TimeZoneSidKey = 'America/Los_Angeles', 
            Username = 'user2_' + System.currentTimeMillis() + '@test.com',
            CompanyName = 'You',
            Situacao__c = 'Offline'
        );
        
        insert new List<User>{user1, user2};
    }

    @IsTest
    static void testObterUsuariosPorIds() {
        // Obtendo os IDs dos usuários criados no método @testSetup
        List<User> usuarios = [SELECT Id, Situacao__c, CanaisAtendimento__c FROM User WHERE Username LIKE 'user1_%@test.com' LIMIT 1];
        
        // Certificando-se de que um usuário foi encontrado
        System.assert(!usuarios.isEmpty(), 'Deve existir ao menos um usuário correspondente ao setup.');
      
        User usuario = usuarios[0];
        Set<Id> idsUsuarios = new Set<Id>{usuario.Id};
        
        Test.startTest();
        
        // Chamando o método a ser testado
        List<User> resultado = UserSelector.obterUsuariosPorIds(idsUsuarios);
        
        // Verificação se o usuário retornado possui os campos esperados
        System.assertEquals(1, resultado.size(), 'O método deve retornar exatamente um usuário.');
        
        User usuarioRetornado = resultado[0];
        System.assertEquals(usuario.Id, usuarioRetornado.Id, 'O usuário retornado deve ter o mesmo ID que o usuário inserido.');
        System.assertEquals('Online', usuarioRetornado.Situacao__c, 'O campo Situacao__c deve ser igual ao valor inserido.');
        System.assertEquals('WhatsApp', usuarioRetornado.CanaisAtendimento__c, 'O campo CanaisAtendimento__c deve ser igual ao valor inserido.');
        
        Test.stopTest();
    }
    
 
 
      @IsTest
    static void testGetUserPorIds() {
        List<User> usuarios = [SELECT Id FROM User WHERE email = 'user1@test.com' LIMIT 1];
        
      
        User usuario = usuarios[0];
        List<Id> userIds = new List<Id>{usuario.Id};
        
        Test.startTest();
        
        List<User> resultado = UserSelector.getUserPorIds(userIds);
      
        User usuarioRetornado = resultado[0];
       
        Test.stopTest();
    }
    
    
      @isTest
    static void testObterUsuarios() {
        // Iniciar o teste
        Test.startTest();
        
        // Chamar o método que será testado
        List<User> resultado = UserSelector.obterUsuarios();
        
        // Finalizar o teste
        Test.stopTest();
    }
}