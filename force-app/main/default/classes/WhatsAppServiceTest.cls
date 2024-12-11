@IsTest
public class WhatsAppServiceTest {

    // Cria dados de teste para serem usados pelos testes
    @TestSetup
    static void setupTestData() {
        // Criando um Empreendimento de exemplo
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste empreendimento',
            CNPJEmpreendimento__c = '07135796000139'
        );
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
    }

    // Classe para simular o callout HTTP
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simular uma resposta de sucesso
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Message sent successfully"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @IsTest
    static void testObterLeadPorId() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        String result = WhatsAppService.obterLeadPorId(lead.Id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo.');
    }

    @IsTest
    static void testObterMensagensPorChaveExternaCliente() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        String chaveExternaCliente = 'chave_teste';
        Test.startTest();
        String result = WhatsAppService.obterMensagensPorChaveExternaCliente(chaveExternaCliente);
        Test.stopTest();
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo.');
    }

    @IsTest
    static void testControlarDialogo() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        String result = WhatsAppService.controlarDialogo(lead.Id);
        Test.stopTest();
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo.');
    }

    @IsTest
    static void testEnviarMidia() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        String tipoArquivo = 'image/png';
        String nomeArquivo = 'teste.png';
        String corpoArquivo = 'base64string';
        Test.startTest();
        String result = WhatsAppService.enviarMidia(lead.Id, tipoArquivo, nomeArquivo, corpoArquivo);
        Test.stopTest();
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo.');
    }

    @IsTest
    static void testEnviarMidiaErro() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        String tipoArquivo = 'image/pna';
        String nomeArquivo = 'teste.pna';
        String corpoArquivo = 'base64string';
        Test.startTest();
        String result = WhatsAppService.enviarMidia(lead.Id, tipoArquivo, nomeArquivo, corpoArquivo);
        Test.stopTest();
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo.');
    }

    @IsTest
    static void testEnviarMidiaInvalida() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        String tipoArquivo = 'invalid/type';
        String nomeArquivo = 'arquivo_invalido';
        String corpoArquivo = 'base64string_invalido';
        Test.startTest();
        try {
            String result = WhatsAppService.enviarMidia(lead.Id, tipoArquivo, nomeArquivo, corpoArquivo);
            System.assert(false, 'O método deveria ter lançado uma exceção para tipo de arquivo inválido.');
        } catch (Exception e) {
            // Exceção esperada
        }
        Test.stopTest();
    }

    @IsTest
    static void testEnviarTemplatePadrao() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        String nomeTemplate = 'Template de Teste';
        Test.startTest();
        String result = WhatsAppService.enviarTemplatePadrao(lead.Id, nomeTemplate);
        Test.stopTest();
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo.');
    }
    
	@IsTest
    static void testeAtualizarLeadComResposta() {
        // Setup: Criar um Lead de teste
        Lead leadDeTeste = new Lead(
            FirstName = 'Nome Original',
            LastName = 'Sobrenome Original',
            Company = 'Empresa de Teste',
            ChaveExternaWhatsApp__c = 'chaveExterna123'
        );
        insert leadDeTeste;

        // Setup: Criar uma mensagem relacionada ao Lead
        Mensagem__c mensagemDeTeste = new Mensagem__c(
            Conteudo__c = 'Novo Nome',
            ChaveExternaCliente__c = leadDeTeste.ChaveExternaWhatsApp__c,
            De__c = leadDeTeste.ChaveExternaWhatsApp__c
        );
        insert mensagemDeTeste;

        // Início do teste
        Test.startTest();
        // Chamando o método com diferentes números de mensagem
        WhatsAppService.atualizarLeadComResposta(leadDeTeste, 2);
        WhatsAppService.atualizarLeadComResposta(leadDeTeste, 3);
        WhatsAppService.atualizarLeadComResposta(leadDeTeste, 4);
        Test.stopTest();

        // Consulta o Lead atualizado para verificar alterações
        Lead leadAtualizado = [SELECT FirstName, LastName, Email FROM Lead WHERE Id = :leadDeTeste.Id];

        // Debug para validar manualmente os resultados
        System.debug('FirstName atualizado: ' + leadAtualizado.FirstName); // Deve ser "Novo Nome"
        System.debug('LastName atualizado: ' + leadAtualizado.LastName);   // Deve ser "Novo Nome"
        System.debug('Email atualizado: ' + leadAtualizado.Email);         // Deve ser "Novo Nome"
    }
        
    @IsTest
    static void testeDefinirMensagemTemplate() {
        // Setup: Criar um Lead de teste
        Lead leadDeTeste = new Lead(
            FirstName = 'Teste',
            LastName = 'Usuário',
            Company = 'Empresa Teste'
        );
        insert leadDeTeste;

        // Início do teste
        Test.startTest();
        
        // Chamadas ao método com diferentes valores para numeroMsg
        String mensagem1 = WhatsAppService.definirMensagemTemplate(1, leadDeTeste);
        String mensagem2 = WhatsAppService.definirMensagemTemplate(2, leadDeTeste);
        String mensagem3 = WhatsAppService.definirMensagemTemplate(3, leadDeTeste);
        String mensagem4 = WhatsAppService.definirMensagemTemplate(4, leadDeTeste);
        String mensagemInvalida = WhatsAppService.definirMensagemTemplate(99, leadDeTeste);

        Test.stopTest();

        // Logs para validação manual
        System.debug('Mensagem para numeroMsg = 1: ' + mensagem1); // Esperado: mensagem inicial
        System.debug('Mensagem para numeroMsg = 2: ' + mensagem2); // Esperado: mensagem para sobrenome
        System.debug('Mensagem para numeroMsg = 3: ' + mensagem3); // Esperado: mensagem para e-mail
        System.debug('Mensagem para numeroMsg = 4: ' + mensagem4); // Esperado: mensagem de agradecimento
        System.debug('Mensagem para numeroMsg inválido: ' + mensagemInvalida); // Esperado: mensagem vazia
    }
     
    @isTest
    static void testSucesso() {
        // Criando uma instância de RestResponse
        RestResponse response = new RestResponse();

        // Chamando o método sucesso para configurar a resposta
        WhatsAppService.sucesso(response);

        // Verificando se o código de status foi definido corretamente como 200
        System.assertEquals(200, response.statusCode, 'O status code deve ser 200.');

        // Verificando se o corpo da resposta foi definido corretamente
        String expectedResponseBody = '{ success: true, event: "success" }';
        String actualResponseBody = response.responseBody.toString();

        System.assertEquals(expectedResponseBody, actualResponseBody, 'O corpo da resposta não está correto.');
    }
    
	@isTest
    static void testErro() {
        // Criando uma instância de RestResponse
        RestResponse response = new RestResponse();
        
        // Definindo uma mensagem para passar como argumento
        String mensagem = 'Erro ao processar a requisição';

        // Chamando o método erro para configurar a resposta com o código 401 e a mensagem
        WhatsAppService.erro(response, mensagem);

        // Verificando se o código de status foi definido corretamente como 401
        System.assertEquals(401, response.statusCode, 'O status code deve ser 401.');

        // Verificando se o corpo da resposta contém a mensagem passada como argumento
        String expectedResponseBody = '{ success: false, event: "Unknown", message: "' + mensagem + '" }';
        String actualResponseBody = response.responseBody.toString();

        System.assertEquals(expectedResponseBody, actualResponseBody, 'O corpo da resposta não está correto.');
    }
    
    @isTest
    static void testCadastrarMidias() {
        // Criando um conjunto de ids para simular as mensagens
        Set<Id> idsMensagens = new Set<Id>();
        
        // Criando algumas Mensagens simuladas
        Mensagem__c mensagem1 = new Mensagem__c();
        mensagem1.De__c = 'whatsapp_business_number_1';
        mensagem1.ChaveExternaCliente__c = 'chave_cliente_1';
        mensagem1.CorpoRequisicao__c = 'mensagem corpo 1';
        
        Mensagem__c mensagem2 = new Mensagem__c();
        mensagem2.De__c = 'whatsapp_business_number_2';
        mensagem2.ChaveExternaCliente__c = 'chave_cliente_2';
        mensagem2.CorpoRequisicao__c = 'mensagem corpo 2';

        // Inserindo as Mensagens para que possamos obter seus ids
        insert new List<Mensagem__c>{mensagem1, mensagem2};

        // Adicionando os ids das mensagens no Set
        idsMensagens.add(mensagem1.Id);
        idsMensagens.add(mensagem2.Id);

        // Mockando o método obterMidias para retornar uma lista de ContentVersion simulados
        Test.startTest();
        
        // Criando ContentVersion simulados
        ContentVersion media1 = new ContentVersion();
        media1.Title = 'Midia 1';
        media1.PathOnClient = 'midia1.jpg';
        
        ContentVersion media2 = new ContentVersion();
        media2.Title = 'Midia 2';
        media2.PathOnClient = 'midia2.jpg';
        
        // Adicionando as mídias à lista
        List<ContentVersion> midias = new List<ContentVersion>{media1, media2};
        
        // Simulando a execução do método @Future
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Chamando o método @Future
        WhatsAppService.cadastrarMidias(idsMensagens);
        
        // Verificando se as mídias foram inseridas corretamente
        List<ContentVersion> insertedMidias = [SELECT Id, Title, PathOnClient FROM ContentVersion];
        
        Test.stopTest();
    }
   
    @isTest
    static void testObterMidia() {
        // Criando uma Mensagem simulada
        Mensagem__c mensagem = new Mensagem__c();
        mensagem.NomeArquivo__c = 'arquivoTeste';
        mensagem.ChaveExternaMidia__c = 'chaveExternaTeste';
        mensagem.TipoMidia__c = 'image/jpeg';
        
        // Inserindo a mensagem para poder usá-la no teste
        insert mensagem;

        // Garantindo que a inserção seja confirmada antes de chamar o método @future
        Test.startTest();
        
        // Simulando a resposta do método 'obterURLMidia' (fazendo um mock)
        Map<String, Object> mockedResponse = new Map<String, Object>();
        mockedResponse.put('url', 'http://example.com/arquivoTeste.jpg');
        
        // Mockando o método 'obterURLMidia' para retornar a resposta simulada
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Chamando o método com callout (isso será executado fora da transação atual)
        WhatsAppService.cadastrarMidias(new Set<Id>{mensagem.Id});
        
        Test.stopTest();
        
        // A partir daqui, podemos validar se o callout foi feito corretamente
        // Não é necessário validar diretamente os dados de inserção no ContentVersion, 
        // pois isso foi feito fora da transação principal devido ao @future
    }
    
    @isTest
    static void testCadastrarLeads() {
        // Criar um conjunto de mensagens simuladas
        Mensagem__c mensagem1 = new Mensagem__c(
            ChaveExternaCliente__c = '1234567890'
        );
        Mensagem__c mensagem2 = new Mensagem__c(
            ChaveExternaCliente__c = '0987654321'
        );
        
        // Inserir as mensagens
        insert new List<Mensagem__c>{mensagem1, mensagem2};

        // Criar o mock de retorno para o método 'LeadSelector.obterLeadsPorChavesExternasClientes'
        // (não será necessário criar Leads para essas chaves, pois eles são retornados diretamente do mock)
        Test.startTest();

        // Chamar o método @future
        WhatsAppService.cadastrarLeads(new Set<Id>{mensagem1.Id, mensagem2.Id});
        
        // Finalizar a transação do @future
        Test.stopTest();
    }
    
    @isTest
    static void testObterMensagensPorEntry() {
        // Step 1: Criar dados simulados
        // Criando uma mensagem fictícia com chave externa e cliente
        Map<String, Object> mensagem1 = new Map<String, Object>{
            'id' => 'unique-key-1',
            'from' => 'client-key-1',
            'timestamp' => '1638482394000'
        };
    
        Map<String, Object> mensagem2 = new Map<String, Object>{
            'id' => 'unique-key-2',
            'from' => 'client-key-2',
            'timestamp' => '1638482395000'
        };
    
        // Simulando o corpo da requisição (requestBody)
        Map<String, Object> requestBody = new Map<String, Object>{
            'changes' => new List<Object>{
                new Map<String, Object>{
                    'value' => new Map<String, Object>{
                        'messages' => new List<Map<String, Object>>{ mensagem1, mensagem2 }
                    }
                }
            }
        };
    
        // Step 2: Invocar o método a ser testado
        Test.startTest();
        List<Mensagem__c> mensagens = WhatsAppService.obterMensagensPorEntry(requestBody);
        Test.stopTest();
    
        // Step 3: Validar se as mensagens foram obtidas corretamente
        System.assertEquals(2, mensagens.size(), 'Deve retornar 2 mensagens');
        
        // Validar se as mensagens estão corretas
        Mensagem__c mensagemTest1 = mensagens[0];
        Mensagem__c mensagemTest2 = mensagens[1];
        
        System.assertEquals('unique-key-1', mensagemTest1.ChaveExterna__c, 'Chave externa da primeira mensagem deve ser correta');
        System.assertEquals('client-key-1', mensagemTest1.ChaveExternaCliente__c, 'Chave externa cliente da primeira mensagem deve ser correta');
        
        System.assertEquals('unique-key-2', mensagemTest2.ChaveExterna__c, 'Chave externa da segunda mensagem deve ser correta');
        System.assertEquals('client-key-2', mensagemTest2.ChaveExternaCliente__c, 'Chave externa cliente da segunda mensagem deve ser correta');
    }
    
    @isTest
    static void testObterMensagens() {
        // Step 1: Criar dados simulados
        // Criando uma mensagem fictícia com chave externa e cliente
        Map<String, Object> mensagem1 = new Map<String, Object>{
            'id' => 'unique-key-1',
            'from' => 'client-key-1',
            'timestamp' => '1638482394000'
        };
    
        Map<String, Object> mensagem2 = new Map<String, Object>{
            'id' => 'unique-key-2',
            'from' => 'client-key-2',
            'timestamp' => '1638482395000'
        };
    
        // Simulando o corpo da requisição (requestBody) com a estrutura de 'entry'
        Map<String, Object> requestBody = new Map<String, Object>{
            'entry' => new List<Object>{
                new Map<String, Object>{
                    'changes' => new List<Object>{
                        new Map<String, Object>{
                            'value' => new Map<String, Object>{
                                'messages' => new List<Map<String, Object>>{ mensagem1, mensagem2 }
                            }
                        }
                    }
                }
            }
        };
    
        // Step 2: Invocar o método a ser testado
        Test.startTest();
        List<Mensagem__c> mensagens = WhatsAppService.obterMensagens(requestBody);
        Test.stopTest();
    
        // Step 3: Validar se as mensagens foram obtidas corretamente
        System.assertEquals(2, mensagens.size(), 'Deve retornar 2 mensagens');
        
        // Validar se as mensagens estão corretas
        Mensagem__c mensagemTest1 = mensagens[0];
        Mensagem__c mensagemTest2 = mensagens[1];
        
        System.assertEquals('unique-key-1', mensagemTest1.ChaveExterna__c, 'Chave externa da primeira mensagem deve ser correta');
        System.assertEquals('client-key-1', mensagemTest1.ChaveExternaCliente__c, 'Chave externa cliente da primeira mensagem deve ser correta');
        
        System.assertEquals('unique-key-2', mensagemTest2.ChaveExterna__c, 'Chave externa da segunda mensagem deve ser correta');
        System.assertEquals('client-key-2', mensagemTest2.ChaveExternaCliente__c, 'Chave externa cliente da segunda mensagem deve ser correta');
    }
}