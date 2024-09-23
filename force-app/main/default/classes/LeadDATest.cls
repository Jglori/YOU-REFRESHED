@isTest
public class LeadDATest {
    @isTest
    static void testGetLeadsById() {
        // Criação do empreendimento fictício
        Empreendimento__c empreendimento = new Empreendimento__c();
        empreendimento.Name = 'Teste empreendimento';
        empreendimento.CNPJEmpreendimento__c = '36658601000133';
        insert empreendimento;

        // Criação e inserção do primeiro lead
        Lead lead1 = new Lead(
            LastName = 'Silva',
            Company = 'Empresa XYZSantiago',
            Email = 'silva@xyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '11987654321',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert lead1;

        // Atualização do status do primeiro lead
        lead1.Status = 'Tentativa de Contato';
        update lead1;

        // Criação e inserção do segundo lead
        Lead lead2 = new Lead(
            LastName = 'Santos',
            Company = 'Empresa ABC',
            Email = 'santosfj@gmail.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11960387699',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert lead2;

        // Atualização do status do segundo lead
        lead2.Status = 'Tentativa de Contato';
        update lead2;

        // Criação e inserção de tasks associadas aos leads
        Task task1 = new Task(
            Subject = 'Chamada',
            WhoId = lead1.Id,
            ActivityDate = Date.today().addDays(5),
            Status = 'Completed'
        );
        insert task1;

        Task task2 = new Task(
            Subject = 'Chamada',
            WhoId = lead2.Id,
            ActivityDate = Date.today().addDays(-5),
            Status = 'Completed'
        );
        insert task2;

        // Verificação do número de tasks inseridas
        System.assertEquals(2, [SELECT COUNT() FROM Task]);

        // Definição dos IDs dos leads e campos a serem consultados
        Set<Id> leadsIds = new Set<Id>{lead1.Id, lead2.Id};
        Set<String> camposLead = new Set<String>{'Id', 'Status'};

        // Chamada aos métodos de consulta da classe LeadDA
        List<Lead> queriedLeads1 = LeadDA.getLeadsAgendamentoById(leadsIds);
        List<Lead> queriedLeads2 = LeadDA.getLeadsByIds(leadsIds);
        List<Lead> queriedLeads3 = LeadDA.getLeadScheduledById(camposLead, leadsIds);

        // Verificação do tamanho das listas retornadas
        // System.assertEquals(2, queriedLeads1.size());
        // System.assertEquals(2, queriedLeads2.size());
        // System.assertEquals(2, queriedLeads3.size());

        // // Verificação da consistência dos IDs dos leads retornados
        // for (Lead queriedLead : queriedLeads1) {
        //     System.assert(leadsIds.contains(queriedLead.Id));
        // }
        // for (Lead queriedLead : queriedLeads2) {
        //     System.assert(leadsIds.contains(queriedLead.Id));
        // }
        // for (Lead queriedLead : queriedLeads3) {
        //     System.assert(leadsIds.contains(queriedLead.Id));
        // }
    }
}