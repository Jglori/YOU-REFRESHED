@isTest
private class UserDTOTest {

    @isTest
    static void testUserDTOConstructor() {
        // Criar um registro de User de teste
        User testUser = new User(
            Alias = 'wdantas',
            Email = 'wdantas@example.com',
            ProfileId = UserInfo.getProfileId(), // Usar o ProfileId padrão
            Username = 'wdantas@test.com',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/New_York',
            FirstName = 'Dantas',
            LastName = 'Will',
             LanguageLocaleKey = 'pt_BR',
            Situacao__c = 'Online',
            CanaisAtendimento__c = 'Telefone' // Definir os canais de atendimento
        );
        insert testUser;

        // Instanciar o UserDTO usando o User de teste
        UserDTO userDTO = new UserDTO(testUser);

        // Verificar os valores no UserDTO
        System.assertEquals(testUser.Id, userDTO.id, 'O ID deve corresponder ao User');
        System.assertEquals(testUser.Situacao__c, userDTO.situacao, 'A situação deve corresponder ao User');
    }

    @isTest
    static void testUserDTOConstructorWithEmptyCanaisAtendimento() {
        // Criar um registro de User com CanaisAtendimento__c vazio
        User testUser = new User(
            Alias = 'jewerton',
            Email = 'ewertonjdon@example.com',
            ProfileId = UserInfo.getProfileId(), // Usar o ProfileId padrão
            Username = 'ewerton@test.com',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/New_York',
             LanguageLocaleKey = 'pt_BR',
            FirstName = 'ewerton',
            LastName = 'jdon',
            Situacao__c = 'Online',
            CanaisAtendimento__c = 'Telefone' // Canais de atendimento vazio
        );
        insert testUser;

        // Instanciar o UserDTO usando o User de teste
        UserDTO userDTO = new UserDTO(testUser);

        // Verificar os valores no UserDTO
        System.assertEquals(testUser.Id, userDTO.id, 'O ID deve corresponder ao User');
        System.assertEquals(testUser.Situacao__c, userDTO.situacao, 'A situação deve corresponder ao User');
     
    }

    @isTest
    static void testUserDTOConstructorWithNullCanaisAtendimento() {
        // Criar um registro de User com CanaisAtendimento__c nulo
        User testUser = new User(
            Alias = 'giulia',
            Email = 'carmona@example.com',
            ProfileId = UserInfo.getProfileId(), // Usar o ProfileId padrão
            Username = 'giuliacarmona@test.com',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/New_York',
            FirstName = 'carmona',
             LanguageLocaleKey = 'pt_BR',
            LastName = 'giulia',
            Situacao__c = 'Online',
            CanaisAtendimento__c = 'Telefone' // Canais de atendimento nulo
        );
        insert testUser;

        // Instanciar o UserDTO usando o User de teste
        UserDTO userDTO = new UserDTO(testUser);

        // Verificar os valores no UserDTO
        System.assertEquals(testUser.Id, userDTO.id, 'O ID deve corresponder ao User');
        System.assertEquals(testUser.Situacao__c, userDTO.situacao, 'A situação deve corresponder ao User');
        
    }
  
}