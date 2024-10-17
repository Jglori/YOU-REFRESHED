@isTest
private class TaskDATest {

    @isTest
    static void testGetContactTasksByWhoId() {
        // Criar um registro de Empreendimento__c para associar ao Lead
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento', CNPJEmpreendimento__c = '75844939000131');
        insert empreendimento;
        
        // Criar um Lead de teste associado ao Empreendimento
        Lead testLead = new Lead(
            LastName = 'Will',
            Company = 'Elera',
            Email = 'Willdantas@gmail.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11960387699',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;

        // Criar uma tarefa associada ao Lead
        Task task = new Task(
            Subject = 'Chamada',
            Status = 'Completed',
            WhoId = testLead.Id
        );
        insert task;
        
        // Chamar o método a ser testado
        Set<Id> leadsIds = new Set<Id>{testLead.Id};
        List<Task> result = TaskDA.getContactTasksByWhoId(leadsIds, true);
    }
    
    @isTest
    static void testGetOpenContactTasksByWhoId() {
        // Criar um registro de Empreendimento__c para associar ao Lead
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento',CNPJEmpreendimento__c = '75844939000131');
        insert empreendimento;
        
        // Criar um Lead de teste associado ao Empreendimento
        Lead testLead = new Lead(
            LastName = 'Ewerton',
            Company = 'São Paulo Tech School',
            Email = 'ewertonsptech@gmail.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '119847643238',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;

        // Criar uma tarefa aberta associada ao Lead
        Task task = new Task(
            Subject = 'Chamada',
            Status = 'Open',
            WhoId = testLead.Id
        );
        insert task;
        
        // Chamar o método a ser testado
        List<Task> result = TaskDA.getContactTasksByWhoId(new Set<Id>{testLead.Id}, 'Open');

        TaskDA.getLeadByLeadId(testLead.Id);
        TaskDA.buscarUltimasCampanhasLeadId(testLead.Id);
        TaskDA.buscarUltimaCampanha(testLead.Id);
        TaskDA.leadParticipaDeCampanha(testLead.Id);
        
        
        
    }
}