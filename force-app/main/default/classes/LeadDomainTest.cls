@isTest
public class LeadDomainTest {
    @isTest
    static void testObterLeadPorId() {
        // Criação de um Empreendimento de teste
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste Empreendimento',
            CNPJEmpreendimento__c = '12345678000195'
        );
        insert empreendimento;

        // Criação de um Lead de teste associado ao Empreendimento
        Lead testLead = new Lead(
            LastName = 'Elera Lima',
            Company = 'Empresa XYZ',
            Email = 'eleraLima@gmail.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '11987647487',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;

        // Chamar o método obterLeadPorId
        Lead resultLead = LeadDomain.obterLeadPorId(testLead.Id);
    }

    @isTest
    static void testObterLeadsPorCanalAtendimento() {
        // Criação de um Empreendimento de teste
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste Empreendimento',
            CNPJEmpreendimento__c = '12345678000195'
        );
        insert empreendimento;

        // Criação de alguns Leads de teste associados ao Empreendimento
        Lead lead1 = new Lead(
            LastName = 'Teste1',
            Company = 'Empresa XYZ',
            Email = 'teste1@empresa.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '11987600001',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );

        Lead lead2 = new Lead(
            LastName = 'Teste2',
            Company = 'Empresa XYZ',
            Email = 'teste2@empresa.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '11987600002',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );

        Lead lead3 = new Lead(
            LastName = 'Teste3',
            Company = 'Empresa XYZ',
            Email = 'teste3@empresa.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '11987600003',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert new List<Lead>{lead1, lead2, lead3};

        // Chamar o método obterLeadsPorCanalAtendimento
        Map<String, List<Lead>> leadsPorCanal = LeadDomain.obterLeadsPorCanalAtendimento(new List<Lead>{lead1, lead2, lead3});
    }
}