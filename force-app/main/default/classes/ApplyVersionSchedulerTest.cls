@isTest
private class ApplyVersionSchedulerTest {
    
    

    @isTest
    static void testJobExecutionLogic() {
        // Criar um lead para teste
        Lead testLead = new Lead(
            LastName = 'Test',
            Company = 'Test Company',
            Status = 'Novo',
            DataHoraVencimento__c = Datetime.now().addMinutes(-1) // Lead a expirar 1 minuto atrás
        );
        insert testLead;

        // Iniciar o teste
        Test.startTest();
        
     
        // Finalizar o teste
        Test.stopTest();

        // Verificar se o status do lead foi atualizado
        Lead updatedLead = [SELECT Id, Status FROM Lead WHERE Id = :testLead.Id];
       
    }
}