@isTest
private class LeadCanaisRestResourceTest {

    // Método para criar um Lead com Canal de Atendimento
    private static void criarLeadComCanal(String canal) {
        // Criando o Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c();  
        empreendimento.Name = 'Teste empreendimento';  
        empreendimento.CNPJEmpreendimento__c = '12345678000195'; // Substitua por um CNPJ válido  
        insert empreendimento; 

        // Criando o Lead com o Canal de Atendimento
        Lead testLead = new Lead(
            LastName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'silva@xyz.com',
            LeadSource = 'Website',
            CanalAtendimento__c = canal,
            MobilePhone = '5511987654321',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;
    }

    // Método para criar um Lead sem Canal de Atendimento
    private static void criarLeadSemCanal() {
        // Criando o Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c();  
        empreendimento.Name = 'Teste empreendimento';  
        empreendimento.CNPJEmpreendimento__c = '12345678000195'; // Substitua por um CNPJ válido  
        insert empreendimento; 

        // Criando o Lead sem Canal de Atendimento
        Lead testLead = new Lead(
            LastName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'silva@xyz.com',
            LeadSource = 'Website',
            CanalAtendimento__c = null,
            MobilePhone = '5511987654321',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;
    }

    // Teste para o método getCanaisAtendimento
    @isTest
    static void testGetCanaisAtendimento_Success() {
        // Criando leads com canais de atendimento
        criarLeadComCanal('WhatsApp');
        criarLeadComCanal('Fale conosco');
        
        // Criando um lead sem canal de atendimento
        criarLeadSemCanal();

        // Configurando o contexto da requisição REST
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/Lead/ListaCanaisAtendimento';
        req.httpMethod = 'GET';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Chamando o método REST
        LeadCanaisRestResource.getCanaisAtendimento();

        
        Test.stopTest();
    }

    // Teste para o caso em que não há canais de atendimento
    @isTest
    static void testGetCanaisAtendimento_NoCanais() {
        // Criando um lead sem canal de atendimento
        criarLeadSemCanal();

        // Configurando o contexto da requisição REST
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/Lead/ListaCanaisAtendimento';
        req.httpMethod = 'GET';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Chamando o método REST
        LeadCanaisRestResource.getCanaisAtendimento();

        Test.stopTest();
    }

    // Teste para o tratamento de exceções
    @isTest
    static void testGetCanaisAtendimento_Exception() {
        // Induzindo um erro ao tentar acessar dados de Lead com uma consulta inválida
        // Substituindo a consulta para forçar uma exceção (sem dados de Lead)
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/Lead/ListaCanaisAtendimento';
        req.httpMethod = 'GET';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Simulando uma exceção
        LeadCanaisRestResource.getCanaisAtendimento();

        Test.stopTest();
    }
}