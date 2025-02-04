@isTest
public class LeadRestResourceTest {
    @isTest
    static void doPostTest() {
        // Criar dados de teste
        Campaign testCampaign = new Campaign(Name = 'Test Campaign');
        insert testCampaign;
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento', CNPJEmpreendimento__c ='07135796000139');
        insert empreendimento;

        Equipe__c equipe = new Equipe__c(Name = 'Equipe Teste', CargaMaxima__c = 100);
        insert equipe;

        MembroEquipe__c membro = new MembroEquipe__c(Name = 'Teste Corretor', Equipe__c = equipe.Id);
        insert membro;

        RoletaLeads__c roletaLeads = new RoletaLeads__c(
            Name = 'Roleta Online',
            Ativa__c = true,
            HoraInicio__c = Datetime.now().time(),
            CanaisAtendimento__c = 'Whatsapp',
            Equipe__c = equipe.Id,
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );
        insert roletaLeads;

        ConfiguracoesDeNegocio__c conf = new ConfiguracoesDeNegocio__c(Name = 'Config Teste', TempoDeSLA__c = 10);
        insert conf;

        Lead lead = new Lead(
            LastName = 'Paulo',
            Company = 'Elera',
            Email = 'joao.silva@example.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11987654321',
            Status = 'Novo',
            cpf__c = '50154031003',
            cnpj__c = '28724715000106',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert lead;

        List<Map<String, Object>> leads = new List<Map<String, Object>>();
        leads.add(new Map<String, Object>{
            'tipoPessoa' => 'Física',
            'nome' => 'João Silva',
            'email' => 'joao.silva@example.com',
            'origem' => 'Whatsapp',
            'canal' => 'Chat',
            'celular' => '11987654321',
            'informacoesAdicionaisLead' => 'Lead test',
            'idEmpreendimentoInteresse' => empreendimento.id,
            'SubProduto' => 'Eleva Harmonia Studios',
            'campaignName' => 'Test Campaign'
        });

        String jsonBody = JSON.serialize(leads);

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Lead/';
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        LeadRestResource.doPost();
        Test.stopTest();
    }

    @isTest
    static void testDoPostWithErrors() {
        List<Map<String, Object>> leads = new List<Map<String, Object>>();
        leads.add(new Map<String, Object>{
            'tipoPessoa' => 'Física',
            'nome' => 'Carlos Silva',
            'email' => null,
            'origem' => 'Outdoor',
            'canal' => 'Chat',
            'celular' => '11987654323',
            'informacoesAdicionaisLead' => 'Lead test',
            'idEmpreendimentoInteresse' => null,
            'SubProduto' => 'Eleva Harmonia Studios',
            'campaignName' => 'Test Campaign'
        });

        String jsonBody = JSON.serialize(leads);

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Lead/';
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        LeadRestResource.doPost();
        Test.stopTest();
    }

    @isTest
    public static void testGetCamposLead() {
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/Lead/campos';
        RestContext.response = new RestResponse();

        Test.startTest();
        LeadRestResource.getCamposLead();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Pessoa Física'));
    }
    
    @isTest
private static void testLeadCreationLogic() {
    Test.startTest();
    
    // Criando usuários
    User user1 = new User(
        Alias = 'user1',
        Email = 'user1@test.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Test',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = UserInfo.getProfileId(),
        TimeZoneSidKey = 'America/Los_Angeles',
        CompanyName = 'You',
        Username = 'user1_' + System.currentTimeMillis() + '@test.com',
        Situacao__c = 'Online'
    );
    
    User user2 = new User(
        Alias = 'user2',
        Email = 'user2@test.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Test',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = UserInfo.getProfileId(),
        TimeZoneSidKey = 'America/Los_Angeles',
        Username = 'user2_' + System.currentTimeMillis() + '@test.com',
        CompanyName = 'You',
        Situacao__c = 'Offline'
    );
    
    insert new List<User>{user1, user2};
    
    // Criando equipes
    Equipe__c equipe1 = new Equipe__c(Name = 'Equipe 1', CargaMaxima__c = 100);
    Equipe__c equipe2 = new Equipe__c(Name = 'Equipe 2', CargaMaxima__c = 100);
    insert new List<Equipe__c>{equipe1, equipe2};
    
    // Criando membros de equipe
    MembroEquipe__c membro1 = new MembroEquipe__c(Name = 'Jéssica BM', Equipe__c = equipe1.Id, Usuario__c = user1.Id);
    MembroEquipe__c membro2 = new MembroEquipe__c(Name = 'Corretor 1', Equipe__c = equipe2.Id, Usuario__c = user2.Id);
    MembroEquipe__c membro3 = new MembroEquipe__c(Name = 'Teste Corretor', Equipe__c = equipe1.Id, Usuario__c = user1.Id);
    insert new List<MembroEquipe__c>{membro1, membro2, membro3};
    
    // Criando roleta
    RoletaLeads__c roleta = new RoletaLeads__c(
        Name = 'Roleta - Equipe 1',
        Ativa__c = true,
        HoraInicio__c = Datetime.now().time(),
        CanaisAtendimento__c = 'WhatsApp',
        Equipe__c = equipe1.Id,
        DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
    );
    insert roleta;
    
    // Criando parâmetros simulados
    Map<String, Object> params = new Map<String, Object>{
        'dataIteracaoMtn' => '2024-02-03T12:00:00Z',
        'Email' => 'teste@example.com',
        'MobilePhone' => '11999999999'
    };
    
    // Criando listas para verificar duplicidade
    Set<String> existingEmails = new Set<String>{'duplicado@example.com'};
    Set<String> existingMobiles = new Set<String>{'11888888888'};
    Set<String> existingPhones = new Set<String>();
    List<Lead> leadsToInsert = new List<Lead>();
    List<String> errors = new List<String>();
    
    // Criando um novo lead
    Lead newLead = new Lead(
        LastName = 'Teste',
        Company = 'Empresa Teste',
        RoletaLeads__c = roleta.Id,
        Email = (String) params.get('Email'),
        MobilePhone = (String) params.get('MobilePhone')
    );
    
    // Convertendo data
    String dataIteracaoMtn = (String) params.get('dataIteracaoMtn');
    if (dataIteracaoMtn != null) {
        try {
            String formattedDate = dataIteracaoMtn.replace('Z', '').replace('T', ' ');
            newLead.Data_Iteracao_MTN__c = Datetime.valueOf(formattedDate);
        } catch (Exception e) {
            errors.add('Formato de data inválido: ' + dataIteracaoMtn);
        }
    }
    
    // Verificando duplicatas
    Boolean isDuplicate = false;
    if (existingEmails.contains(newLead.Email) || existingMobiles.contains(newLead.MobilePhone)) {
        isDuplicate = true;
    }
    
    System.assertEquals(false, isDuplicate, 'O lead não deveria ser identificado como duplicado.');
    
    // Adicionando à lista de inserção
    if (!isDuplicate) {
        leadsToInsert.add(newLead);
    }
    
    insert leadsToInsert;
    
    System.assertEquals(1, [SELECT COUNT() FROM Lead WHERE Email = 'teste@example.com']);
    
    Test.stopTest();
}


}