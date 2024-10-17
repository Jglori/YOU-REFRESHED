public without sharing class RoletaLeadsSelector {
    public static List<RoletaLeads__c> obterRoletasLeadsPorIdsMembros(Set<Id> idsMembros) {
        return [
            SELECT 
                CanaisAtendimento__c, 
                Equipe__c, 
                Equipe__r.CargaMaxima__c,
                (
                    SELECT 
                        MembroEquipe__c, 
                        MembroEquipe__r.Usuario__r.Situacao__c
                    FROM ParticipantesRoleta__r
                )
            FROM RoletaLeads__c 
            WHERE 
                Ativa__c = true AND
                DentroHorarioFuncionamento__c = true AND
                Equipe__c IN (SELECT Equipe__c FROM MembroEquipe__c WHERE Id IN :idsMembros)
        ];
    }

    public static List<RoletaLeads__c> obterRoletasLeadsPorIdsUsuarios(Set<Id> idsUsuarios) {
        return [
            SELECT 
                CanaisAtendimento__c, 
                Equipe__r.CargaMaxima__c, 
                (SELECT Id FROM ParticipantesRoleta__r WHERE MembroEquipe__r.Usuario__c IN :idsUsuarios) 
            FROM RoletaLeads__c 
            WHERE Equipe__c IN (SELECT Equipe__c FROM MembroEquipe__c WHERE Usuario__c IN :idsUsuarios)
        ];
    }

    public static List<RoletaLeads__c> obterRoletasLeadsVigentes() {
        return [SELECT Name, CanaisAtendimento__c, HoraInicio__c, HoraFim__c FROM RoletaLeads__c WHERE Ativa__c = true AND DentroHorarioFuncionamento__c = true];
    }

    public static List<RoletaLeads__c> obterRoletasLeadsPorCanaisAtendimento(String canaisAtendimento) {
        String consulta = 'SELECT ' + 
            '    Name, ' + 
            '    CanaisAtendimento__c, ' + 
            '    Equipe__c, ' + 
            '    ( ' + 
            '        SELECT ' + 
            '           MembroEquipe__r.Usuario__c, ' +  
            '           MembroEquipe__r.Usuario__r.CanaisAtendimento__c, ' +  
            '           RoletaLeads__c, ' +  
            '           CargaRestante__c, ' + 
            '           Situacao__c, ' + 
            '           QuantidadeLeadsChat__c, ' + 
            '           QuantidadeLeadsWhatsApp__c, ' + 
            '           QuantidadeLeadsTelefone__c,UsuarioCorretor__c, ' + 
            '           QuantidadeLeadsLoja__c, ' + 
            '           QuantidadeLeadsStand__c, ' + 
            '           QuantidadeLeadsFaleConosco__c ' + 
            '        FROM ParticipantesRoleta__r ' + 
            '        WHERE ' + 
            '           Situacao__c = \'Online\' AND ' + 
            '           PausarDistribuicao__c = false AND ' + 
            '           ( ' + 
            '               (MembroEquipe__r.ExigeValidacaoCoordenador__c = true AND PresencaValidada__c = true) OR ' + 
            '               (MembroEquipe__r.ExigeValidacaoCoordenador__c = false) ' + 
            '           ) ' + 
            '        ORDER BY Posicao__c ASC NULLS LAST ' + 
            '    ) ' + 
            'FROM RoletaLeads__c ' + 
            'WHERE ' + 
            '    Ativa__c = true AND ' + 
            '    DentroHorarioFuncionamento__c = true';

        return String.isBlank(canaisAtendimento)
            ? Database.query(consulta)
            : Database.query(consulta + ' AND CanaisAtendimento__c INCLUDES(\'' + canaisAtendimento + '\')');
    }
}