@IsTest
public class MembroEquipeSelectorTest {
    
    @TestSetup
    static void setupTestData() {
        // Criar usuários de teste
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

        // Criar equipes de teste
        Equipe__c equipe1 = new Equipe__c(Name = 'Equipe 1' , CargaMaxima__c = 100);
        Equipe__c equipe2 = new Equipe__c(Name = 'Equipe 2' , CargaMaxima__c = 100);
        insert new List<Equipe__c>{equipe1, equipe2};

        // Criar membros da equipe de teste
        MembroEquipe__c membro1 = new MembroEquipe__c(Name = 'Membro 1' , Equipe__c = equipe1.Id , Usuario__c = user1.Id);
        MembroEquipe__c membro2 = new MembroEquipe__c(Name = 'Membro 2' , Equipe__c = equipe2.Id , Usuario__c = user2.Id);
        insert new List<MembroEquipe__c>{membro1, membro2};
    }
    
    @IsTest
    static void testObterMembrosPorIdsUsuarios() {
        // Obter os IDs dos usuários criados no método setupTestData
        Set<Id> idsUsuarios = new Set<Id>();
        for (User u : [SELECT Id FROM User]) {
            idsUsuarios.add(u.Id);
        }

        Test.startTest();
        // Chamar o método a ser testado
        List<MembroEquipe__c> membros = MembroEquipeSelector.obterMembrosPorIdsUsuarios(idsUsuarios);
        Test.stopTest();

        // Verificar se os membros retornados são corretos
        System.assertEquals(2, membros.size(), 'O número de membros retornados está incorreto.');
        for (MembroEquipe__c membro : membros) {
            System.assert(idsUsuarios.contains(membro.Usuario__c), 'O ID do usuário não está contido no conjunto de IDs de usuários.');
        }
    }

    @IsTest
    static void testObterMembrosPorId() {
        // Obter os IDs dos membros criados no método setupTestData
        Set<Id> idsMembros = new Set<Id>();
        for (MembroEquipe__c m : [SELECT Id FROM MembroEquipe__c]) {
            idsMembros.add(m.Id);
        }

        Test.startTest();
        // Chamar o método a ser testado
        List<MembroEquipe__c> membros = MembroEquipeSelector.obterMembrosPorId(idsMembros);
        Test.stopTest();

        // Verificar se os membros retornados são corretos
        System.assertEquals(2, membros.size(), 'O número de membros retornados está incorreto.');
        for (MembroEquipe__c membro : membros) {
            System.assert(idsMembros.contains(membro.Id), 'O ID do membro não está contido no conjunto de IDs de membros.');
        }
    }
}