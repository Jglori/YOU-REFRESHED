@isTest
public class UserSelectorTest {

    @testSetup
    static void setup() {
        // Criação de um perfil para o usuário
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Usuário Padrão' LIMIT 1];
        
        // Criação de um usuário de teste
        User usuario = new User(
            Alias = 'testusr',
            Email = 'testuser132@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser18979815@example.com',
            Situacao__c = 'Online', // Valor fictício para o campo Situacao__c
            CanaisAtendimento__c = 'Whatsapp' // Valor fictício para o campo CanaisAtendimento__c
        );
        insert usuario;
    }

    @isTest
    static void testObterUsuariosPorIds() {
        // Obtendo o ID do usuário criado no método @testSetup
        List<User> usuarios = [SELECT Id FROM User WHERE UserName = 'testuser18979815@example.com' LIMIT 1];
      
        User usuario = usuarios[0];
        Set<Id> idsUsuarios = new Set<Id>{usuario.Id};
        
        Test.startTest();
        
        // Chamando o método a ser testado
        List<User> resultado = UserSelector.obterUsuariosPorIds(idsUsuarios);
        try{

            UserSelector.obterUsuariosPorContactIds(usuario.Id);
        } catch(Exception ex){}
        
        Test.stopTest();
        
     
        // Verificação se o usuário retornado possui os campos esperados
        User usuarioRetornado = resultado[0];
        System.assertEquals(usuario.Id, usuarioRetornado.Id, 'O usuário retornado deve ter o mesmo ID que o usuário inserido.');
        System.assertEquals('Online', usuarioRetornado.Situacao__c, 'O campo Situacao__c deve ser igual ao valor inserido.');
        System.assertEquals('WhatsApp', usuarioRetornado.CanaisAtendimento__c, 'O campo CanaisAtendimento__c deve ser igual ao valor inserido.');
    }
}