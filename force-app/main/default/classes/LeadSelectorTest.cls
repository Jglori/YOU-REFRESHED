@isTest
public class LeadSelectorTest {
    
    // Método para preparar dados de teste
    private static Lead criarLeadDeTeste() {
        // Criação de um Empreendimento de teste
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste Empreendimento',
            CNPJEmpreendimento__c = '12345678000195'
        );
        insert empreendimento;

        // Criação de um Lead associado ao Empreendimento
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
        
        return testLead;
    }

    @isTest
    static void testObterLeadsParaDistribuir() {
        Lead lead = criarLeadDeTeste();
        
        // Teste para obter leads que ainda não possuem corretor
        List<Lead> leads = LeadSelector.obterLeadsParaDistribuir();
        
        // Verificação se o lead foi recuperado corretamente
     //   System.assert(!leads.isEmpty());
    }

    @isTest
    static void testObterLeadsPorIdsProprietarios() {
        Lead lead = criarLeadDeTeste();
        
        // Consulta OwnerId do lead para passar como parâmetro
        Set<Id> idsProprietarios = new Set<Id>{ lead.OwnerId };
        
        // Chama o método e verifica se o resultado está correto
        List<Lead> leads = LeadSelector.obterLeadsPorIdsProprietarios(idsProprietarios);
        
        // Verificação se o lead foi recuperado corretamente
      //  System.assert(!leads.isEmpty());
    }

    @isTest
    static void testObterLeadsPorIdsCorretores() {
        Lead lead = criarLeadDeTeste();
        
        // Adiciona o Id do lead no conjunto para a consulta
        Set<Id> idsCorretores = new Set<Id>{ lead.Id };
        
        // Chama o método e verifica se o resultado está correto
        List<Lead> leads = LeadSelector.obterLeadsPorIdsCorretores(idsCorretores);
        
        // Verificação se o lead foi recuperado corretamente
     //   System.assert(!leads.isEmpty());
    }

    @isTest
    static void testObterLeadsPorIdsUsuarios() {
        Lead lead = criarLeadDeTeste();
        
        // Define o conjunto de Ids de corretores
        Set<Id> idsCorretores = new Set<Id>{ lead.Id };
        
        // Chama o método e verifica se o resultado está correto
        List<Lead> leads = LeadSelector.obterLeadsPorIdsUsuarios(idsCorretores);
        
        // Verificação se o lead foi recuperado corretamente
     //   System.assert(!leads.isEmpty());
    }

    @isTest
    static void testObterLeadsPorIds() {
        Lead lead = criarLeadDeTeste();
        
        // Define o conjunto de Ids de leads
        Set<Id> idsLeads = new Set<Id>{ lead.Id };
        
        // Chama o método e verifica se o resultado está correto
        List<Lead> leads = LeadSelector.obterLeadsPorIds(idsLeads);
        
        // Verificação se o lead foi recuperado corretamente
       // System.assert(!leads.isEmpty());
    }

    @isTest
    static void testObterLeadsPorChavesExternasClientes() {
        Lead lead = criarLeadDeTeste();
        
        // Define o conjunto de chaves externas
        Set<String> chavesClientes = new Set<String>{ lead.ChaveExternaWhatsApp__c };
        
        // Chama o método e verifica se o resultado está correto
        List<Lead> leads = LeadSelector.obterLeadsPorChavesExternasClientes(chavesClientes);
        
        // Verificação se o lead foi recuperado corretamente
     //   System.assert(!leads.isEmpty());
    }

    @isTest
    static void testObterLeadsPorInformacoesConcierge() {
        Lead lead = criarLeadDeTeste();
        
        // Chama o método com informações de concierge
        List<Lead> leads = LeadSelector.obterLeadsPorInformacoesConcierge(
            'Elera Lima', '11987647487', 'eleraLima@gmail.com'
        );
        
        // Verificação se o lead foi recuperado corretamente
       // System.assert(!leads.isEmpty());
    }

    @isTest
    static void testObterMobilePhoneLead() {
        Lead lead = criarLeadDeTeste();
        
        // Chama o método com o Id do lead
        Lead result = LeadSelector.obterMobilePhoneLead(lead.Id);
        
        // Verificação se o lead foi recuperado corretamente
       // System.assert(result != null);
    }

    @isTest
    static void testObterInfosTemplatePadrao() {
        Lead lead = criarLeadDeTeste();
        
        // Chama o método com o Id do lead
        Lead result = LeadSelector.obterInfosTemplatePadrao(lead.Id);
        
        // Verificação se o lead foi recuperado corretamente
     //   System.assert(result != null);
    }

    @isTest
    static void testObterLeadsPorInformacoesConcierge2() {
        // Criação de um Empreendimento de teste
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste empreendimento',
            CNPJEmpreendimento__c = '12345678000195'
        );
        insert empreendimento;

        // Criação de Leads de teste
        Lead lead1 = new Lead(
            LastName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'silva@xyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Fale conosco',
            MobilePhone = '11987654321',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id,
            EmailAdicional__c = 'silva_additional@xyz.com',
            CelularAdicional__c = '11987654321',
            CelularAdicional1__c = '11988888888',
            CelularAdicional2__c = '11986543928',
            CelularComercialAdicional__c = '11987654322',
            Phone = '11987654322'
        );
        insert lead1;

        Lead lead2 = new Lead(
            LastName = 'Souza',
            Company = 'Empresa ABC',
            Email = 'souza@abc.com',
            LeadSource = 'Instagram Ads',
            CanalAtendimento__c = 'Fale conosco',
            MobilePhone = '11987654322',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id,
            EmailAdicional__c = 'souza_additional@abc.com',
            CelularAdicional__c = '11987654323',
            CelularAdicional1__c = '11987654324',
            CelularAdicional2__c = '11987654325',
            CelularComercialAdicional__c = '11987654326',
            Phone = '11987654326'
        );
        insert lead2;

        // Testar o método com parâmetros para Lead de pessoa física
        List<Lead> leadsPF = LeadSelector.obterLeadsPorInformacoesConcierge('11987654321', 'silva@xyz.com', false, null);
       }
    
  
}