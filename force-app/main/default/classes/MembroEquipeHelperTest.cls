@isTest
public class MembroEquipeHelperTest {

    // Método de configuração para criar dados de teste
    private static void setupTestData() {
        // Criar usuários de teste
        User user1 = new User(
            Alias = 'user1', Email = 'user1@test.com', 
            EmailEncodingKey = 'UTF-8', LastName = 'Test', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', ProfileId = UserInfo.getProfileId(), 
            TimeZoneSidKey = 'America/Los_Angeles', 
            CompanyName = 'You',
            Username = 'user1_' + System.currentTimeMillis() + '@test.com',
            Situacao__c = 'Online'
        );
        User user2 = new User(
            Alias = 'user2', Email = 'user2@test.com', 
            EmailEncodingKey = 'UTF-8', LastName = 'Test', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', ProfileId = UserInfo.getProfileId(), 
            TimeZoneSidKey = 'America/Los_Angeles', 
            CompanyName = 'You',
            Username = 'user2_' + System.currentTimeMillis() + '@test.com',
            Situacao__c = 'Offline'
        );
        insert new List<User>{user1, user2};

        // Criar equipes de teste
        Equipe__c equipe1 = new Equipe__c(Name = 'Equipe 1', CargaMaxima__c = 100);
        Equipe__c equipe2 = new Equipe__c(Name = 'Equipe 2', CargaMaxima__c = 100);
        insert new List<Equipe__c>{equipe1, equipe2};

        // Criar membros da equipe de teste
        MembroEquipe__c membro1 = new MembroEquipe__c(Name = 'Jéssica BM', Equipe__c = equipe1.Id, Usuario__c = user1.Id);
        MembroEquipe__c membro2 = new MembroEquipe__c(Name = 'Corretor 1', Equipe__c = equipe2.Id, Usuario__c = user2.Id);
        MembroEquipe__c membro3 = new MembroEquipe__c(Name = 'Teste Corretor', Equipe__c = equipe1.Id, Usuario__c = user1.Id);
        insert new List<MembroEquipe__c>{membro1, membro2, membro3};
    }

    // Método de teste para verificar duplicação de membros na equipe
    @isTest
    static void testCheckDuplicatedMember() {
        setupTestData();

        // Recuperar dados de teste
        List<MembroEquipe__c> newList = [SELECT Id, Equipe__c, Usuario__c FROM MembroEquipe__c WHERE Name = 'Teste Corretor'];

        // Invocar método a ser testado
        Test.startTest();
        MembroEquipeHelper.checkDuplicatedMember(newList);
        Test.stopTest();


    }

    // Método de teste para verificar a inserção sem duplicação
    @isTest
    static void testNoDuplicatedMember() {
        setupTestData();

        // Criar novo membro sem duplicação
        User user3 = new User(
            Alias = 'user3', Email = 'user3@test.com', 
            EmailEncodingKey = 'UTF-8', LastName = 'Test', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', ProfileId = UserInfo.getProfileId(), 
            TimeZoneSidKey = 'America/Los_Angeles', 
            CompanyName = 'You',
            Username = 'user3_' + System.currentTimeMillis() + '@test.com',
            Situacao__c = 'Online'
        );
        insert user3;

        Equipe__c equipe3 = new Equipe__c(Name = 'Equipe 3', CargaMaxima__c = 100);
        insert equipe3;

        MembroEquipe__c membro4 = new MembroEquipe__c(Name = 'Novo Membro', Equipe__c = equipe3.Id, Usuario__c = user3.Id);
        insert membro4;

        List<MembroEquipe__c> newList = new List<MembroEquipe__c>{membro4};

        // Invocar método a ser testado
        Test.startTest();
        MembroEquipeHelper.checkDuplicatedMember(newList);
        Test.stopTest();

      
    }
}