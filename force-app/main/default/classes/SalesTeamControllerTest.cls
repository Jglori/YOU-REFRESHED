@IsTest
public class SalesTeamControllerTest {
    @IsTest
    public static void testGetSalesTeamMembers() {
        // Criar dados de teste para Usuários

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' LIMIT 1];

        User user1 = new User(
            FirstName = 'Lucca',
            LastName = 'Wasley',
            Email = 'lucca.wasley@test.com',
            Username = 'lucca.wasley@test.com.salesforce',
            Alias = 'luccw',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profile.Id,
            LanguageLocaleKey = 'en_US',
            Reportase__c = null,
            Cargo__c = 'COORDENADOR 1 (COORD PRODUTO)'
        );
        insert user1;

        Profile profile2 = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' LIMIT 1];

        User user2 = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@test.com',
            Username = 'john.doe@test.com.salesforce',
            Alias = 'jdoe',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profile2.Id,
            Reportase__c = user1.Id,
            Coordenador__c = user1.Id,
            LanguageLocaleKey = 'en_US',
            Cargo__c = 'GERENTE SALÃO'
        );
        insert user2;

        Profile profile3 = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' LIMIT 1];
        
        User user3 = new User(
            FirstName = 'Jane',
            LastName = 'Doe',
            Email = 'jane.doe@test.com',
            Username = 'jane.doe@test.com.salesforce',
            Alias = 'jadoe',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profile3.Id,
            LanguageLocaleKey = 'en_US',
            Reportase__c = user1.Id,
            Cargo__c = 'CORRETOR ONLINE'
        );
        insert user3;
        
        // Criar uma conta para o contato
        Account acc = createTestAccount();

        // Criar um contato de corretor e associá-lo a user2
        Contact corretorContact = createTestCorretorContact(user2);

