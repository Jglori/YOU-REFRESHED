@isTest
public class SalesTeamControllerTest {
    @testSetup
    static void setupData() {
        // Cria usuários que representam a estrutura hierárquica de exemplo
        User coordenador = new User(
            FirstName = 'Coordenador',
            LastName = 'Sales',
            Email = 'coordenador@example.com',
            Username = 'coordenador@example.com.salesforce',
            Alias = 'coord',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='CEO' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert coordenador;

        User gerente = new User(
            FirstName = 'Gerente',
            LastName = 'Sales',
            Email = 'gerente@example.com',
            Username = 'gerente@example.com.salesforce',
            Alias = 'gerent',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='CEO' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            Coordenador__c = coordenador.Id
        );
        insert gerente;

        User corretor = new User(
            FirstName = 'Corretor',
            LastName = 'Sales',
            Email = 'corretor@example.com',
            Username = 'corretor@example.com.salesforce',
            Alias = 'corret',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='CEO' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            Reportase__c = gerente.Id
        );
        insert corretor;

        User subordinado = new User(
            FirstName = 'Subordinado',
            LastName = 'Sales',
            Email = 'subordinado@example.com',
            Username = 'subordinado@example.com.salesforce',
            Alias = 'subord',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='CEO' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            Reportase__c = corretor.Id
        );
        insert subordinado;

        // Cria uma oportunidade com o corretor associado
        Opportunity opp = new Opportunity(
            Name = 'Oportunidade Teste',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Corretor__c = corretor.Id
        );
        insert opp;
    }

    @isTest
    static void testGetSalesTeamMembers() {
        // Obtém a oportunidade inserida no @testSetup
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        // Chama o método a ser testado
        Test.startTest();
        List<SalesTeamController.SalesTeamMember> teamMembers = SalesTeamController.getSalesTeamMembers(opp.Id);
        Test.stopTest();

        // Valida que a lista de membros da equipe não está vazia
        System.assertNotEquals(0, teamMembers.size(), 'A lista de membros da equipe deve conter membros.');

        // Valida que os membros esperados estão presentes
        Set<Id> memberIds = new Set<Id>();
        for (SalesTeamController.SalesTeamMember member : teamMembers) {
            memberIds.add(member.userId);
        }

        // Valida que o corretor, o gerente, o coordenador e o subordinado estão na lista
        User corretor = [SELECT Id FROM User WHERE FirstName = 'Corretor' LIMIT 1];
        User gerente = [SELECT Id FROM User WHERE FirstName = 'Gerente' LIMIT 1];
        User coordenador = [SELECT Id FROM User WHERE FirstName = 'Coordenador' LIMIT 1];
        User subordinado = [SELECT Id FROM User WHERE FirstName = 'Subordinado' LIMIT 1];

    }
}