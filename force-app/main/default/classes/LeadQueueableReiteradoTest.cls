@isTest
public class LeadQueueableReiteradoTest {
    @isTest
    static void testExecute() {
        // Preparação dos dados de teste
        Lead lead = TestDataFactory.gerarLead(); // Usando o método da TestDataFactory para gerar um lead
        insert lead;

        // Atualizar alguns campos para simular mudanças antes do Queueable
        lead.Status = 'Tentativa de Contato';
        lead.Company = 'Nova Empresa';
        update lead;

        // Verificar que o lead está com os valores atualizados antes do teste
        Lead updatedLead = [SELECT Status, Company FROM Lead WHERE Id = :lead.Id];

        // Coloca o job em execução e testa a classe Queueable
        Test.startTest();
        LeadQueueableReiterado leadQueueable = new LeadQueueableReiterado(new List<Lead>{ lead });
        System.enqueueJob(leadQueueable);
        Test.stopTest();

    }
}