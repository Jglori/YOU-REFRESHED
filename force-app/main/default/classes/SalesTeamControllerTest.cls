@isTest
public class SalesTeamControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Buscar o Record Type correto para Contato (Corretor)
        Id corretorRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Corretor' LIMIT 1].Id;

        Profile profileId = [SELECT Id FROM Profile WHERE Name='Comercial' LIMIT 1];
        System.debug(profileId + ' profile id' + profileId.Id);
        // Criar um usuário coordenador
        User coordenador = new User(
            FirstName = 'Coordenador', LastName = 'Teste', 
            Username = 'coordenador@test.com', Email = 'coordenador@test.com',
            Alias = 'coord', TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR', EmailEncodingKey = 'UTF-8',
            ProfileId = profileId.Id,
            LanguageLocaleKey = 'pt_BR'
        );
        insert coordenador;

        // Criar um usuário gestor (Reportase)
        User gestor = new User(
            FirstName = 'Gestor', LastName = 'Teste', 
            Username = 'gestor@test.com', Email = 'gestor@test.com',
            Alias = 'gestor', TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR', EmailEncodingKey = 'UTF-8',
            ProfileId = profileId.Id,
            LanguageLocaleKey = 'pt_BR',
            Coordenador__c = coordenador.Id
        );
        insert gestor;

        // Criar um usuário corretor
        User corretor = new User(
            FirstName = 'Corretor', LastName = 'Teste', 
            Username = 'corretor@test.com', Email = 'corretor@test.com',
            Alias = 'corr', TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR', EmailEncodingKey = 'UTF-8',
            ProfileId = profileId.Id,
            LanguageLocaleKey = 'pt_BR',
            Reportase__c = gestor.Id
        );
        insert corretor;

        // Criar um contato relacionado ao corretor com o Record Type correto
        Contact contato = new Contact(
            FirstName = 'Cliente', LastName = 'Teste', 
            OwnerId = corretor.Id,
            RecordTypeId = corretorRecordTypeId
        );
        insert contato;

        // Criar uma oportunidade vinculada ao contato
        Opportunity opp = new Opportunity(
            Name = 'Oportunidade Teste', 
            StageName = 'Negociação', 
            CloseDate = Date.today(), 
            Contato__c = contato.Id
        );
        insert opp;
    }

    @isTest
    static void testGetSalesTeamMembers() {
        // Buscar a oportunidade criada no setup
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        // Chamar o método e validar resultados
        Test.startTest();
        List<SalesTeamController.SalesTeamMember> teamMembers = SalesTeamController.getSalesTeamMembers(opp.Id);
        Test.stopTest();

        // Verificar se a equipe de vendas retornou dados
        System.assertNotEquals(0, teamMembers.size(), 'A lista de membros da equipe de vendas não pode estar vazia');

        // Verificar se os usuários corretos estão na lista
        Set<Id> userIds = new Set<Id>();
        for (SalesTeamController.SalesTeamMember member : teamMembers) {
            userIds.add(member.userId);
        }

        List<User> users = [SELECT Id FROM User];
        for (User u : users) {
         
        }
    }
}