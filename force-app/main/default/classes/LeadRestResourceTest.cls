@isTest
public class LeadRestResourceTest {


    @isTest
    static void doPostTest() {
        // Configurar dados de teste
        Campaign testCampaign = new Campaign(Name = 'Test Campaign');
        insert testCampaign;
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento', CNPJEmpreendimento__c ='07135796000139');
        insert empreendimento;
        
                Equipe__c equipe1 = new Equipe__c(Name = 'Equipe 1', CargaMaxima__c = 100);
        Equipe__c equipe2 = new Equipe__c(Name = 'Equipe 2', CargaMaxima__c = 100);
        insert new List<Equipe__c>{equipe1, equipe2};

        // Criar Membros da Equipe
        MembroEquipe__c membro1 = new MembroEquipe__c(Name = 'Jéssica BM', Equipe__c = equipe1.Id);
        MembroEquipe__c membro2 = new MembroEquipe__c(Name = 'Corretor 1', Equipe__c = equipe2.Id);
        MembroEquipe__c membro3 = new MembroEquipe__c(Name = 'Teste Corretor', Equipe__c = equipe1.Id);
        insert new List<MembroEquipe__c>{membro1, membro2, membro3};

        // Criar a RoletaLeads associada à Equipe
        RoletaLeads__c roletaLeads = new RoletaLeads__c(
            Name = 'Roleta Online',
            Ativa__c = true,
            HoraInicio__c = Datetime.now().time(),
            CanaisAtendimento__c = 'Whatsapp',
            Equipe__c = equipe1.Id,
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );
        insert roletaLeads;


        // Criação do Lead associado ao empreendimento
        ConfiguracoesDeNegocio__c conf =   new ConfiguracoesDeNegocio__c(name = 'teste', TempoDeSLA__c = 10);
        insert conf;
        Lead lead = new Lead(
            LastName = 'Paulo',
            Company = 'Elera',
            Email =     'joao.silva@example.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11987654321',
            Status = 'Novo',
            cpf__c = '50154031003',
            cnpj__c = '28724715000106',
            // ConfiguracaoDeSLA__c =conf,
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert lead;

        List<Map<String, Object>> leads = new List<Map<String, Object>>();
        
        // Adicionar um lead de exemplo - Pessoa Física
        leads.add(new Map<String, Object>{
            'tipoPessoa' => 'Física',
            'nome' => 'João Silva',
            'email' => 'joao.silva@example.com',
            'origem' => 'Whatsapp',
            'canal' => 'Chat',
            'celular' => '11987654321',
            'informacoesAdicionaisLead' => 'Lead test',
            'idEmpreendimentoInteresse' => empreendimento.id, // Substitua pelo ID do empreendimento se necessário
            'SubProduto' => 'Eleva Harmonia Studios',
            'campaignName' => 'Test Campaign' // Certifique-se de que essa campanha existe
        });

        // Adicionar um lead de exemplo - Pessoa Jurídica
        leads.add(new Map<String, Object>{
            'tipoPessoa' => 'Jurídica',
            'razaoSocial' => 'Empresa XYZ',
            'nomeRepresentante' => 'Maria Oliveira',
            'email' => 'maria.oliveira@example.com',
            'origem' => 'Indicação',
            'canal' => 'Telefone',
            'celular' => '11987654322',
            'informacoesAdicionaisLead' => 'Lead test empresa',
            'idEmpreendimentoInteresse' => null, // Substitua pelo ID do empreendimento se necessário
            'SubProduto' => 'Eleva Harmonia Studios',
            'campaignName' => 'Test Campaign' // Certifique-se de que essa campanha existe
        });

        // Serializar os leads para JSON
        String jsonBody = JSON.serialize(leads);

        // Criar a requisição de teste
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Lead/';
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        RestContext.request = req;

        // Criar a resposta de teste
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Executar o método a ser testado
        Test.startTest();
        LeadRestResource.doPost();
        Test.stopTest();

        // Verificar a resposta
        // System.assertEquals(201, res.statusCode, 'Deveria ter retornado o status code 201');
        // System.assertEquals('Leads criados com sucesso.', res.responseBody.toString(), 'A mensagem de sucesso deveria ser retornada.');
    }


    @isTest
    static void testDoPost() {
        // Configurar dados de teste
        List<Map<String, Object>> leads = new List<Map<String, Object>>();
        Campaign testCampaign = new Campaign(Name = 'Test Campaign');
        insert testCampaign;
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento', CNPJEmpreendimento__c ='07135796000139');
        insert empreendimento;

        // Adicionar um lead de exemplo - Pessoa Física
        leads.add(new Map<String, Object>{
            'tipoPessoa' => 'Física',
            'nome' => 'João Silva',
            'email' => 'joao.silva@example.com',
            'origem' => 'Outdoor',
            'canal' => 'Chat',
            'celular' => '11987654321',
            'informacoesAdicionaisLead' => 'Lead test',
            'idEmpreendimentoInteresse' => null, // Substitua pelo ID do empreendimento se necessário
            'SubProduto' => 'Eleva Harmonia Studios',
            'campaignName' => 'Test Campaign' // Certifique-se de que essa campanha existe
        });

        // Adicionar um lead de exemplo - Pessoa Jurídica
        leads.add(new Map<String, Object>{
            'tipoPessoa' => 'Jurídica',
            'razaoSocial' => 'Empresa XYZ',
            'nomeRepresentante' => 'Maria Oliveira',
            'email' => 'maria.oliveira@example.com',
            'origem' => 'Indicação',
            'canal' => 'Telefone',
            'celular' => '11987654322',
            'informacoesAdicionaisLead' => 'Lead test empresa',
            'idEmpreendimentoInteresse' => null, // Substitua pelo ID do empreendimento se necessário
            'SubProduto' => 'Eleva Harmonia Studios',
            'campaignName' => 'Test Campaign' // Certifique-se de que essa campanha existe
        });

        // Serializar os leads para JSON
        String jsonBody = JSON.serialize(leads);

        // Criar a requisição de teste
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Lead/';
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        RestContext.request = req;

        // Criar a resposta de teste
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Executar o método a ser testado
        Test.startTest();
        LeadRestResource.doPost();
        Test.stopTest();

        // Verificar a resposta
        // System.assertEquals(201, res.statusCode, 'Deveria ter retornado o status code 201');
        // System.assertEquals('Leads criados com sucesso.', res.responseBody.toString(), 'A mensagem de sucesso deveria ser retornada.');
    }

    @isTest
    static void testDoPostWithErrors() {
        // Criar uma requisição com dados inválidos
        List<Map<String, Object>> leads = new List<Map<String, Object>>();
        Campaign testCampaign = new Campaign(Name = 'Test Campaign');
        insert testCampaign;
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento', CNPJEmpreendimento__c ='07135796000139');
        insert empreendimento;

        // Adicionar um lead de exemplo - Pessoa Física sem email
        leads.add(new Map<String, Object>{
            'tipoPessoa' => 'Física',
            'nome' => 'Carlos Silva',
            'email' => null, // Email em branco
            'origem' => 'Outdoor',
            'canal' => 'Chat',
            'celular' => '11987654323',
            'informacoesAdicionaisLead' => 'Lead test',
            'idEmpreendimentoInteresse' => null,
            'SubProduto' => 'Eleva Harmonia Studios',
            'campaignNam' => 'Test Campaign'
        });

        // Serializar os leads para JSON
        String jsonBody = JSON.serialize(leads);

        // Criar a requisição de teste
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Lead/';
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        RestContext.request = req;

        // Criar a resposta de teste
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Executar o método a ser testado
        Test.startTest();
        LeadRestResource.doPost();
        Test.stopTest();

        // Verificar a resposta
        // System.assertEquals(400, res.statusCode, 'Deveria ter retornado o status code 400');
        // System.assert(res.responseBody.toString().contains('Campos obrigatórios estão faltando'), 'A mensagem de erro deveria conter informações sobre campos obrigatórios faltando.');
    }
    
     @isTest
    public static void testGetCamposLead() {
        // Simular uma requisição GET
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/Lead/campos';
        RestContext.response = new RestResponse();

        Test.startTest();

        // Chama o método getCamposLead da sua classe REST
        LeadRestResource.getCamposLead();

        Test.stopTest();

        // Verificar se a resposta foi como esperado
        System.assertEquals(200, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Pessoa Física'));
    }
    
    
     @isTest
    static void doPostTestWithRoleta() {
        // Configurar dados de teste
        Campaign testCampaign = new Campaign(Name = 'Test Campaign');
        insert testCampaign;

        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Teste empreendimento', CNPJEmpreendimento__c ='07135796000139');
        insert empreendimento;

        // Criar a RoletaLeads associada à Equipe
        Equipe__c equipe1 = new Equipe__c(Name = 'Equipe 1', CargaMaxima__c = 100);
        insert equipe1;
        
        RoletaLeads__c roletaLeads = new RoletaLeads__c(
            Name = 'Roleta Online',
            Ativa__c = true,
            HoraInicio__c = Datetime.now().time(),
            CanaisAtendimento__c = 'Whatsapp',
            Equipe__c = equipe1.Id,
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );
        insert roletaLeads;

        // Criar o Lead com origem "Whatsapp" para garantir que ele será associado à roleta
        Lead lead = new Lead(
            LastName = 'Paulo',
            Company = 'Elera',
            Email = 'joao.silva@example.com',
            LeadSource = 'Whatsapp',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11987654321',
            Status = 'Novo',
            cpf__c = '50154031003',
            cnpj__c = '28724715000106',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert lead;

        // Criar lista de leads a serem processados
        List<Lead> leads = [SELECT Id, LeadSource FROM Lead WHERE Id = :lead.Id];

        // Executar a lógica da classe Queueable
        Test.startTest();
        System.enqueueJob(new LeadQueueable(leads));
        Test.stopTest();

        // Verificar se o lead foi atualizado com a roleta associada
        Lead updatedLead = [SELECT RoletaLeads__c FROM Lead WHERE Id = :lead.Id];
        System.assertEquals(roletaLeads.Id, updatedLead.RoletaLeads__c, 'O lead deveria estar associado à roleta');
    }
}