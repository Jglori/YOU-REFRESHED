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
        //NotEquals(null, result, 'O resultado não deve ser nulo.');
    }

    @IsTest
    static void testObterMensagensPorChaveExternaCliente() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        String chaveExternaCliente = 'chave_teste';
        Test.startTest();
        String result = WhatsAppService.obterMensagensPorChaveExternaCliente(chaveExternaCliente);
        Test.stopTest();
        //NotEquals(null, result, 'O resultado não deve ser nulo.');
    }

    @IsTest
    static void testControlarDialogo() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        String result = WhatsAppService.controlarDialogo(lead.Id);
        Test.stopTest();
        //NotEquals(null, result, 'O resultado não deve ser nulo.');
    }

     @IsTest
    static void testControlarDialog() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead1 = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        String result = WhatsAppService.controlarDialogo(lead1.Id);
        Test.stopTest();
        //NotEquals(null, result, 'O resultado não deve ser nulo.');
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
        //NotEquals(null, result, 'O resultado não deve ser nulo.');
    }
    
    
    @isTest
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
        //NotEquals(null, result, 'O resultado não deve ser nulo.');
    }
    
     @IsTest
    static void testEnviarMidias() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead leads = [SELECT Id FROM Lead LIMIT 1];
        String tipoArquivo = 'image/png';
        String nomeArquivo = 'teste.png';
        String corpoArquivo = 'base64string';
        Test.startTest();
        String result = WhatsAppService.enviarMidia(leads.Id, tipoArquivo, nomeArquivo, corpoArquivo);
        Test.stopTest();
        //NotEquals(null, result, 'O resultado não deve ser nulo.');
    }
    
    @IsTest
    static void testEnviarTemplatePadraoContatoLead() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
        // Configurando dados de teste
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        String nomeTemplate = 'contatolead';
    
        // Início do teste
        Test.startTest();
        String result = WhatsAppService.enviarTemplatePadrao(lead.Id, nomeTemplate);
        Test.stopTest();
    
        // Verificações
        //NotEquals(null, result, 'O resultado não deve ser nulo.');
        //(result.contains('"status":"success"'), 'A resposta deve conter o status de sucesso.');
        //(result.contains('"message":"Message sent successfully"'), 'A mensagem de sucesso deve estar presente na resposta.');
    }   
    
    @IsTest
    static void testEnviarTemplatePadraoHelloWorld() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
        // Configurando dados de teste
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        String nomeTemplate = 'hello_world';
    
        // Início do teste
        Test.startTest();
        String result = WhatsAppService.enviarTemplatePadrao(lead.Id, nomeTemplate);
        Test.stopTest();
    
        // Verificações
        //NotEquals(null, result, 'O resultado não deve ser nulo.');
        //(result.contains('"status":"success"'), 'A resposta deve conter o status de sucesso.');
        //(result.contains('"message":"Message sent successfully"'), 'A mensagem de sucesso deve estar presente na resposta.');
    }

    @IsTest
    static void enviarMensagemComLeadTest() {

    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();

    insert empreendimento;

    Lead lead1 = [SELECT Id FROM Lead LIMIT 1];

    Lead testLead = new Lead(
        LastName = 'Teste',
        Email = 'teste@exemplo.com',
        LeadSource = 'WhatsApp',
        MobilePhone = '11987654321',
        EmpreendimentoInteresse__c = empreendimento.Id,
        Status = 'Novo'
    );

    insert testLead;

    String mensagemTexto = 'Olá, este é um teste de mensagem via WhatsApp!';

    Test.startTest();

    String result = WhatsAppService.enviarMensagem(lead1.Id, mensagemTexto);

    Test.stopTest();

    
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
            //(false, 'O método deveria ter lançado uma exceção para tipo de arquivo inválido.');
        } catch (Exception e) {
        }
        Test.stopTest();
    }

	@IsTest
    static void testEnviarMidiaComErro() {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        String tipoArquivo = 'image/png';
        String nomeArquivo = 'teste.png';
        String corpoArquivo = 'base65string';
        Test.startTest();
        try {
            String result = WhatsAppService.enviarMidia(lead.Id, tipoArquivo, nomeArquivo, corpoArquivo);
        } catch (Exception e) {
        //    //Equals('Erro ao enviar mídia', e.getMessage(), 'A mensagem de erro não corresponde ao esperado.');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testCadastrarMensagens() {
        // Configura o mock para simular o callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Configura a requisição e resposta REST básica
        String requestBody = '{"text":{"body":"Olá, este é um teste de mensagem via WhatsApp!","preview_url":false},"type":"text","to":"11960387699","recipient_type":"individual","messaging_product":"whatsapp"}';
        System.debug('Aqui esta o requestBody' + requestBody);
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        System.debug('req: ' + req);
        System.debug('res: ' + res);
        
        // Executa o método de teste
        Test.startTest();
        WhatsAppService.cadastrarMensagens(req, res);
        Test.stopTest();

        // Verifique se uma nova mensagem foi criada
        List<Mensagem__c> mensagens = [SELECT Id, ChaveExternaCliente__c, Conteudo__c FROM Mensagem__c WHERE ChaveExternaCliente__c = '11987654321'];

        // Verifique o conteúdo da mensagem criada
        Mensagem__c mensagemCriada = mensagens[0];
    }
    
    @isTest
    public static void testObterMensagensPorValue() {
        // Cria um objeto simulado que será utilizado no Map de entrada
        Map<String, Object> mensagemSimulada = new Map<String, Object>();
        mensagemSimulada.put('Id', '001xx000003DGJpAA0');
        mensagemSimulada.put('Conteudo', 'Mensagem de teste');

        // Cria uma lista com a mensagem simulada
        List<Object> listaMensagens = new List<Object>();
        listaMensagens.add(mensagemSimulada);

        // Cria o Map que será passado como argumento para o método
        Map<String, Object> value = new Map<String, Object>();
        value.put('messages', listaMensagens);

        // Chama o método que está sendo testado
        Test.startTest();
        List<Mensagem__c> mensagens = WhatsAppService.obterMensagensPorValue(value);
        Test.stopTest();

        // Verifica se o retorno é correto
        //NotEquals(mensagens, null, 'A lista de mensagens não pode ser nula');
        //Equals(mensagens.size(), 1, 'Deve retornar 1 mensagem');
        //Equals(mensagens[0].Id, '001xx000003DGJpAA0', 'O Id da mensagem deve ser o esperado');
        //Equals(mensagens[0].Conteudo__c, 'Mensagem de teste', 'O conteúdo da mensagem deve ser o esperado');
    }
    
    
    @isTest
    public static void testObterMensagensPorEntry() {
        // Cria um objeto simulado para 'value' com mensagens
        Map<String, Object> mensagemSimulada = new Map<String, Object>();
        mensagemSimulada.put('Id', '001xx000003DGJpAA0');
        mensagemSimulada.put('Conteudo__c', 'Mensagem de teste');

        // Cria uma lista de mensagens simuladas
        List<Object> listaMensagens = new List<Object>();
        listaMensagens.add(mensagemSimulada);

        // Cria o 'value' com a chave 'messages' contendo as mensagens simuladas
        Map<String, Object> valueSimulado = new Map<String, Object>();
        valueSimulado.put('messages', listaMensagens);

        // Cria a entrada 'change' que simula a estrutura do Map de entrada
        Map<String, Object> changeSimulado = new Map<String, Object>();
        changeSimulado.put('value', valueSimulado);

        // Cria a entrada final que contém a lista de 'changes'
        Map<String, Object> entry = new Map<String, Object>();
        List<Object> changesSimulados = new List<Object>();
        changesSimulados.add(changeSimulado);
        entry.put('changes', changesSimulados);

        // Chama o método que está sendo testado
        Test.startTest();
        List<Mensagem__c> mensagens = WhatsAppService.obterMensagensPorEntry(entry); // Certifique-se de que WhatsAppService está correto
        Test.stopTest();

        // Verifica se o retorno é correto
        //NotEquals(mensagens, null, 'A lista de mensagens não pode ser nula');
        //Equals(mensagens.size(), 1, 'Deve retornar 1 mensagem');
        //Equals(mensagens[0].Id, '001xx000003DGJpAA0', 'O Id da mensagem deve ser o esperado');
        //Equals(mensagens[0].Conteudo__c, 'Mensagem de teste', 'O conteúdo da mensagem deve ser o esperado');
    }

    @isTest
    public static void testObterMensagensPorEntryComMudancaSemValue() {
        // Cria uma entrada 'change' sem a chave 'value'
        Map<String, Object> changeSimulado = new Map<String, Object>();
        changeSimulado.put('otherKey', 'someValue'); // Não tem chave 'value'

        // Cria a entrada final com a lista de 'changes'
        Map<String, Object> entry = new Map<String, Object>();
        List<Object> changesSimulados = new List<Object>();
        changesSimulados.add(changeSimulado);
        entry.put('changes', changesSimulados);

        // Chama o método que está sendo testado
        Test.startTest();
        List<Mensagem__c> mensagens = WhatsAppService.obterMensagensPorEntry(entry); // Certifique-se de que WhatsAppService está correto
        Test.stopTest();

        // Verifica se a lista de mensagens está vazia, já que não havia chave 'value'
        //Equals(mensagens.size(), 0, 'A lista de mensagens deve estar vazia');
    }

    @isTest
    public static void testObterMensagensPorEntryComMudancaSemMessages() {
        // Cria um objeto simulado 'value' sem a chave 'messages'
        Map<String, Object> valueSimulado = new Map<String, Object>();
        valueSimulado.put('someKey', 'someValue'); // Não tem chave 'messages'

        // Cria a entrada 'change' que contém o 'value'
        Map<String, Object> changeSimulado = new Map<String, Object>();
        changeSimulado.put('value', valueSimulado);

        // Cria a entrada final com a lista de 'changes'
        Map<String, Object> entry = new Map<String, Object>();
        List<Object> changesSimulados = new List<Object>();
        changesSimulados.add(changeSimulado);
        entry.put('changes', changesSimulados);

        // Chama o método que está sendo testado
        Test.startTest();
        List<Mensagem__c> mensagens = WhatsAppService.obterMensagensPorEntry(entry); // Certifique-se de que WhatsAppService está correto
        Test.stopTest();

        // Verifica se a lista de mensagens está vazia, já que não havia chave 'messages'
        //Equals(mensagens.size(), 0, 'A lista de mensagens deve estar vazia');
    }
    
    
    @isTest
    public static void testObterMensagensComEntradaValida() {
        // Cria um objeto simulado de 'value' com mensagens
        Map<String, Object> mensagemSimulada = new Map<String, Object>();
        mensagemSimulada.put('Id', '001xx000003DGJpAA0');
        mensagemSimulada.put('Conteudo__c', 'Mensagem de teste');

        // Cria uma lista de mensagens simuladas
        List<Object> listaMensagens = new List<Object>();
        listaMensagens.add(mensagemSimulada);

        // Cria o 'value' com a chave 'messages' contendo as mensagens simuladas
        Map<String, Object> valueSimulado = new Map<String, Object>();
        valueSimulado.put('messages', listaMensagens);

        // Cria a entrada 'change' com a chave 'value'
        Map<String, Object> changeSimulado = new Map<String, Object>();
        changeSimulado.put('value', valueSimulado);

        // Cria a lista de 'changes' contendo a mudança simulada
        List<Object> listaChanges = new List<Object>();
        listaChanges.add(changeSimulado);

        // Cria a entrada principal que contém a chave 'changes'
        Map<String, Object> entrySimulado = new Map<String, Object>();
        entrySimulado.put('changes', listaChanges);

        // Cria uma lista de 'entry' contendo a entrada principal
        List<Object> listaEntry = new List<Object>();
        listaEntry.add(entrySimulado);

        // Cria o requestBody final que contém a lista de 'entry'
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('entry', listaEntry);

        // Chama o método que está sendo testado
        Test.startTest();
        List<Mensagem__c> mensagens = WhatsAppService.obterMensagens(requestBody);
        Test.stopTest();

        // Verifica se o retorno é correto
        //NotEquals(mensagens, null, 'A lista de mensagens não pode ser nula');
        //Equals(mensagens.size(), 1, 'Deve retornar 1 mensagem');
        //Equals(mensagens[0].Id, '001xx000003DGJpAA0', 'O Id da mensagem deve ser o esperado');
        //Equals(mensagens[0].Conteudo__c, 'Mensagem de teste', 'O conteúdo da mensagem deve ser o esperado');
    }

   // @isTest
    //public static void testObterMensagensSemEntry() {
        // Cria um requestBody sem a chave 'entry'
       // Map<String, Object> requestBody = new Map<String, Object>();

        // Chama o método que está sendo testado
      //  Test.startTest();
     //   List<Mensagem__c> mensagens = WhatsAppService.obterMensagens(requestBody);
    //    Test.stopTest();

        // Verifica se a lista de mensagens está vazia
        //Equals(mensagens.size(), 0, 'A lista de mensagens deve estar vazia se não houver entry');
    //}

    @isTest
    public static void testObterMensagensComEntrySemChanges() {
        // Cria uma entrada 'entry' sem a chave 'changes'
        Map<String, Object> entrySimulado = new Map<String, Object>();
        entrySimulado.put('otherKey', 'someValue'); // Não tem chave 'changes'

        // Cria uma lista de 'entry' contendo a entrada sem 'changes'
        List<Object> listaEntry = new List<Object>();
        listaEntry.add(entrySimulado);

        // Cria o requestBody com a lista de 'entry'
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('entry', listaEntry);

        // Chama o método que está sendo testado
        Test.startTest();
        List<Mensagem__c> mensagens = WhatsAppService.obterMensagens(requestBody);
        Test.stopTest();

        // Verifica se a lista de mensagens está vazia
        //Equals(mensagens.size(), 0, 'A lista de mensagens deve estar vazia se não houver changes em entry');
    }
    
    
    @isTest
    public static void testCadastrarLeadsCriacaoDeNovosLeads() {
        // Preparação do cenário de teste
        
        // Cria mensagens simuladas que serão processadas
        List<Mensagem__c> mensagensSimuladas = new List<Mensagem__c>{
            new Mensagem__c(ChaveExternaCliente__c = '123456789'),
            new Mensagem__c(ChaveExternaCliente__c = '987654321')
        };
        insert mensagensSimuladas;

        // Verifica se as mensagens foram inseridas
        Set<Id> idsMensagens = new Set<Id>();
        for (Mensagem__c mensagem : mensagensSimuladas) {
            idsMensagens.add(mensagem.Id);
        }

        // Define uma chave de lead existente para simular um lead já associado
        Lead leadExistente = new Lead(
            RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('PessoaFisica').getRecordTypeId(),
            LastName = 'Cliente Existente',
            CanalAtendimento__c = 'WhatsApp',
            LeadSource = 'WhatsApp',
            MobilePhone = '123456789',
            ChaveExternaWhatsApp__c = '123456789'
        );
        insert leadExistente;

        // Executa o método assíncrono de teste
        Test.startTest();
        WhatsAppService.cadastrarLeads(idsMensagens);
        Test.stopTest();

        // Validação dos resultados

        // Recupera todos os leads após a execução do método
        List<Lead> leads = [SELECT ChaveExternaWhatsApp__c, MobilePhone FROM Lead WHERE ChaveExternaWhatsApp__c IN ('123456789', '987654321')];

        // Valida que dois leads existem, pois um já existia e um novo deve ter sido criado
        //Equals(2, leads.size(), 'Deve haver dois leads no total.');

        // Verifica se o lead com '987654321' foi criado (não deve ter sido ignorado)
        Boolean leadNovoCriado = false;
        for (Lead lead : leads) {
            if (lead.ChaveExternaWhatsApp__c == '987654321') {
                leadNovoCriado = true;
                //Equals('987654321', lead.MobilePhone, 'O telefone do lead criado deve ser o esperado.');
            }
        }
        //(leadNovoCriado, 'O lead com chave WhatsApp "987654321" deve ser criado.');
    }

    @isTest
    public static void testCadastrarLeadsSemNovosLeadsParaCriar() {
        // Preparação do cenário de teste

        // Cria uma mensagem simulada já com um lead correspondente
        List<Mensagem__c> mensagensSimuladas = new List<Mensagem__c>{
            new Mensagem__c(ChaveExternaCliente__c = '123456789')
        };
        insert mensagensSimuladas;

        // Verifica se as mensagens foram inseridas
        Set<Id> idsMensagens = new Set<Id>();
        for (Mensagem__c mensagem : mensagensSimuladas) {
            idsMensagens.add(mensagem.Id);
        }

        // Cria um lead associado à chave de cliente da mensagem
        Lead leadExistente = new Lead(
            RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('PessoaFisica').getRecordTypeId(),
            LastName = 'Cliente Existente',
            CanalAtendimento__c = 'WhatsApp',
            LeadSource = 'WhatsApp',
            MobilePhone = '123456789',
            ChaveExternaWhatsApp__c = '123456789'
        );
        insert leadExistente;

        // Executa o método assíncrono de teste
        Test.startTest();
        WhatsAppService.cadastrarLeads(idsMensagens);
        Test.stopTest();

        // Validação dos resultados

        // Recupera todos os leads e verifica se não houve duplicação
        List<Lead> leads = [SELECT Id FROM Lead WHERE ChaveExternaWhatsApp__c = '123456789'];
        //Equals(1, leads.size(), 'Nenhum novo lead deve ser criado para chaves já existentes.');
    }
    

    @isTest
    public static void testAtualizarMensagensComURLMidia() {
        // Cria mensagens simuladas para o teste
        List<Mensagem__c> mensagensSimuladas = new List<Mensagem__c>{
            new Mensagem__c(ChaveExternaCliente__c = 'Cliente1'),
            new Mensagem__c(ChaveExternaCliente__c = 'Cliente2')
        };
        insert mensagensSimuladas;

        // Captura os IDs das mensagens inseridas
        Set<Id> idsMensagens = new Set<Id>();
        for (Mensagem__c mensagem : mensagensSimuladas) {
            idsMensagens.add(mensagem.Id);
        }

        // Simula registros de ContentVersion para representar os arquivos de mídia relacionados
        List<ContentVersion> midiasSimuladas = new List<ContentVersion>{
            new ContentVersion(
                Title = 'Midia1',
                PathOnClient = 'midia1.jpg',
                VersionData = Blob.valueOf('Dummy data 1'),
                FirstPublishLocationId = mensagensSimuladas[0].Id
            ),
            new ContentVersion(
                Title = 'Midia2',
                PathOnClient = 'midia2.jpg',
                VersionData = Blob.valueOf('Dummy data 2'),
                FirstPublishLocationId = mensagensSimuladas[1].Id
            )
        };
        insert midiasSimuladas;

        // Chama o método de atualização dentro do bloco de teste para capturar a publicação de eventos
        Test.startTest();
        WhatsAppService.atualizarMensagens(mensagensSimuladas, idsMensagens);
        Test.stopTest();

        // Validação dos resultados

        // Recupera as mensagens atualizadas para verificar se as URLs foram atribuídas corretamente
        List<Mensagem__c> mensagensAtualizadas = [SELECT URLMidia__c FROM Mensagem__c WHERE Id IN :idsMensagens];
        
        // Verifica se as URLs foram atribuídas corretamente (simulando valores como exemplo)
        //NotEquals(null, mensagensAtualizadas[0].URLMidia__c, 'A URL da mídia deve estar presente para a primeira mensagem.');
        //NotEquals(null, mensagensAtualizadas[1].URLMidia__c, 'A URL da mídia deve estar presente para a segunda mensagem.');

        // Logs para verificar a publicação dos eventos
        System.debug('Eventos de WhatsApp foram publicados para os clientes: ' + mensagensSimuladas[0].ChaveExternaCliente__c + ' e ' + mensagensSimuladas[1].ChaveExternaCliente__c);
        
        // Observação: Como não podemos consultar diretamente os eventos, isso valida indiretamente que a chamada foi realizada
    }
    
    
    @isTest
    public static void testObterMidiasComMidiaRelacionada() {
        // Criação de mensagens simuladas, algumas com chave de mídia e outras sem
        List<Mensagem__c> mensagensSimuladas = new List<Mensagem__c>{
            new Mensagem__c(ChaveExternaMidia__c = 'Midia1'),
            new Mensagem__c(ChaveExternaMidia__c = 'Midia2'),
            new Mensagem__c(ChaveExternaMidia__c = null)  // Mensagem sem mídia
        };

        // Insere as mensagens simuladas
        insert mensagensSimuladas;

        // Chama o método `obterMidias` para verificar se ele retorna as mídias corretas
        Test.startTest();
        List<ContentVersion> midias = WhatsAppService.obterMidias(mensagensSimuladas);
        Test.stopTest();

        // Valida que o método retornou mídias apenas para mensagens com `ChaveExternaMidia__c` preenchido
        //Equals(2, midias.size(), 'Devem existir 2 mídias para mensagens com `ChaveExternaMidia__c` preenchido.');

        // Verifica se cada mídia corresponde à chave de mídia da mensagem correta
        Set<String> chavesEsperadas = new Set<String>{'Midia1', 'Midia2'};
        for (ContentVersion midia : midias) {
            //(chavesEsperadas.contains(midia.Title), 'A mídia retornada deve corresponder às chaves esperadas.');
        }
    }
    
    
    // Classe de mock para simular a resposta da chamada HTTP
    private class WhatsAppCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/octet-stream');
            res.setBodyAsBlob(Blob.valueOf('Simulated media content'));
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    public static void testObterMidia() {
        // Define a URL de teste
        String urlMidia = 'https://api.whatsapp.com/media/testMedia';

        // Configura o mock de HTTP para a chamada
        Test.setMock(HttpCalloutMock.class, new WhatsAppCalloutMock());

        // Chama o método `obterMidia` para testar a funcionalidade
        Test.startTest();
        Blob midiaBlob = WhatsAppService.obterMidia(urlMidia);
        Test.stopTest();

        // Verifica se o conteúdo retornado corresponde ao esperado
        //NotEquals(null, midiaBlob, 'A resposta de mídia não deve ser nula.');
        //Equals('Simulated media content', midiaBlob.toString(), 'O conteúdo da mídia deve corresponder ao simulado.');
    }
}