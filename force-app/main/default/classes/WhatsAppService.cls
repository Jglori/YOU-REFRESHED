public without sharing class WhatsAppService {
    private static final ConfiguracaoWhatsApp__mdt CONFIGURACAO_WHATSAPP = ConfiguracaoWhatsApp__mdt.getInstance('ConfiguracaoWhatsApp');
    private static final Id ID_LEAD_TIPO_PF = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('PessoaFisica').getRecordTypeId();
    private static final Id ID_LEAD_TIPO_PJ = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('PessoaJuridica').getRecordTypeId();

    /**
     * Método responsável pelo envio de mídia para o cliente, retornando o 
     * registro de mensagem gerado pelo sistema.
     */
    public static String enviarMidia(Id idLead, String tipoArquivo, String nomeArquivo, String corpoArquivo) {
        Lead lead = LeadDomain.obterLeadPorId(idLead);

        Mensagem__c mensagem = cadastrarMensagem(lead, new Map<String, Object>(), new Map<String, Object>());
        ContentVersion arquivo = cadastrarMidia(mensagem, nomeArquivo, corpoArquivo);

        mensagem = atualizarMensagem(lead, mensagem, arquivo, tipoArquivo);
        enviarMidiaPorURL(idLead, mensagem.id);

        return JSON.serialize(new MensagemDTO(mensagem));
    }

    /**
     * Método responsável pelo envio de mídia a partir do Sales para o cliente WhatsApp, utilizando
     * o número de telefone do Lead, o ContentDistribution e ContentVersion.
     */
    @Future(callout = true)
    public static void enviarMidiaPorURL(Id idLead, Id idMensagem) {
        ContentDocumentLink link = ContentDocumentLinkDomain.obterLinkPorIdRegistroRelacionado(idMensagem);
        ContentDistribution distribuicao = ContentDistributionDomain.obterDistribuicaoPorIdArquivo(link.ContentDocument.LatestPublishedVersionId);
        Lead lead = LeadDomain.obterLeadPorId(idLead);

        String jsonBody = JSON.serialize(new Map<String, Object>{
            'messaging_product'=>'whatsapp',
            'recipient_type'=>'individual',
            'to'=> lead.MobilePhone,
            'type'=>'document',
            'document' => new Map<String, Object>{
               'link' => distribuicao.ContentDownloadUrl,
               'filename' => distribuicao.Name
            }
        });

        WhatsAppCallout.enviarMidia(jsonBody);
    }

    public static String enviarTemplatePadrao(Id idLead, String nomeTemplate) {
        Lead leadInfo = LeadSelector.obterInfosTemplatePadrao(idLead);
        System.debug('leadInfo recuperado: ' + leadInfo);
        Organization orgName = OrganizationSelector.obterNomeOrganizacao();
        System.debug('orgName recuperado: ' + orgName);
        Empreendimento__c nomeEmpreendimento = EmpreendimentoSelector.obterNomeEmpreendimentoById(leadInfo.EmpreendimentoInteresse__c);
        System.debug('nomeEmpreendimento recuperado: ' + nomeEmpreendimento);

        String jsonBody = '';
        
        if(nomeTemplate == 'contatolead'){
            // Body com template personalizado
            jsonBody = JSON.serialize(new Map<String, Object>{
                'messaging_product' => 'whatsapp',
                'to' => leadInfo.MobilePhone,
                'type' => 'template',
                'template' => new Map<String, Object>{
                    'namespace' => '087f05ea_b70d_4a51_9c3d_e1330d6ea2d2', // Namespace deve ser parametrizado!!!
                    'name' => nomeTemplate,
                    'language' => new Map<String, Object>{
                        'code' => 'pt_BR'
                    },
                    'components' => new List<Object>{
                        new Map<String, Object>{
                            'type' => 'body',
                            'parameters' => new List<Object>{
                                new Map<String, Object>{
                                    'type' => 'text',
                                    'text' => leadInfo.FirstName
                                },
                                new Map<String, Object>{
                                    'type' => 'text',
                                    'text' => leadInfo.Owner.Name
                                },
                                new Map<String, Object>{
                                    'type' => 'text',
                                    'text' => orgName.Name
                                },
                                new Map<String, Object>{
                                    'type' => 'text',
                                    'text' => nomeEmpreendimento.Name
                                }
                            }
                        }
                    }
                },
                'category' => 'MARKETING'
            });
        } else if(nomeTemplate == 'hello_world'){
            // Body com "hello_world" template
            jsonBody = JSON.serialize(new Map<String, Object>{
                'messaging_product' => 'whatsapp',
                'to' => leadInfo.MobilePhone,
                'type' => 'template',
                'template' => new Map<String, Object>{
                    'name' => 'hello_world',
                    'language' => new Map<String, Object>{
                        'code' => 'en_US'
                    }
                }
            });
        }
        System.debug('jsonBody: ' + jsonBody);
        
        HttpResponse response = WhatsAppCallout.enviarTemplatePadrao(jsonBody); 
        System.debug(response.getBody());

        if(nomeTemplate == 'contatolead'){
            Mensagem__c mensagem = new Mensagem__c();
            mensagem.De__c = CONFIGURACAO_WHATSAPP.NumeroWhatsAppBusiness__c;
            mensagem.ChaveExternaCliente__c = leadInfo.ChaveExternaWhatsApp__c;
            mensagem.Conteudo__c = 
                'Olá ' + leadInfo.FirstName +
                ', tudo bem? Meu nome é ' + leadInfo.Owner.Name +
                ' da ' + nomeEmpreendimento.Name +
                '. Entrei em contato porque vi que você se interessou por ' + nomeEmpreendimento.Name +
                '. Gostaria de saber mais sobre suas necessidades e como podemos te ajudar.';
            mensagem.CorpoRequisicao__c = jsonBody;
            mensagem.DataHora__c = System.now();
            mensagem.CodigoStatus__c = 201;
            mensagem.Status__c = 'Created';
            mensagem.Tipo__c = 'text';
            try {
                System.debug('Mensagem a ser criada:' + mensagem);
                insert mensagem;
            } catch (Exception e) {
                System.debug('Erro ao criar mensagem: ' + e.getMessage());
            }
        } else if(nomeTemplate == 'hello_world'){
            Mensagem__c mensagem = new Mensagem__c();
            mensagem.De__c = CONFIGURACAO_WHATSAPP.NumeroWhatsAppBusiness__c;
            mensagem.ChaveExternaCliente__c = leadInfo.ChaveExternaWhatsApp__c;
            mensagem.Conteudo__c = 'Olá, gostaria de te apresentar outro projeto interessante!';
            mensagem.CorpoRequisicao__c = jsonBody;
            mensagem.DataHora__c = System.now();
            mensagem.CodigoStatus__c = 201;
            mensagem.Status__c = 'Created';
            mensagem.Tipo__c = 'text';
            try {
                System.debug('Mensagem a ser criada:' + mensagem);
                insert mensagem;
            } catch (Exception e) {
                System.debug('Erro ao criar mensagem: ' + e.getMessage());
            }
        }

        return jsonBody;
    }

    private static Mensagem__c atualizarMensagem(Lead lead, Mensagem__c mensagem, ContentVersion arquivo, String tipoArquivo) {
        ContentDistribution distribuicaoArquivo = ContentDistributionDomain.obterDistribuicaoPorIdArquivo(arquivo.Id);

        Map<String, Object> requestBody = obterRequestBodyParaMidia(lead, distribuicaoArquivo, tipoArquivo);
        Map<String, Object> value = obterNotificationValue(lead, requestBody, new Map<String, Object>());

        Mensagem__c mensagemAtualizada = obterMensagem(lead, requestBody, value);

        mensagemAtualizada.Id = mensagem.Id;
        mensagemAtualizada.TipoMidia__c = tipoArquivo;
        mensagemAtualizada.NomeArquivo__c = distribuicaoArquivo.ContentVersion.Title;
        mensagemAtualizada.URLMidia__c = distribuicaoArquivo.ContentVersion.VersionDataUrl;

        Database.update(mensagemAtualizada);

        return mensagemAtualizada;
    }

    private static Map<String, Object> obterRequestBodyParaMidia(Lead lead, ContentDistribution distribuicaoArquivo, String tipoArquivo) {
        Map<String, Object> requestBody = new Map<String, Object>{
            'messaging_product' => 'whatsapp',
            'recipient_type' => 'individual',
            'to' => lead.MobilePhone
        };

        requestBody.putAll(obterRequestBodyParaMidiaPorTipo(distribuicaoArquivo, tipoArquivo));

        return requestBody;
    }

    private static Map<String, Object> obterRequestBodyParaMidiaPorTipo(ContentDistribution distribuicaoArquivo, String tipoArquivo) {
        switch on tipoArquivo {
            when 'image/jpeg', 
            'image/png', 
            'image/gif', 
            'image/bmp', 
            'image/webp', 
            'image/tiff', 
            'image/svg+xml' {
           return new Map<String, Object>{
                'type' => 'image',
                'image' => new Map<String, Object>{
                    'link' => distribuicaoArquivo != null ? distribuicaoArquivo.ContentDownloadUrl : ''
                }
            };}
            when 'audio/mpeg',
            'audio/ogg',
            'audio/wav',
            'audio/webm',
            'audio/aac',
            'audio/flac',
            'audio/midi',
            'audio/x-ms-wma',
            'audio/x-ms-wax',
            'audio/x-aiff',
            'audio/x-pn-realaudio'{ 
                return new Map<String, Object>{
                    'type' => 'audio',
                    'audio' => new Map<String, Object>{
                        'link' => distribuicaoArquivo != null ? distribuicaoArquivo.ContentDownloadUrl : ''
                    }
                };
            }
            when else {
                return new Map<String, Object>{
                    'type' => 'document',
                    'document' => new Map<String, Object>{
                        'link' => distribuicaoArquivo != null ? distribuicaoArquivo.ContentDownloadUrl : ''
                    }
                };
            }
        }
    }

    private static ContentVersion cadastrarMidia(Mensagem__c mensagem, String nomeArquivo, String corpoArquivo) {
        ContentVersion arquivo = obterMidia(mensagem, nomeArquivo, corpoArquivo);

        Database.insert(arquivo);

        return arquivo;
    }

    // private static ContentVersion obterMidia(Mensagem__c mensagem, String nomeArquivo, String corpoArquivo) {
    //     System.debug('Mensagem: ' + corpoArquivo);
    //     return new ContentVersion(
    //         Title = nomeArquivo,
    //         PathOnClient =  nomeArquivo,
    //         VersionData = Blob.valueOf(corpoArquivo),
    //         IsMajorVersion = true,
    //         FirstPublishLocationId = mensagem.Id
    //     );
    // }

    
    private static ContentVersion obterMidia(Mensagem__c mensagem, String nomeArquivo, String corpoArquivo) {
        Blob dataBlob;
        
        try {
            dataBlob = EncodingUtil.base64Decode(corpoArquivo);
        } catch (Exception e) {
            System.debug('Erro ao decodificar base64: ' + e.getMessage());
            return null; 
        }
    
        ContentVersion contentVersion = new ContentVersion(
            Title = nomeArquivo,
            PathOnClient = nomeArquivo,
            VersionData = dataBlob,
            IsMajorVersion = true,
            FirstPublishLocationId = mensagem.Id
        );
    
        return contentVersion;
    }

    /**
     * Método responsável pelo envio de mensagem para o cliente, retornando
     * o registro de mensagem gerado pelo sistema.
     */
    public static String enviarMensagem(Id idLead, String mensagemTexto) {
        System.debug('Id do Lead enviado: ' + idLead);
        System.debug('Mensagem de texto enviada: ' + mensagemTexto);
        Lead lead = LeadDomain.obterLeadPorId(idLead);

        Map<String, Object> requestBody = obterRequestBodyParaMensagemTexto(lead, mensagemTexto);
        Map<String, Object> responseBody = enviarMensagem(JSON.serialize(requestBody));

        System.debug('resquestBody: ' + requestBody);
        System.debug('responseBody: ' + responseBody);
        
        atualizarRequestBody(requestBody, responseBody);

        System.debug('resquestBody atualizado: ' + requestBody);

        Mensagem__c mensagem = cadastrarMensagem(lead, requestBody, responseBody);

        System.debug('Mensagem cadastrada: ' + mensagem);

        return JSON.serialize(new MensagemDTO(mensagem));
    }

    /**
     * Método responsável pelo cadastro de mensagem após comunicação com o
     * cliente.
     */
    private static Mensagem__c cadastrarMensagem(Lead lead, Map<String, Object> requestBody, Map<String, Object> responseBody) {
        Map<String, Object> value = obterNotificationValue(lead, requestBody, responseBody);
        Mensagem__c mensagem = obterMensagem(lead, requestBody, value);

        Database.insert(mensagem, Mensagem__c.ChaveExterna__c);

        return mensagem;
    }

    private static Mensagem__c obterMensagem(Lead lead, Map<String, Object> message, Map<String, Object> value) {
        Mensagem__c mensagem = obterMensagem(message, value);

        mensagem.ChaveExternaCliente__c = lead.ChaveExternaWhatsApp__c;
        mensagem.De__c = CONFIGURACAO_WHATSAPP.NumeroWhatsAppBusiness__c;

        return mensagem;
    }

    /**
     * Método responsável pela montagem do objeto 'value' para geração de 
     * registro de mensagem.
     */
    private static Map<String, Object> obterNotificationValue(Lead lead, Map<String, Object> requestBody, Map<String, Object> responseBody) {
        return new Map<String, Object>{
            'messaging_product' => 'whatsapp',
            'metadata' => new Map<String, Object>{
                'display_phone_number' => lead.MobilePhone,
                'phone_number_id' => lead.ChaveExternaWhatsApp__c
            },
            'contacts' => responseBody.containsKey('contacts') ? responseBody.get('contacts') : '[]',
            'messages' => new List<Object>{ 
                requestBody 
            }
        };
    }

    /**
     * Método responsável pela atualização do corpo da requisição com retorno
     * da integração em envio de mensagem ao cliente, preenchendo o 'id' da
     * mensagem.
     */
    private static void atualizarRequestBody(Map<String, Object> requestBody, Map<String, Object> responseBody) {
        List<Object> messages = (List<Object>) responseBody.get('messages');
        Map<String, Object> message = (Map<String, Object>) messages.get(0);

        requestBody.putAll(message);
    }

    private static Map<String, Object> enviarMensagem(String body) {
        HttpResponse response = WhatsAppCallout.enviarMensagem(body);
        
        // Tratar erros em integração.

        return (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    }

    /**
     * Método responsável pela montagem do corpo da requisição para envio de
     * mensagem de texto ao cliente.
     */
    private static Map<String, Object> obterRequestBodyParaMensagemTexto(Lead lead, String mensagem) {
        return new Map<String, Object>{
            'messaging_product' => 'whatsapp',
            'recipient_type' => 'individual',
            'to' => lead.MobilePhone,
            'type' => 'text',
            'text' => new Map<String, Object>{
                'preview_url' => false,
                'body' => mensagem
            }
        };
    }

    /**
     * Método responsável por controlar início e fim de um diálogo entre 
     * corretor e cliente.
     */
    public static String controlarDialogo(Id idLead) {
        Lead lead = LeadDomain.obterLeadPorId(idLead);

        if(lead.Id == null) { return JSON.serialize(new LeadDTO(lead)); }

        if(lead.FimDialogo__c != null) { iniciarDialogo(lead); }
        else { finalizarDialogo(lead); }

        return JSON.serialize(new LeadDTO(lead));
    }

    private static void iniciarDialogo(Lead lead) {
        lead.InicioDialogo__c = System.now();
        lead.FimDialogo__c = null;

        update lead;
    }

    private static void finalizarDialogo(Lead lead) {
        lead.FimDialogo__c = System.now();

        update lead;
    }

    /**
     * Método responsável pela obtenção das mensagens relacionadas à chave
     * externa do cliente.
     */
    public static String obterMensagensPorChaveExternaCliente(String chaveExternaCliente) {
        List<MensagemDTO> mensagensDTO = new List<MensagemDTO>();
        for(Mensagem__c mensagem : MensagemSelector.obterMensagensPorChavesExternasClientes(new Set<String>{ chaveExternaCliente })) {
            mensagensDTO.add(new MensagemDTO(mensagem));
        }

        return JSON.serialize(mensagensDTO);
    }

    public static String obterLeadPorId(Id idLead) {
        Lead lead = LeadDomain.obterLeadPorId(idLead);

        return JSON.serialize(new LeadDTO(lead));
    }

    /**
     * Método responsável pela recepção de nova mensagem do WhatsApp e registro
     * em lead relacionado.
     */
    public static void cadastrarMensagens(RestRequest request, RestResponse response) {
        if (!assinaturaValida(RestContext.request)) { 
            erro(response, null);
            return;
        }

        System.debug('Requisição recebida: ' + RestContext.request.requestBody.toString());
        System.debug('Antes do try da minha cadastrarMensagens');
        try {
            Map<String, Object> requestBody = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());

            String telefone = (String) requestBody.get('MobilePhone');
            List<Lead> leads = [SELECT Id, MobilePhone FROM Lead WHERE ChaveExternaWhatsApp__c = :telefone LIMIT 1];
            List<Empreendimento__c> empreendimentoList = [SELECT Id FROM Empreendimento__c WHERE Name = 'Other' LIMIT 1];
            List<Lead> existingLeads = [SELECT Id FROM Lead WHERE MobilePhone = :telefone LIMIT 1];
            System.debug('Leads existentes: ' + existingLeads);
            // System.debug('Empreendimentos: ' + empreendimentoList);
            System.debug('Leads: ' + leads);

            Id empreendimentoInterresseId = null;
            if (!empreendimentoList.isEmpty()) {
                empreendimentoInterresseId = empreendimentoList[0].Id;
            }
            
            if (leads.isEmpty() || existingLeads.isEmpty()) {    
                Lead novoLead = new Lead(
                    RecordTypeId = ID_LEAD_TIPO_PF,
                    FirstName = telefone,
                    LastName = telefone,
                    MobilePhone = telefone,
                    CanalAtendimento__c = 'WhatsApp',
                    LeadSource = 'WhatsApp',
                    ChaveExternaWhatsApp__c = telefone,
                    EmpreendimentoInteresse__c = empreendimentoInterresseId
                );
                
                System.debug('Novo Lead: ' + novoLead);
                insert novoLead;
                leads.add(novoLead);
            }
            
            if (leads.isEmpty()) {
                Lead existingLead = existingLeads[0];
                existingLead.ChaveExternaWhatsApp__c = telefone;
                update existingLead;

                System.debug('Lead existente: ' + existingLead);
                leads.add(existingLead);
            }

            List<Mensagem__c> mensagens = cadastrarMensagens(requestBody);
            
            Set<Id> idsMensagens = SObjectDomain.obterIds(mensagens);

            cadastrarLeads(idsMensagens);
            cadastrarMidias(idsMensagens);
            sucesso(response);
        } catch (Exception erro) {
            erro(response, erro.getMessage());
        }
    }

    private static void sucesso(RestResponse response) {
        response.statusCode = 200;
        response.responseBody = Blob.valueOf('{ success: true, event: "success" }');
    }

    private static void erro(RestResponse response, String mensagem) {
        response.statusCode = 401;
        response.responseBody = Blob.valueOf('{ success: false, event: "Unknown", message: "' + mensagem + '" }');
    }

    @Future(callout = true)
    private static void cadastrarMidias(Set<Id> idsMensagens) {
        List<Mensagem__c> mensagens = MensagemSelector.obterMensagensPorIds(idsMensagens);
        List<ContentVersion> midias = obterMidias(mensagens);

        if(midias.isEmpty()) { return; }

        Database.insert(midias);

        atualizarMensagens(mensagens, SObjectDomain.obterIds(midias));
    }

    /**
     * Método responsável pela atualização das mensagens com URL gerada por
     * documento relacionado.
     */
    @TestVisible 
    private static void atualizarMensagens(List<Mensagem__c> mensagens, Set<Id> idsMidias) {
        Map<Id, Mensagem__c> mensagensPorId = new Map<Id, Mensagem__c>(mensagens);
        Map<Id, ContentVersion> midiasPorIdMensagem = ContentVersionDomain.obterArquivosPorIdRelacionado(idsMidias);
        for(Id idMensagem : mensagensPorId.keySet()) {
            ContentVersion midia = midiasPorIdMensagem.get(idMensagem);
            Mensagem__c mensagem = mensagensPorId.get(idMensagem);

            mensagem.URLMidia__c = midia.VersionDataUrl;
        }

        Database.update(mensagensPorId.values());

        List<EventoWhatsApp__e> eventosWPP = new List<EventoWhatsApp__e>();
        for(Mensagem__c mensagem : mensagens) {
            EventoWhatsApp__e eventoWPP = new EventoWhatsApp__e();
            eventoWPP.MessageId__c = mensagem.ChaveExternaCliente__c;
            eventosWPP.add(eventoWPP);
        }
        
        if(!eventosWPP.isEmpty()) {
            EventBus.publish(eventosWPP);
        }
    }

    /**
     * Método responsável pela geração de mídias por mensagens caso haja mídia
     * relacionada.
     */
    @TestVisible 
    private static List<ContentVersion> obterMidias(List<Mensagem__c> mensagens) {
        List<ContentVersion> midias = new List<ContentVersion>();
        for(Mensagem__c mensagem : mensagens) {
            if(String.isBlank(mensagem.ChaveExternaMidia__c)) { continue; }

            midias.add(obterMidia(mensagem));
        }

        return midias;
    }

    private static ContentVersion obterMidia(Mensagem__c mensagem) {
        Map<String, Object> responseBody = obterURLMidia(mensagem.ChaveExternaMidia__c);
        Blob responseBodyAsBlob = obterMidia((String) responseBody.get('url'));

        return new ContentVersion(
            Title = mensagem.NomeArquivo__c ?? mensagem.ChaveExternaMidia__c,
            PathOnClient =  mensagem.NomeArquivo__c + '.' + mensagem.TipoMidia__c.split('/')[1],
            VersionData = responseBodyAsBlob,
            IsMajorVersion = true,
            FirstPublishLocationId = mensagem.Id
        );
    }

    /**
     * Método responsável pela obtenção de mídia enviada pela WhatsApp a partir 
     * da URL gerada para a mídia.
     */
    @TestVisible
    private static Blob obterMidia(String urlMidia) {
        HttpResponse response = WhatsAppCallout.obterMidia(urlMidia);
        
        // Tratar erros em integração.

        return response.getBodyAsBlob();
    }

    /**
     * Método responsável pela obtenção de URL para mídia enviada pela WhatsApp
     * a partir do Id da mídia.
     */
    private static Map<String, Object> obterURLMidia(String idMidia) {
        HttpResponse response = WhatsAppCallout.obterURLMidia(idMidia);

        // Tratar erros em integração.

        return (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    }

    @TestVisible 
    @Future
    private static void cadastrarLeads(Set<Id> idsMensagens){
        List<Mensagem__c> mensagens = MensagemSelector.obterMensagensPorIds(idsMensagens);

        Set<String> chavesClientes = new Set<String>();
        for(Mensagem__c mensagem : mensagens){
            chavesClientes.add(mensagem.ChaveExternaCliente__c);
        }

        List<Lead> leads = LeadSelector.obterLeadsPorChavesExternasClientes(chavesClientes);

        Map<String, Lead> leadsPorChaveWhatsApp = new Map<String, Lead>();
        for (Lead lead : leads) {
            leadsPorChaveWhatsApp.put(lead.ChaveExternaWhatsApp__c, lead);
        }

        List<Lead> leadsParaCriar = new List<Lead>();
        for(Mensagem__c mensagem : mensagens){
            System.debug('Lead a ser criado coma mensagem: ' + mensagem);
            if(leadsPorChaveWhatsApp.containsKey(mensagem.ChaveExternaCliente__c)){
                continue;
            }

            leadsParaCriar.add(new Lead(
                RecordTypeId = ID_LEAD_TIPO_PF,
                LastName = mensagem.ChaveExternaCliente__c,
                CanalAtendimento__c = 'WhatsApp',
                LeadSource = 'WhatsApp',
                MobilePhone = mensagem.ChaveExternaCliente__c,
                ChaveExternaWhatsApp__c = mensagem.ChaveExternaCliente__c
            ));
        }

        System.debug('Info dos Lead para criar: ' + leadsParaCriar);
        if(!leadsParaCriar.isEmpty()){
            Database.insert(leadsParaCriar);
            System.debug('LEAD CRIADO COM SUCESSO!!!');
        }
    }

    /**
     * Método responsável pela geração de registros de mensagem a partir do
     * corpo da requisição recebido via webhook.
     */
    private static List<Mensagem__c> cadastrarMensagens(Map<String, Object> requestBody) {
        List<Mensagem__c> mensagens = obterMensagens(requestBody);

        if(mensagens.isEmpty()) { return mensagens; }

        Database.upsert(mensagens, Mensagem__c.ChaveExterna__c, false);

        List<EventoWhatsApp__e> eventosWPP = new List<EventoWhatsApp__e>();
        for(Mensagem__c mensagem : mensagens) {
            EventoWhatsApp__e eventoWPP = new EventoWhatsApp__e();
            eventoWPP.MessageId__c = mensagem.ChaveExternaCliente__c;
            eventosWPP.add(eventoWPP);
        }
        
        if(!eventosWPP.isEmpty()) {
            EventBus.publish(eventosWPP);
        }
        return mensagens;
    }

    @TestVisible 
    private static List<Mensagem__c> obterMensagens(Map<String, Object> requestBody) {
        List<Mensagem__c> mensagens = new List<Mensagem__c>();
        for(Object entryObject : (List<Object>) requestBody.get('entry')) {
            Map<String, Object> entry = (Map<String, Object>) entryObject;

            if(!entry.containsKey('changes')) { continue; }

            mensagens.addAll(obterMensagensPorEntry(entry));
        }

        return mensagens;
    }

    @TestVisible 
    private static List<Mensagem__c> obterMensagensPorEntry(Map<String, Object> entry) {
        List<Mensagem__c> mensagens = new List<Mensagem__c>();
        for(Object changeObject : (List<Object>) entry.get('changes')) {
            Map<String, Object> change = (Map<String, Object>) changeObject;

            if(!change.containsKey('value')) { continue; }

            Map<String, Object> value = (Map<String, Object>) change.get('value');

            if(!value.containsKey('messages')) { continue; }

            mensagens.addAll(obterMensagensPorValue(value));
        }

        return mensagens;
    }

    @TestVisible 
    private static List<Mensagem__c> obterMensagensPorValue(Map<String, Object> value) {
        List<Mensagem__c> mensagens = new List<Mensagem__c>();
        for(Object messageObject : (List<Object>) value.get('messages')) {
            Map<String, Object> message = (Map<String, Object>) messageObject;

            mensagens.add(obterMensagem(message, value));
        }

        return mensagens;
    }

    private static Mensagem__c obterMensagem(Map<String, Object> message, Map<String, Object> value) {
        Mensagem__c mensagem = new Mensagem__c();

        mensagem.Status__c = 'Created';
        mensagem.CodigoStatus__c = 201;
        mensagem.CorpoRequisicao__c = JSON.serialize(value);
        mensagem.DataHora__c = message.containsKey('timestamp') ? Datetime.newInstance(Long.valueOf((String) message.get('timestamp') + '000')) : System.now();
        mensagem.ChaveExterna__c = message.containsKey('id') ? (String) message.get('id') : null;
        mensagem.ChaveExternaCliente__c = message.containsKey('from') ? (String) message.get('from') : null;
        mensagem.De__c = message.containsKey('from') ? (String) message.get('from') : null;
        mensagem.Tipo__c = message.containsKey('type') ? (String) message.get('type') : null;
        mensagem.Conteudo__c = obterConteudoPorTipo(mensagem.Tipo__c, message);
        mensagem.TipoMidia__c = obterTipoMidiaPorTipo(mensagem.Tipo__c, message);
        mensagem.Certificado__c = obterCertificadoPorTipo(mensagem.Tipo__c, message);
        mensagem.ChaveExternaMidia__c = obterChaveExternaMidiaPorTipo(mensagem.Tipo__c, message);
        mensagem.NomeArquivo__c = obterNomeArquivoPorTipo(mensagem.Tipo__c, message);

        return mensagem;
    }

    /**
     * Método responsável pela obtenção do nome do arquivo (filename) de acordo com o
     * tipo de mensagem recebida.
     */
    private static String obterNomeArquivoPorTipo(String tipo, Map<String, Object> message) {
        switch on tipo {
            when 'document' {
                return message.containsKey('document') ? (String) ((Map<String, Object>) message.get('document')).get('filename') : null;
            }
            when 'video' {
                return message.containsKey('video') ? (String) ((Map<String, Object>) message.get('video')).get('filename') : null;
            }
            when else {
                return null;
            }
        }
    }

    /**
     * Método responsável pela obtenção da chave externa do arquivo (id) de acordo 
     * com o tipo de mensagem recebida.
     */
    private static String obterChaveExternaMidiaPorTipo(String tipo, Map<String, Object> message) {
        switch on tipo {
            when 'audio' {
                return message.containsKey('audio') ? (String) ((Map<String, Object>) message.get('audio')).get('id') : null;
            }
            when 'document' {
                return message.containsKey('document') ? (String) ((Map<String, Object>) message.get('document')).get('id') : null;
            }
            when 'image' {
                return message.containsKey('image') ? (String) ((Map<String, Object>) message.get('image')).get('id') : null;
            }
            when 'sticker' {
                return message.containsKey('sticker') ? (String) ((Map<String, Object>) message.get('sticker')).get('id') : null;
            }
            when 'video' {
                return message.containsKey('video') ? (String) ((Map<String, Object>) message.get('video')).get('id') : null;
            }
            when else {
                return null;
            }
        }
    }

    /**
     * Método responsável pela obtenção do certificado do arquivo (sha256) de acordo 
     * com o tipo de mensagem recebida.
     */
    private static String obterCertificadoPorTipo(String tipo, Map<String, Object> message) {
        switch on tipo {
            when 'document' {
                return message.containsKey('document') ? (String) ((Map<String, Object>) message.get('document')).get('sha256') : null;
            }
            when 'image' {
                return message.containsKey('image') ? (String) ((Map<String, Object>) message.get('image')).get('sha256') : null;
            }
            when 'video' {
                return message.containsKey('video') ? (String) ((Map<String, Object>) message.get('video')).get('sha256') : null;
            }
            when 'sticker' {
                return message.containsKey('sticker') ? (String) ((Map<String, Object>) message.get('sticker')).get('sha256') : null;
            }
            when else {
                return null;
            }
        }
    }

    /**
     * Método responsável pela obtenção do tipo de mídia do arquivo (mime_type) de acordo 
     * com o tipo de mensagem recebida.
     */
    private static String obterTipoMidiaPorTipo(String tipo, Map<String, Object> message) {
        switch on tipo {
            when 'document' {
                return message.containsKey('document') ? (String) ((Map<String, Object>) message.get('document')).get('mime_type') : null;
            }
            when 'image' {
                return message.containsKey('image') ? (String) ((Map<String, Object>) message.get('image')).get('mime_type') : null;
            }
            when 'video' {
                return message.containsKey('video') ? (String) ((Map<String, Object>) message.get('video')).get('mime_type') : null;
            }
            when 'sticker' {
                return message.containsKey('sticker') ? (String) ((Map<String, Object>) message.get('sticker')).get('mime_type') : null;
            }
            when 'audio' {
                return message.containsKey('audio') ? (String) ((Map<String, Object>) message.get('audio')).get('mime_type') : null;
            }
            when else {
                return null;
            }
        }
    }

    /**
     * Método responsável pela obtenção do conteúdo textual relacionado ao arquivo (body
     * , caption) de acordo com o tipo de mensagem recebida.
     */
    private static String obterConteudoPorTipo(String tipo, Map<String, Object> message) {
        switch on tipo {
            when 'text' {
                return message.containsKey('text') ? (String) ((Map<String, Object>) message.get('text')).get('body') : null;
            }
            when 'document' {
                return message.containsKey('document') ? (String) ((Map<String, Object>) message.get('document')).get('caption') : null;
            }
            when 'image' {
                return message.containsKey('image') ? (String) ((Map<String, Object>) message.get('image')).get('caption') : null;
            }
            when 'video' {
                return message.containsKey('video') ? (String) ((Map<String, Object>) message.get('video')).get('caption') : null;
            }
            when else {
                return null;
            }
        }
    }

    /**
     * Método responsável pela comparação da assinatura enviada em requisição
     * com assinatura gerada a partir da encriptação do corpo da requisição,
     * para garantir integridade dos dados recebidos.
     */
    public static Boolean assinaturaValida(RestRequest request) {
        String assinaturaGerada = obterAssinatura(request);
        String assinaturaRecebida = request.headers.get('X-Hub-Signature-256');

        return assinaturaGerada == assinaturaRecebida;
    }

    /**
     * Método responsável pela geração de assinatura a partir da encriptação
     * do corpo da requisição, por método hmacSHA256, a partir do segredo do
     * aplicativo definido na Meta.
     */
    private static String obterAssinatura(RestRequest request) {
        Blob cargaCriptografada = Crypto.generateMac(
            'hmacSHA256', 
            Blob.valueOf(request.requestBody.toString()), 
            Blob.valueOf(CONFIGURACAO_WHATSAPP.SegredoAplicativo__c)
        );

        return 'sha256=' + EncodingUtil.convertToHex(cargaCriptografada);
    }

    /**
     * Método responsável pela validação de legitimidade do webhook a partir de
     * verificação de token e challenge.
     */
    public static void validarWebhook(RestRequest request, RestResponse response) {
        if(request.params.get('hub.verify_token') != CONFIGURACAO_WHATSAPP.TokenVerificacao__c) { return; }

        response.responseBody = Blob.valueOf(request.params.get('hub.challenge'));
    }
}