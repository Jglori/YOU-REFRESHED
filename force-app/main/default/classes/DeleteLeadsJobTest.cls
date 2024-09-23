@isTest
public class DeleteLeadsJobTest {

    @testSetup
    static void setup() {
        // Criar 50 Leads para testar o método de deleção
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 50; i++) {
            leads.add(new Lead(
                FirstName = 'Nome ' + i,
                LastName = 'Sobrenome ' + i,
                Email = 'email' + i + '@example.com',
                MobilePhone = '1198765' + String.valueOf(1000 + i),
                LeadSource = 'Internet',
                CanalAtendimento__c = 'Telefone',
                Status = 'Novo'
            ));
        }
        insert leads;
    }

    @isTest
    static void testDeleteLeadsJob() {
        // Obter os Leads criados no setup
        List<Lead> leadsToDelete = [SELECT Id FROM Lead LIMIT 50];
        
        // Verificar que os Leads existem antes da deleção
        Integer initialCount = [SELECT COUNT() FROM Lead];
        System.assertEquals(50, initialCount, 'Deveria haver 50 Leads no início do teste');

        // Criar e enfileirar o job de deleção
        DeleteLeadsJob job = new DeleteLeadsJob(leadsToDelete);
        
        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();

        // Verificar que os Leads foram deletados
        Integer finalCount = [SELECT COUNT() FROM Lead];
        System.assertEquals(0, finalCount, 'Todos os Leads deveriam ter sido deletados');
    }
}