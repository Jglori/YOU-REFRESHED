public without sharing class OmnichannelService {
        private static final Map<String, ConfiguracaoCanalAtendimento__mdt> CONFIGURACOES_POR_CANAL = new Map<String, ConfiguracaoCanalAtendimento__mdt>();
    
        /**
         * Método responsável pela seleção de canais de atendimento no usuário para
         * recepção de leads dos respectivos canais.
         */
        public static String selecionarCanais(List<String> canaisAtendimento) {
            Database.update(new User(Id = UserInfo.getUserId(), CanaisAtendimento__c = String.join(canaisAtendimento, ';')));
    
            return obterUsuario();
        }
    
        /**
         * Método responsável pela aceitação do lead atribuído ao corretor, definindo
         * o corretor como proprietário.
         */
        public static String aceitarLead(Id idLead) {
            Database.update(new Lead(Id = idLead, OwnerId = UserInfo.getUserId()));
    
            adicionarLeadAoParticipante(idLead);
    
            return obterLeadsEmNovo();
        }
    
        private static void adicionarLeadAoParticipante(Id idLead) {
            Lead lead = LeadDomain.obterLeadPorId(idLead);
    
            adicionarLeadAoParticipante(lead);
    
            Database.update(lead.Corretor__r);
    
           // setParticipantePosition(lead.Corretor__c, lead.RoletaLeads__c);
        }
    
        private static void setParticipantePosition(Id membro, Id roletaId){
            List<ParticipanteRoleta__c> participantesToUpdte = new List<ParticipanteRoleta__c>();
            List<ParticipanteRoleta__c>  participantes = ParticipanteRoletaSelector.obterParticipantesPorIdsRoleta(new Set<Id>{roletaId});
            Map<Decimal, ParticipanteRoleta__c> mapPosition = new Map<Decimal,ParticipanteRoleta__c>();
    
            for(ParticipanteRoleta__c participante : participantes){
                if(participante.MembroEquipe__c == membro){
                    participante.Posicao__c = 9999999;
                }
                mapPosition.put(participante.Posicao__c, participante);
            }
    
            List<Decimal> sortPositions = new List<Decimal>(mapPosition.keyset());
            for(Integer newPosition = 0; newPosition < sortPositions.size(); newPosition++){
                ParticipanteRoleta__c part = mapPosition.get(sortPositions[newPosition]);
                part.Posicao__c = newPosition + 1;
                participantesToUpdte.add(part);
            }
    
            if(!participantesToUpdte.isEmpty()){
                update participantesToUpdte;
            }
    
        }
    
        private static void adicionarLeadAoParticipante(Lead lead) {
            switch on lead.CanalAtendimento__c {
                when 'Fale conosco' {
                    lead.Corretor__r.QuantidadeLeadsFaleConosco__c = (lead.Corretor__r.QuantidadeLeadsFaleConosco__c <> null ? 0 : lead.Corretor__r.QuantidadeLeadsFaleConosco__c) + 1;
                }
                when 'Chat' {
                    lead.Corretor__r.QuantidadeLeadsChat__c = (lead.Corretor__r.QuantidadeLeadsChat__c <> null ? 0 : lead.Corretor__r.QuantidadeLeadsChat__c) + 1;
                }
                when 'WhatsApp' {
                    lead.Corretor__r.QuantidadeLeadsWhatsApp__c = (lead.Corretor__r.QuantidadeLeadsWhatsApp__c <> null ? 0 : lead.Corretor__r.QuantidadeLeadsWhatsApp__c) + 1;
                }
                when 'Telefone' {
                    lead.Corretor__r.QuantidadeLeadsTelefone__c = (lead.Corretor__r.QuantidadeLeadsTelefone__c <> null ? 0 : lead.Corretor__r.QuantidadeLeadsTelefone__c) + 1;
                }
                when 'Loja' {
                    lead.Corretor__r.QuantidadeLeadsLoja__c = (lead.Corretor__r.QuantidadeLeadsLoja__c <> null ? 0 : lead.Corretor__r.QuantidadeLeadsLoja__c) + 1;
                }
                when 'Stand' {
                    lead.Corretor__r.QuantidadeLeadsStand__c = (lead.Corretor__r.QuantidadeLeadsStand__c <> null ? 0 : lead.Corretor__r.QuantidadeLeadsStand__c) + 1;
                }
                when else {
                    
                }
            }
        }
    
        /**
         * Método responsável pela rejeição do lead atribuído ao corretor, limpando a
         * roleta e corretor escolhidos.
         */
        public static String rejeitarLead(Id idLead) {
            Database.update(new Lead(Id = idLead, RoletaLeads__c = null, Corretor__c = null));
    
            return obterLeadsEmNovo();
        }
    
        /**
         * Método responsável pela alteração da situação do corretor para atualização ou 
         * criação de novos participantes, caso não hajam.
         */
        public static String alterarSituacao(String novaSituacao) {
            Database.update(new User(Id = UserInfo.getUserId(), Situacao__c = novaSituacao));
    
            return obterUsuario();
        }
    
        /**
         * Método responsável pela obtenção de leads atribuídos e aceitos pelo corretor.
         */
        public static String obterLeadsEmTrabalho() {
            List<LeadDTO> leadsDTO = new List<LeadDTO>();
            for(Lead lead : LeadSelector.obterLeadsPorIdsProprietarios(new Set<Id>{ UserInfo.getUserId() })) {
                leadsDTO.add(new LeadDTO(lead));
            }
    
            return JSON.serialize(leadsDTO);
        }
    
        /**
         * Método responsável pela obtenção do usuário para apresentação da situação e
         * canais de atendimento selecionados.
         */
        public static String obterUsuario() {
            User usuario = UserDomain.obterUsuarioPorId(UserInfo.getUserId());
        
            if (String.isBlank(usuario.Situacao__c)) {
                usuario.Situacao__c = 'Offline'; 
                update usuario;
            }
        
            return JSON.serialize(new UserDTO(usuario));
        }
        
        
        /**
         * Método responsável pela obtenção das situações disponíveis para o usuário atual.
         */
        public static Map<String, String> obterSituacoes() {
            Map<String, String> situacoesPorValor = new Map<String, String>();
            for(Schema.PicklistEntry opcaoSituacao : User.Situacao__c.getDescribe().getPicklistValues()) {
                situacoesPorValor.put(opcaoSituacao.getValue(), opcaoSituacao.getLabel());
            }
    
            return situacoesPorValor;
        }
    
        /**
         * Método responsável pela obtenção dos canais de atendimento relacionados às
         * roletas que o corretor é membro.
         */
        public static Map<String, String> obterCanaisAtendimento() {
            List<RoletaLeads__c> roletasLeads = RoletaLeadsSelector.obterRoletasLeadsPorIdsUsuarios(new Set<Id>{ UserInfo.getUserId() });
            Set<String> canaisAtendimento = RoletaLeadsDomain.obterCanaisAtendimento(roletasLeads);
    
            Map<String, String> canaisAtendimentoPorValor = new Map<String, String>();
            for(Schema.PicklistEntry opcaoCanalAtendimento : User.CanaisAtendimento__c.getDescribe().getPicklistValues()) {
                if(!canaisAtendimento.contains(opcaoCanalAtendimento.getValue())) { continue; }
    
                canaisAtendimentoPorValor.put(opcaoCanalAtendimento.getValue(), opcaoCanalAtendimento.getLabel());
            }
    
            return canaisAtendimentoPorValor;
        }
    
            public static String definirStatusInicial() {
                User usuario = [SELECT Id, Situacao__c FROM User WHERE Id = :UserInfo.getUserId()];
                if (usuario.Situacao__c == null) {
                    usuario.Situacao__c = 'Offline';
                    update usuario;
                }
                return JSON.serialize(usuario);
            }
    
    
            public static String obterLeadsEmNovo() {
                CONFIGURACOES_POR_CANAL.putAll(CustomMetadataTypeDomain.obterConfiguracoesPorCanalAntendimento());
                List<LeadDTO> leadsDTO = new List<LeadDTO>();
                for(Lead lead : LeadSelector.obterLeadsPorIdsUsuarios(new Set<Id>{ UserInfo.getUserId() })) {
                    leadsDTO.add(new LeadDTO(lead, CONFIGURACOES_POR_CANAL.get(lead.CanalAtendimento__c)));
                    notificarPeloChatter(lead.Id, UserInfo.getUserId());
                }
                enviarEmailLeadsEmTrabalho(UserInfo.getUserId(), leadsDTO);
                return JSON.serialize(leadsDTO);
            }
        
        public static void enviarEmailLeadsEmTrabalho(Id userId, List<LeadDTO> leads) {
            User recipient = [SELECT Id, Email FROM User WHERE Id = :userId];
            List<String> leadDetails = new List<String>();
            for (LeadDTO lead : leads) {
                leadDetails.add('Lead: ' + User.FirstName + ' ' + User.LastName);
            }
            String subject = 'Detalhes dos Leads em Trabalho';
            String body = 'Olá,\n\nSegue abaixo os detalhes dos leads em trabalho:\n\n';
            body += String.join(leadDetails, '\n');
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ recipient.Email });
            email.setSubject(subject);
            email.setPlainTextBody(body);
           // Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
        }
           
            public static void notificarPeloChatter(Id leadId, Id userId) {
                Lead lead = [SELECT Id, FirstName, LastName FROM Lead WHERE Id = :leadId];
                User user = [SELECT Id, Name FROM User WHERE Id = :userId];
                FeedItem post = new FeedItem();
                post.ParentId = lead.Id;
                post.Body = user.Name + ' aceitou o lead ' + lead.FirstName + ' ' + lead.LastName + '.';
                post.Type = 'LinkPost';
                insert post;
            }
            
    }