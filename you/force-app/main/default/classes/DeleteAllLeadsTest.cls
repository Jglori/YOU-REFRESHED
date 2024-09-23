@isTest
public class DeleteAllLeadsTest {

    @testSetup
    static void setup() {
        // Criar 200 Leads para testar o método de deleção
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
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
    static void testDeleteAll() {
        // Verificar que os Leads existem antes da deleção
        Integer initialCount = [SELECT COUNT() FROM Lead];
        System.assertEquals(200, initialCount, 'Deveria haver 200 Leads no início do teste');

        // Executar o método de deleção
        Test.startTest();
        DeleteAllLeads.deleteAll();
        Test.stopTest();

        // Verificar que os Leads foram deletados
        Integer finalCount = [SELECT COUNT() FROM Lead];
        System.assertEquals(0, finalCount, 'Todos os Leads deveriam ter sido deletados');
    }
}