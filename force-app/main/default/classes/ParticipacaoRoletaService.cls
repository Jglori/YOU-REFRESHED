public without sharing class ParticipacaoRoletaService {
    /**
     * Método responsável pela sincronização dos participantes das roletas com usuários
     * que tiveram a situação alterada.
     */
    public static void sincronizarParticipantes(List<User> usuarios, Map<Id, User> usuariosAntigosPorId) {
        List<User> usuariosFiltrados = obterUsuariosComSituacaoAlterada(usuarios, usuariosAntigosPorId);

        if(usuariosFiltrados.isEmpty()) { return; }

        if(System.isFuture()) { sincronizarParticipantes(usuariosFiltrados); }
        else { sincronizarParticipantesAsync(SObjectDomain.obterIds(usuariosFiltrados)); }
    }

    /**
     * Ob.: A sincronização dos participantes nas roletas em que os usuários são membros, 
     * sendo uma operação custosa, é realizada de forma assíncrona, garantindo rápida
     * exibição da situação do usuário no Omnichannel.
     */
    @Future
    private static void sincronizarParticipantesAsync(Set<Id> idsUsuarios) {
        List<User> usuarios = UserSelector.obterUsuariosPorIds(idsUsuarios);

        if(usuarios.isEmpty()) { return; }

        sincronizarParticipantes(usuarios);
    }

    private static void sincronizarParticipantes(List<User> usuarios) {
        List<MembroEquipe__c> membros = MembroEquipeSelector.obterMembrosPorIdsUsuarios(SObjectDomain.obterIds(usuarios));

        criarParticipantes(membros);
        atualizarParticipantes(membros);
    }

    private static void atualizarParticipantes(List<MembroEquipe__c> membros) {
        List<ParticipanteRoleta__c> participantesParaAtualizar = ParticipanteRoletaSelector.obterParticipantesPorIdsMembros(SObjectDomain.obterIds(membros));

        if(participantesParaAtualizar.isEmpty()) { return; }

        atualizarParticipantes(participantesParaAtualizar);
    }

    /**
     * Método responsável pela atualização dos participantes das roletas a partir
     * da situação do usuário.
     */
    private static void atualizarParticipantes(List<ParticipanteRoleta__c> participantes) {
        Map<Id,Id> mapParticipanteRoleta = new Map<Id,Id>(); 
        Set<Id> roletaIds =  new Set<Id>();

        for(ParticipanteRoleta__c participante : participantes) {
            atualizarSituacaoParticipante(participante, participante.MembroEquipe__r.Usuario__r);

            if(participante.MembroEquipe__r.Usuario__r.Situacao__c.equalsIgnoreCase('Online')){
                mapParticipanteRoleta.put(participante.Id, participante.RoletaLeads__c);
                roletaIds.add(participante.RoletaLeads__c);
            }
        }

        Map<Id, List<ParticipanteRoleta__c>> mapRoletaParticipanteList = new Map<Id, List<ParticipanteRoleta__c>>(); 
        for(ParticipanteRoleta__c participanteRoleta : ParticipanteRoletaSelector.obterParticipantesPorIdsRoleta(roletaIds)){
            if(mapRoletaParticipanteList.containsKey(participanteRoleta.RoletaLeads__c)){
                mapRoletaParticipanteList.get(participanteRoleta.RoletaLeads__c).add(participanteRoleta);
            } else {
                mapRoletaParticipanteList.put(participanteRoleta.RoletaLeads__c, new List<ParticipanteRoleta__c>{participanteRoleta});
            }
        }

        List<ParticipanteRoleta__c> participantesToDel =  new List<ParticipanteRoleta__c>();
        List<ParticipanteRoleta__c> participantesToUpd =  new List<ParticipanteRoleta__c>();

        for(ParticipanteRoleta__c participanteDel : participantes) {
            if(participanteDel.MembroEquipe__r.Usuario__r.Situacao__c.equalsIgnoreCase('offline')){
                participantesToDel.add(participanteDel);
            } else if(participanteDel.MembroEquipe__r.Usuario__r.Situacao__c.equalsIgnoreCase('online') && mapRoletaParticipanteList.containsKey(participanteDel.RoletaLeads__c)){
                participanteDel.Posicao__c = mapRoletaParticipanteList.get(participanteDel.RoletaLeads__c).size();
                participantesToUpd.add(participanteDel);
            } else {
                participantesToUpd.add(participanteDel);
            }
        }

        Database.update(participantesToUpd);
        Database.delete(participantesToDel);
    }

    private static void criarParticipantes(List<MembroEquipe__c> membros) {
        List<RoletaLeads__c> roletasLeads = RoletaLeadsSelector.obterRoletasLeadsPorIdsMembros(SObjectDomain.obterIds(membros));
        Map<Id, List<RoletaLeads__c>> roletasPorIdMembroParaCriar = obterRoletasPorIdMembroParaCriar(membros, roletasLeads);

        if(roletasPorIdMembroParaCriar.isEmpty()) { return; }

        criarParticipantes(membros, roletasPorIdMembroParaCriar);
    }

    /**
     * Método responsável pela criação dos participantes das roletas a partir da 
     * situação do usuário recebido.
     */
    private static void criarParticipantes(
        List<MembroEquipe__c> membros,
        Map<Id, List<RoletaLeads__c>> roletasPorIdMembroParaCriar
    ) {
        List<ParticipanteRoleta__c> participantes = new List<ParticipanteRoleta__c>();
        for(MembroEquipe__c membro : membros) {
            if(!roletasPorIdMembroParaCriar.containsKey(membro.Id)) { continue; }

            participantes.addAll(obterParticipantesCriados(membro, roletasPorIdMembroParaCriar.get(membro.Id)));
        }

        if(participantes.isEmpty()) { return; }

        Database.insert(participantes);
    }
    
    private static List<ParticipanteRoleta__c> obterParticipantesCriados(MembroEquipe__c membro, List<RoletaLeads__c> roletasLeads) {
        List<ParticipanteRoleta__c> participantesRoletaCriados = new List<ParticipanteRoleta__c>();
        Set<id> idRoleta = new Set<id>();

        for(RoletaLeads__c roletaLeads : roletasLeads) {
            idRoleta.add(roletaLeads.Id);
        }

        Map<Id, List<ParticipanteRoleta__c>> mapParticipantesPorRoleta = new Map<Id, List<ParticipanteRoleta__c>>();
        for (ParticipanteRoleta__c participante : ParticipanteRoletaSelector.obterParticipantesPorIdsRoleta(idRoleta)) {
            if (mapParticipantesPorRoleta.containsKey(participante.roletaLeads__C)) {
                mapParticipantesPorRoleta.get(participante.roletaLeads__C).add(participante);
            }else{
                mapParticipantesPorRoleta.put(participante.roletaLeads__C, new List<ParticipanteRoleta__c> {participante}); 
            }
        }
        
        for(RoletaLeads__c roletaLeads : roletasLeads) {
            participantesRoletaCriados.add(obterNovoParticipante(membro, roletaLeads.Id, mapParticipantesPorRoleta.get(roletaLeads.id)));
        }
        

        return participantesRoletaCriados;
    }


    /**
     * Método responsável pela obtenção de participante da roleta com campos de entrada
     * e saída atualizados de acordo com situação do usuário.
     */
    private static ParticipanteRoleta__c obterNovoParticipante(MembroEquipe__c membro, Id idRoletaLeads, List<ParticipanteRoleta__c> participanteRoleta) {
        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            RoletaLeads__c = idRoletaLeads,
            MembroEquipe__c = membro.Id,
            Name = membro.Usuario__r.Name,
            Posicao__c = (participanteRoleta == null) ? 1 : participanteRoleta.size() +1
        );

        atualizarSituacaoParticipante(participante, membro.Usuario__r);

        return participante;
    }

    /**
     * Método responsável pela atualização dos horários de entrada e saída do usuário e
     * informações de disponibilidade do participante de acordo com a situação do usuário.
     */
    private static ParticipanteRoleta__c atualizarSituacaoParticipante(ParticipanteRoleta__c participante, User usuario) {
        switch on usuario.Situacao__c {
            when 'Online' {
                participante.Entrada__c = System.now();
                participante.Saida__c = null;
                participante.TempoIndisponibilidade__c = obterTempoIndisponibilidadeEmMinutos(participante);
                participante.RegistroIndisponibilidade__c = null;

            }
            when 'Indisponível' {
                participante.RegistroIndisponibilidade__c = System.now();
                participante.Posicao__c = null;
            }
            when 'Offline' {
                participante.Saida__c = System.now();
                participante.TempoIndisponibilidade__c = obterTempoIndisponibilidadeEmMinutos(participante);
                participante.RegistroIndisponibilidade__c = null;
            }
            when else {
                return participante;
            }
        }

        return participante;
    }

    private static Integer obterTempoIndisponibilidadeEmMinutos(ParticipanteRoleta__c participante) {
        return participante.RegistroIndisponibilidade__c != null 
            ? Integer.valueOf((System.now().getTime() - participante.RegistroIndisponibilidade__c.getTime()) / 1000 / 60)
            : null;
    }

    private static Map<Id, List<RoletaLeads__c>> obterRoletasPorIdMembroParaCriar(List<MembroEquipe__c> membros, List<RoletaLeads__c> roletasLeads) {
        Map<Id, List<RoletaLeads__c>> roletasLeadsPorIdsEquipes = RoletaLeadsDomain.obterRoletasLeadsPorIdsEquipes(roletasLeads);
        Map<Id, Map<Id, List<ParticipanteRoleta__c>>> participantesPorIdMembroRoleta = obterParticipantesPorIdMembroRoleta(roletasLeads);

        Map<Id, List<RoletaLeads__c>> roletasPorIdMembroParaCriar = new Map<Id, List<RoletaLeads__c>>();
        for(MembroEquipe__c membro : membros) {
            if(!roletasLeadsPorIdsEquipes.containsKey(membro.Equipe__c)) { continue; }

            for(RoletaLeads__c roletaLeads : roletasLeadsPorIdsEquipes.get(membro.Equipe__c)) {
                Map<Id, List<ParticipanteRoleta__c>> participantesPorIdMembro = participantesPorIdMembroRoleta.get(roletaLeads.Id);

                if(participantesPorIdMembro.containsKey(membro.Id)) { continue; }

                if(!roletasPorIdMembroParaCriar.containsKey(membro.Id)) {
                    roletasPorIdMembroParaCriar.put(membro.Id, new List<RoletaLeads__c>());
                }

                roletasPorIdMembroParaCriar.get(membro.Id).add(roletaLeads);
            }
        }

        return roletasPorIdMembroParaCriar;
    }

    private static Map<Id, Map<Id, List<ParticipanteRoleta__c>>> obterParticipantesPorIdMembroRoleta(List<RoletaLeads__c> roletasLeads) {
        Map<Id, Map<Id, List<ParticipanteRoleta__c>>> participantesPorIdMembroRoleta = new Map<Id, Map<Id, List<ParticipanteRoleta__c>>>();
        for(RoletaLeads__c roletaLeads : roletasLeads) {
            participantesPorIdMembroRoleta.put(roletaLeads.Id, ParticipanteRoletaDomain.obterParticipantesPorIdMembro(roletaLeads.ParticipantesRoleta__r));
        }

        return participantesPorIdMembroRoleta;
    }

    private static List<User> obterUsuariosComSituacaoAlterada(List<User> usuarios, Map<Id, User> usuariosAntigosPorId) {
        List<User> usuariosFiltrados = new List<User>();
        for(User usuario : usuarios) {
            User usuarioAntigo = usuariosAntigosPorId.get(usuario.Id);

            if(usuario.Situacao__c == usuarioAntigo.Situacao__c) { continue; }

            usuariosFiltrados.add(usuario);
        }

        return usuariosFiltrados;
    }
}