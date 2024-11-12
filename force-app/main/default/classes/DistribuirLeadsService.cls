public without sharing class DistribuirLeadsService {
    private static final Map<String, ConfiguracaoCanalAtendimento__mdt> CONFIGURACOES_POR_CANAL = new Map<String, ConfiguracaoCanalAtendimento__mdt>();

    /**
     * Método responsável pela distribuição de leads quando participantes disponíveis
     * para recepção.
     */
    public static void distribuirLeads(List<ParticipanteRoleta__c> participantes) {
        List<ParticipanteRoleta__c> participantesAtualizados = ParticipanteRoletaSelector.obterParticipantesPorIds(SObjectDomain.obterIds(participantes));
        List<ParticipanteRoleta__c> participantesOnline = obterParticipantesOnline(participantesAtualizados);

        if(participantesOnline.isEmpty()) { return; }

        List<Lead> leadsParaDistribuir = LeadSelector.obterLeadsParaDistribuir();

        if(System.isFuture()) { 
            TriggerHandler.bypass('ParticipanteRoletaTriggerHandler');

            distribuirLeadsSync(leadsParaDistribuir); 

            TriggerHandler.clearBypass('ParticipanteRoletaTriggerHandler');
        } else { 
            distribuirLeadsAsync(SObjectDomain.obterIds(leadsParaDistribuir)); 
        }
    }

    /**
     * Método responsável pela obtenção de participantes online dentre os recebidos,
     * isto é, participantes que, além de online, tenham:
     * 
     * - Carga restante superior a zero
     * - Distribuição não pausada
     * - Não exigência de validação ou presença validada pelo coordenador
     * - Canal de atendimento configurado
     */
    @TestVisible
    private static List<ParticipanteRoleta__c> obterParticipantesOnline(List<ParticipanteRoleta__c> participantes) {
        List<ParticipanteRoleta__c> participantesOnline = new List<ParticipanteRoleta__c>();
        for(ParticipanteRoleta__c participante : participantes) {
            if(participante.Situacao__c != 'Online') { continue; }
            if(!participante.PresencaValidada__c) { continue; } if(participante.CargaRestante__c <= 0) { continue; }if(participante.PausarDistribuicao__c) { continue; }if(participante.MembroEquipe__r.ExigeValidacaoCoordenador__c && !participante.PresencaValidada__c) { continue; } if(String.isBlank(participante.MembroEquipe__r.Usuario__r.CanaisAtendimento__c)) { continue; }

            participantesOnline.add(participante);
        }

        return participantesOnline;
    }

    /**
     * Método responsável pela distribuição de leads por roleta de acordo com o 
     * canal de atendimento selecionado. A distribuição é realizada diretamente
     * para uma roleta quando já tiver sido definida no lead ou para uma roleta
     * aleatório, caso contrário.
     */
    public static void distribuirLeads(List<Lead> leads) {
        List<Lead> leadsParaDistribuir = obterLeadsParaDistribuir(leads);

        if(leadsParaDistribuir.isEmpty()) { return; }

        if(System.isFuture()) {  TriggerHandler.bypass('LeadTriggerHandler');distribuirLeadsSync(leadsParaDistribuir);    TriggerHandler.clearBypass('LeadTriggerHandler');
        } else { 
            distribuirLeadsAsync(SObjectDomain.obterIds(leadsParaDistribuir)); 
        }
    }

    /**
     * Método responsável pela distribuição de leads de forma assíncrona quando
     * ainda não estiver sendo executado em contexto assíncrono.
     */
    @TestVisible
    @Future
    private static void distribuirLeadsAsync(Set<Id> idsLeads) {
        List<Lead> leads = LeadSelector.obterLeadsPorIds(idsLeads);

        if(leads.isEmpty()) { return; }

        distribuirLeadsSync(leads);
    }

    private static void distribuirLeadsSync(List<Lead> leads) {
        Map<String, List<Lead>> leadsPorCanalAtendimento = LeadDomain.obterLeadsPorCanalAtendimento(leads);

        CONFIGURACOES_POR_CANAL.putAll(CustomMetadataTypeDomain.obterConfiguracoesPorCanalAntendimento());

        if(leadsPorCanalAtendimento.isEmpty()) { return; }

        List<RoletaLeads__c> roletasLeads = RoletaLeadsSelector.obterRoletasLeadsPorCanaisAtendimento(String.join(leadsPorCanalAtendimento.keySet(), '\', \''));

        if(roletasLeads.isEmpty()) { return; } List<Lead> leadsParaAtualizar = new List<Lead>();leadsParaAtualizar.addAll(distribuirLeads(leads, roletasLeads));leadsParaAtualizar.addAll(distribuirLeadsComRoleta(leads, roletasLeads)); if(leadsParaAtualizar.isEmpty()) { return; } Database.update(leadsParaAtualizar);List<OmnichannelRefresh__e> omniRefresh = new List<OmnichannelRefresh__e>(); OmnichannelRefresh__e evt = new OmnichannelRefresh__e();
        EventBus.publish(omniRefresh);

        // Set<Id> membrosId = new Set<Id>();
        // for(Lead ld : leadsParaAtualizar){
        //     membrosId.add(ld.Corretor__c);
        // }
        
        // Set<String> setUsersToNotify = new Set<String>();
        // for(MembroEquipe__c member : MembroEquipeSelector.obterMembrosPorId(membrosId)){
        //     setUsersToNotify.add(member.Usuario__c);
        // }
        
        // if(!setUsersToNotify.isEmpty()){
        //     notifyUsers(setUsersToNotify, '');
        // }
    }

    /**
     * Método responsável pela distribuição de leads por roleta de acordo com
     * o canal de atendimento selecionado, considerando participantes ativos.
     * 
     * Obs.: Apenas leads com roleta atribuída são distribuídos.
     */
    @TestVisible
    private static List<Lead> distribuirLeadsComRoleta(List<Lead> leads, List<RoletaLeads__c> roletasLeads) {
        Map<Id, RoletaLeads__c> roletasLeadsPorId = new Map<Id, RoletaLeads__c>(roletasLeads);
        Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoleta = new Map<Id, List<ParticipanteRoleta__c>>();
        List<Lead> leadsParaAtualizar = new List<Lead>();

        for(Lead lead : leads) {
            if(lead.Corretor__c != null) { continue; }
            if(!roletasLeadsPorId.containsKey(lead.RoletaLeads__c)) { continue; } RoletaLeads__c roletaLeads = roletasLeadsPorId.get(lead.RoletaLeads__c);Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoletaEmDistribuicao = distribuirLeadEntreParticipantes(lead, roletaLeads);if(participantesPorIdRoletaEmDistribuicao.isEmpty()) { continue; } participantesPorIdRoleta.putAll(participantesPorIdRoletaEmDistribuicao);leadsParaAtualizar.add(lead);
        }

        if(participantesPorIdRoleta.isEmpty()) { return leadsParaAtualizar; } List<ParticipanteRoleta__c> participantes = reordenarParticipantesRoletasLeads(participantesPorIdRoleta); update participantes;return leadsParaAtualizar;
    }

    /**
     * Método responsável pela distribuição de leads por roleta de acordo com
     * o canal de atendimento selecionado, considerando participantes ativos.
     * 
     * Obs.: Apenas leads sem corretor e roleta atribuídos são distribuídos.
     */
    @TestVisible
    private static List<Lead> distribuirLeads(List<Lead> leads, List<RoletaLeads__c> roletasLeads) {
        Map<String, List<RoletaLeads__c>> roletasLeadsPorCanalAtendimento = RoletaLeadsDomain.obterRoletasLeadsPorCanalAtendimento(roletasLeads);
        Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoleta = new Map<Id, List<ParticipanteRoleta__c>>();
        List<Lead> leadsParaAtualizar = new List<Lead>();

        for(Lead lead : leads) {
            if(lead.Corretor__c != null) { continue; }
            if(lead.RoletaLeads__c != null) { continue; }
            if(!roletasLeadsPorCanalAtendimento.containsKey(lead.CanalAtendimento__c)) { continue; }

            for(RoletaLeads__c roletaLeads : roletasLeadsPorCanalAtendimento.get(lead.CanalAtendimento__c)) {
                if(roletaLeads.ParticipantesRoleta__r.isEmpty()) { continue; }

                Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoletaEmDistribuicao = distribuirLeadEntreParticipantes(lead, roletaLeads);

                if(participantesPorIdRoletaEmDistribuicao.isEmpty()) { continue; }

                participantesPorIdRoleta.putAll(participantesPorIdRoletaEmDistribuicao);
                leadsParaAtualizar.add(lead);

                break;
            }
        }

        if(participantesPorIdRoleta.isEmpty()) { return leadsParaAtualizar; }

        List<ParticipanteRoleta__c> participantes = reordenarParticipantesRoletasLeads(participantesPorIdRoleta);

        Database.update(participantes);

        return leadsParaAtualizar;
    }

    /**
     * Método responsável pela reordenação da lista de participantes das roletas 
     * de leads recebidas.
     */
    public static List<ParticipanteRoleta__c> reordenarParticipantesRoletasLeads(Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoleta) {
        List<ParticipanteRoleta__c> participantes = new List<ParticipanteRoleta__c>();
        for(Id idRoletaLeads : participantesPorIdRoleta.keySet()) {
            participantes.addAll(reordenarParticipantesRoletasLeads(participantesPorIdRoleta.get(idRoletaLeads)));
        }

        return participantes;
    }

    public static List<ParticipanteRoleta__c> reordenarParticipantesRoletasLeads(List<ParticipanteRoleta__c> participantes) {
        for(Integer i = 0; i < participantes.size(); i++) {
            participantes.get(i).Posicao__c = i;
        }

        return participantes;
    }

    /**
     * Método responsável pela distribuição do lead entre participantes da roleta
     * de leads, verificando capacidade de atendimento caso canal não seja bypass.
     */
    @TestVisible
    private static Map<Id, List<ParticipanteRoleta__c>> distribuirLeadEntreParticipantes(Lead lead, RoletaLeads__c roletaLeads) {
        Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoleta = new Map<Id, List<ParticipanteRoleta__c>>();
        for(Integer i = 0; i < roletaLeads.ParticipantesRoleta__r.size(); i++) {
            if(!canalConfigurado(lead, roletaLeads.ParticipantesRoleta__r.get(i))) { continue; }
            if(!canalBypass(lead) && !possuiCapacidadeAtendimento(lead, roletaLeads.ParticipantesRoleta__r.get(i))) { continue; }

            participantesPorIdRoleta.putAll(distribuirLeadParaParticipante(lead, i, new List<ParticipanteRoleta__c>(roletaLeads.ParticipantesRoleta__r)));

            break;
        }

        return participantesPorIdRoleta;
    }

        public static Map<Id, List<ParticipanteRoleta__c>> distribuirLeadParaParticipante(Lead lead, Integer posicaoParticipante, List<ParticipanteRoleta__c> participantes) {
        Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoleta = new Map<Id, List<ParticipanteRoleta__c>>();

        ParticipanteRoleta__c participante = participantes.remove(posicaoParticipante);

        distribuirLead(lead, participante.RoletaLeads__c, participante.Id);

        participantes.add(participante);
        participantesPorIdRoleta.put(participante.RoletaLeads__c, participantes);

        return participantesPorIdRoleta;
    }

    public static void distribuirLead(Lead lead, Id idRoleta, Id idCorretor) {
        lead.RoletaLeads__c = idRoleta;
        lead.Corretor__c = idCorretor;
    }

        public static Boolean possuiCapacidadeAtendimento(Lead lead, ParticipanteRoleta__c participante) {
        return (participante.CargaRestante__c ?? 0) - (CONFIGURACOES_POR_CANAL.get(lead.CanalAtendimento__c)?.Carga__c ?? 0) >= 0;
    }

    public static Boolean canalBypass(Lead lead) {
        return CONFIGURACOES_POR_CANAL.get(lead.CanalAtendimento__c)?.Bypass__c ?? false;
    }

    public static Boolean canalConfigurado(Lead lead, ParticipanteRoleta__c participante) {
        return String.isNotBlank(participante.MembroEquipe__r?.Usuario__r?.CanaisAtendimento__c) 
            ? participante.MembroEquipe__r.Usuario__r.CanaisAtendimento__c.contains(lead.CanalAtendimento__c)
            : false;
    }

    /**
     * Método responsável pela obtenção de leads pendentes de distribuição, ou seja,
     * sem corretor atribuído.
     */
    @testVisible
    private static List<Lead> obterLeadsParaDistribuir(List<Lead> leads) {
        List<Lead> leadsParaDistribuir = new List<Lead>();
        for(Lead lead : leads) {
            if(lead.Corretor__c != null) { continue; }

            leadsParaDistribuir.add(lead);
        }

        return leadsParaDistribuir;
    }

    public static void notifyUsers(Set<String> recipientsIds, String targetId) {

        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='NotificacaoPersonalizada'];
        
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('Você Recebeu um novo Lead');
        notification.setBody('Favor abrir o omnichannel para verificar o atendimento');
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}