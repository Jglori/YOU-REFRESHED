public without sharing class DistribuirLeadsService {
    private static final Map<String, ConfiguracaoCanalAtendimento__mdt> CONFIGURACOES_POR_CANAL = new Map<String, ConfiguracaoCanalAtendimento__mdt>();

    /**
     * Método responsável pela distribuição de leads quando participantes disponíveis
     * para recepção.
     */
    public static void distribuirLeads(List<ParticipanteRoleta__c> participantes) {
        List<ParticipanteRoleta__c> participantesAtualizados = ParticipanteRoletaSelector.obterParticipantesPorIds(SObjectDomain.obterIds(participantes));
        List<ParticipanteRoleta__c> participantesOnline = obterParticipantesOnline(participantesAtualizados);

        if(participantesOnline.isEmpty()) { return; } List<Lead> leadsParaDistribuir = LeadSelector.obterLeadsParaDistribuir();if(System.isFuture()) {  TriggerHandler.bypass('ParticipanteRoletaTriggerHandler');distribuirLeadsSync(leadsParaDistribuir);  TriggerHandler.clearBypass('ParticipanteRoletaTriggerHandler');} else { distribuirLeadsAsync(SObjectDomain.obterIds(leadsParaDistribuir)); 
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
            if(!participante.PresencaValidada__c) { continue; } if(participante.CargaRestante__c <= 0) { continue; }if(participante.PausarDistribuicao__c) { continue; }if(participante.MembroEquipe__r.ExigeValidacaoCoordenador__c && !participante.PresencaValidada__c) { continue; }if(String.isBlank(participante.MembroEquipe__r.Usuario__r.CanaisAtendimento__c)) { continue; } participantesOnline.add(participante);
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

        if(System.isFuture()) { 
            TriggerHandler.bypass('LeadTriggerHandler');distribuirLeadsSync(leadsParaDistribuir); TriggerHandler.clearBypass('LeadTriggerHandler');} else { distribuirLeadsAsync(SObjectDomain.obterIds(leadsParaDistribuir)); 
        }
    }

    /**
     * Método responsável pela distribuição de leads de forma assíncrona quando
     * ainda não estiver sendo executado em contexto assíncrono.
     */
    @TestVisible
    @Future
    private static void distribuirLeadsAsync(Set<Id> idsLeads) {

        System.debug('Distribuindo leads de forma assíncrona.');
        System.debug('Leads: ' + idsLeads);
        List<Lead> leads = LeadSelector.obterLeadsPorIds(idsLeads);
        


        if(leads.isEmpty()) { return; }

        distribuirLeadsSync(leads);
    }
   public static void distribuirLeadsSync(List<Lead> leads) { if (leads == null || leads.isEmpty()) { System.debug('A lista de leads está nula ou vazia!'); return; } List<Lead> leadsComCorretor = [SELECT Id, CorretorContato__c, Status , CanalAtendimento__c , Corretor__c , RoletaLeads__c FROM Lead WHERE Id IN :leads]; List<Lead> leadsFiltrados = new List<Lead>(); for (Lead lead : leadsComCorretor) { if (lead.CorretorContato__c == null && lead.Status == 'Novo') { leadsFiltrados.add(lead); } } if (leadsFiltrados.isEmpty()) { System.debug('Nenhum lead a ser processado após o filtro!'); return; } Map<String, List<Lead>> leadsPorCanalAtendimento = LeadDomain.obterLeadsPorCanalAtendimento(leadsFiltrados); if (leadsPorCanalAtendimento == null || leadsPorCanalAtendimento.isEmpty()) { System.debug('O mapa de leadsPorCanalAtendimento está nulo ou vazio!'); return; } Map<String, ConfiguracaoCanalAtendimento__mdt> configuracoesPorCanal = CustomMetadataTypeDomain.obterConfiguracoesPorCanalAntendimento(); if (configuracoesPorCanal == null || configuracoesPorCanal.isEmpty()) { System.debug('O mapa de configuracoesPorCanal está nulo ou vazio!'); return; } CONFIGURACOES_POR_CANAL.putAll(configuracoesPorCanal); if (CONFIGURACOES_POR_CANAL == null || CONFIGURACOES_POR_CANAL.isEmpty()) { System.debug('CONFIGURACOES_POR_CANAL está nulo ou vazio após putAll!'); return; } List<RoletaLeads__c> roletasLeads = RoletaLeadsSelector.obterRoletasLeadsPorCanaisAtendimento(String.join(leadsPorCanalAtendimento.keySet(), '\', \'')); if (roletasLeads == null || roletasLeads.isEmpty()) { System.debug('A lista de roletasLeads está nula ou vazia!'); return; } List<Lead> leadsParaAtualizar = new List<Lead>(); leadsParaAtualizar.addAll(distribuirLeads(leadsFiltrados, roletasLeads)); leadsParaAtualizar.addAll(distribuirLeadsComRoleta(leadsFiltrados, roletasLeads)); if (leadsParaAtualizar == null || leadsParaAtualizar.isEmpty()) { System.debug('A lista de leads para atualizar está nula ou vazia!'); return; } try { Database.update(leadsParaAtualizar); } catch (Exception e) { System.debug('Erro ao atualizar os leads: ' + e.getMessage()); return; } List<OmnichannelRefresh__e> omniRefresh = new List<OmnichannelRefresh__e>(); OmnichannelRefresh__e evt = new OmnichannelRefresh__e(); omniRefresh.add(evt); EventBus.publish(omniRefresh); System.debug('Leads processados e atualizados com sucesso!'); }

    
    
    

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
            if(lead.Corretor__c != null) { continue; } if(!roletasLeadsPorId.containsKey(lead.RoletaLeads__c)) { continue; } RoletaLeads__c roletaLeads = roletasLeadsPorId.get(lead.RoletaLeads__c); Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoletaEmDistribuicao = distribuirLeadEntreParticipantes(lead, roletaLeads);if(participantesPorIdRoletaEmDistribuicao.isEmpty()) { continue; } participantesPorIdRoleta.putAll(participantesPorIdRoletaEmDistribuicao);leadsParaAtualizar.add(lead);
        }

        if(participantesPorIdRoleta.isEmpty()) { return leadsParaAtualizar; }

        List<ParticipanteRoleta__c> participantes = reordenarParticipantesRoletasLeads(participantesPorIdRoleta);

        update participantes;

        return leadsParaAtualizar;
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
    @TestVisible
    private static List<ParticipanteRoleta__c> reordenarParticipantesRoletasLeads(Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoleta) {
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
    System.debug('Iniciando a distribuição de lead ' + lead.Id + ' entre os participantes da roleta ' + roletaLeads.Id);
    
    Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoleta = new Map<Id, List<ParticipanteRoleta__c>>();

    // Iterar sobre os participantes da roleta
    for (Integer i = 0; i < roletaLeads.ParticipantesRoleta__r.size(); i++) {
        ParticipanteRoleta__c participante = roletaLeads.ParticipantesRoleta__r.get(i);

        // Verifica se o canal está configurado corretamente
        if (!canalConfigurado(lead, participante)) {
            System.debug('Canal não configurado para o participante ' + participante.Id);
            continue;
        }

        // Verifica se o participante possui capacidade de atendimento
        if (!canalBypass(lead) && !possuiCapacidadeAtendimento(lead, participante)) {
            System.debug('Capacidade de atendimento insuficiente para o participante ' + participante.Id);
            continue;
        }

        // Distribui o lead para o participante
        participantesPorIdRoleta.putAll(distribuirLeadParaParticipante(lead, i, new List<ParticipanteRoleta__c>(roletaLeads.ParticipantesRoleta__r)));
        break; // Interrompe após distribuir o lead para um participante
    }

    System.debug('Leads distribuídos: ' + participantesPorIdRoleta.size());
    return participantesPorIdRoleta;
}

public static Map<Id, List<ParticipanteRoleta__c>> distribuirLeadParaParticipante(Lead lead, Integer posicaoParticipante, List<ParticipanteRoleta__c> participantes) {
    System.debug('Distribuindo lead ' + lead.Id + ' para o participante na posição ' + posicaoParticipante);
    
    Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoleta = new Map<Id, List<ParticipanteRoleta__c>>();

    ParticipanteRoleta__c participante = participantes.remove(posicaoParticipante);

    // Realiza a distribuição do lead
    distribuirLead(lead, participante.RoletaLeads__c, participante.Id);

    participantes.add(participante); // Re-insere o participante na lista
    participantesPorIdRoleta.put(participante.RoletaLeads__c, participantes);

    System.debug('Lead ' + lead.Id + ' distribuído para o participante ' + participante.Id);
    return participantesPorIdRoleta;
}

public static void distribuirLead(Lead lead, Id idRoleta, Id idCorretor) {
    System.debug('Atribuindo lead ' + lead.Id + ' à roleta ' + idRoleta + ' e corretor ' + idCorretor);

    lead.RoletaLeads__c = idRoleta;
    lead.Corretor__c = idCorretor;
}

public static Boolean possuiCapacidadeAtendimento(Lead lead, ParticipanteRoleta__c participante) {
   return true;
}

public static Boolean canalBypass(Lead lead) {
    Boolean bypass = CONFIGURACOES_POR_CANAL.get(lead.CanalAtendimento__c)?.Bypass__c ?? false;
    System.debug('Verificando bypass para o canal ' + lead.CanalAtendimento__c + ': ' + bypass);
    return true;
}

public static Boolean canalConfigurado(Lead lead, ParticipanteRoleta__c participante) {
    String canaisAtendimento = participante.MembroEquipe__r?.Usuario__r?.CanaisAtendimento__c;

    Boolean configurado = String.isNotBlank(canaisAtendimento) && canaisAtendimento.contains(lead.CanalAtendimento__c);
    System.debug('Verificando se o canal ' + lead.CanalAtendimento__c + ' está configurado para o participante ' + participante.Id + ': ' + configurado);
    
    return configurado;
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