        // Criar oportunidade e associar o contato corretor
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Corretor__c = corretorContact.UsuarioCorretor__c
        );        
        insert opp;

        // Teste - Chama o método que estamos testando
        Test.startTest();
        List<SalesTeamController.SalesTeamMember> teamMembers = SalesTeamController.getSalesTeamMembers(opp.Id);
        Test.stopTest();

        // Verificações
        System.assertNotEquals(0, teamMembers.size(), 'A equipe de vendas não deve estar vazia.');
        System.assertEquals(2, teamMembers.size(), 'Deve haver 2 membros na equipe de vendas (corretor e superior).');

        // Verifica se o primeiro membro é user2
        System.assertEquals(user2.Id, teamMembers[0].userId, 'O primeiro membro da equipe deve ser o corretor.');
        System.assertEquals(user2.FirstName + ' ' + user2.LastName, teamMembers[0].userName, 'O nome do corretor está incorreto.');

        // Verifica se o segundo membro é user1 (Reporta-se)
        System.assertEquals(user1.Id, teamMembers[1].userId, 'O segundo membro da equipe deve ser o usuário ao qual o corretor se reporta.');
        System.assertEquals(user1.FirstName + ' ' + user1.LastName, teamMembers[1].userName, 'O nome do usuário ao qual o corretor se reporta está incorreto.');
    }
    
    @IsTest
    public static void testBuildSalesTeamAbove() {
        // Cenário 1: Hierarquia de dois níveis
        User superior1 = createTestUser('John', 'Doe', 'john.doe@test.com', 'GERENTE SALÃO', null);
        User superior2 = createTestUser('Jane', 'Smith', 'jane.smith@test.com', 'DIRETOR GERAL', superior1.Id);
        User corretor = createTestUser('Carlos', 'Silva', 'carlos.silva@test.com', 'CORRETOR ONLINE', superior2.Id);
        
        List<SalesTeamController.SalesTeamMember> teamMembers = new List<SalesTeamController.SalesTeamMember>();

        Test.startTest();
        SalesTeamController.buildSalesTeamAbove(corretor, teamMembers);
        Test.stopTest();

        // Verificar se os membros da hierarquia foram adicionados corretamente
        System.assertEquals(2, teamMembers.size(), 'Devem haver 2 membros acima do corretor na equipe.');
        System.assertEquals(superior2.Id, teamMembers[0].userId, 'O primeiro superior deve ser o usuário Jane Smith.');
        System.assertEquals(superior1.Id, teamMembers[1].userId, 'O segundo superior deve ser o usuário John Doe.');
    }
    
    @IsTest
    public static void testBuildSalesTeamBelow() {
        // Cenário 1: O usuário tem dois subordinados
        User supervisor = createTestUser('Carlos', 'Sousa', 'carlos.sousa@test.com', 'GERENTE SALÃO', null);
        User subordinate1 = createTestUser('Pedro', 'Silva', 'pedro.silva@test.com', 'CORRETOR SALÃO', supervisor.Id);
        User subordinate2 = createTestUser('Ana', 'Oliveira', 'ana.oliveira@test.com', 'CORRETOR SALÃO', supervisor.Id);
        
        List<SalesTeamController.SalesTeamMember> teamMembers = new List<SalesTeamController.SalesTeamMember>();

        Test.startTest();
        SalesTeamController.buildSalesTeamBelow(supervisor, teamMembers);
        Test.stopTest();

        // Verificar se os subordinados foram adicionados corretamente
        System.assertEquals(2, teamMembers.size(), 'Devem haver 2 subordinados na equipe.');
        System.assertEquals(subordinate1.Id, teamMembers[0].userId, 'O primeiro subordinado deve ser Pedro Silva.');
        System.assertEquals(subordinate2.Id, teamMembers[1].userId, 'O segundo subordinado deve ser Ana Oliveira.');
    }
    
    @IsTest
    public static void testContainsUser() {
        // Criar membros de equipe de teste
        SalesTeamController.SalesTeamMember member1 = new SalesTeamController.SalesTeamMember('0051g000007k4akAAA', 'John Doe', 'GERENTE');
        SalesTeamController.SalesTeamMember member2 = new SalesTeamController.SalesTeamMember('0051g000007k4alAAA', 'Jane Doe', 'CORRETOR');
        List<SalesTeamController.SalesTeamMember> teamMembers = new List<SalesTeamController.SalesTeamMember>{member1, member2};
        
        // Cenário 1: O usuário está na lista
        Boolean contains = SalesTeamController.containsUser(teamMembers, '0051g000007k4akAAA');
        System.assert(contains, 'O método deve retornar true quando o usuário estiver na lista.');

        // Cenário 2: O usuário não está na lista
        contains = SalesTeamController.containsUser(teamMembers, '0051g000007k4amAAA');
        System.assert(!contains, 'O método deve retornar false quando o usuário não estiver na lista.');
    }

    // Método auxiliar para criar usuário
    private static User createTestUser(String firstName, String lastName, String email, String cargo, Id reportaseId) {
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' LIMIT 1];

        User user = new User(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Username = email + '.salesforce',
            Alias = firstName.substring(0, 1) + lastName.substring(0, 3),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profile.Id,
            LanguageLocaleKey = 'en_US',
            Cargo__c = cargo,
            Reportase__c = reportaseId
        );
        insert user;
        return user;
    }

    private static Account createTestAccount() {
        Account acc = new Account(Name = 'Minha Conta de Teste');
        insert acc;
        return acc;
    }

    private static Contact createTestCorretorContact(User user2) {
        Account acc = new Account(Name = 'Test Account', Type = 'HouseImobiliaria');
        insert acc;

        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Corretor' LIMIT 1];
        
        Contact corretorContact = new Contact(
            FirstName = 'Carlos',
            LastName = 'Corretor',
            AccountId = acc.Id,
            RecordTypeId = rt.Id,
            UsuarioCorretor__c = user2.Id
        );
        insert corretorContact;
        return corretorContact;
    }
}