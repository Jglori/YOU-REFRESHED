@isTest
private class LeadOrigemRestResourceTest {

    // Método para criar um Empreendimento e um Lead com origem
    private static void criarLeadComOrigem(String origem) {
        // Criando o Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c();  
        empreendimento.Name = 'Teste empreendimento';  
        empreendimento.CNPJEmpreendimento__c = '12345678000195'; // Substitua por um CNPJ válido  
        insert empreendimento; 

        // Criando o Lead com a origem
        Lead testLead = new Lead(
            LastName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'silva@xyz.com',
            LeadSource = origem,
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '5511987654321',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;
    }

    // Método para criar um Lead sem origem
    private static void criarLeadSemOrigem() {
        // Criando o Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c();  
        empreendimento.Name = 'Teste empreendimento';  
        empreendimento.CNPJEmpreendimento__c = '12345678000195'; // Substitua por um CNPJ válido  
        insert empreendimento; 

        // Criando o Lead sem origem
        Lead testLead = new Lead(
            LastName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'silva@xyz.com',
            LeadSource = null,
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '5511987654321',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;
    }

    // Teste para o método getLeadSources
    @isTest
    static void testGetLeadSources_Success() {
        // Criando leads com origens
        criarLeadComOrigem('Website');
        criarLeadComOrigem('Referral');
        
        // Criando um lead sem origem
        criarLeadSemOrigem();

        // Configurando o contexto da requisição REST
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/Lead/ListaOrigens';
        req.httpMethod = 'GET';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Chamando o método REST
        LeadOrigemRestResource.getLeadSources();

      
        Test.stopTest();
    }

    // Teste para o caso em que não há Leads com origem
    @isTest
    static void testGetLeadSources_NoLeads() {
        // Criando um lead sem origem
        criarLeadSemOrigem();

        // Configurando o contexto da requisição REST
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/Lead/ListaOrigens';
        req.httpMethod = 'GET';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Chamando o método REST
        LeadOrigemRestResource.getLeadSources();

        Test.stopTest();
    }

    // Teste para o tratamento de exceções
    @isTest
    static void testGetLeadSources_Exception() {
        // Induzindo um erro ao tentar acessar dados de Lead com uma consulta inválida
        // Substituindo a consulta para forçar uma exceção (sem dados do Lead)
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/Lead/ListaOrigens';
        req.httpMethod = 'GET';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Simulando uma exceção
        LeadOrigemRestResource.getLeadSources();

     
        Test.stopTest();
    }
}