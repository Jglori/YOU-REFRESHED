public without sharing class LeadSelector {
    
    public static List<Lead> obterLeadsParaDistribuir() {
        return [
            SELECT
                Id,
                Name,
                CanalAtendimento__c,
                RoletaLeads__c,
                Corretor__c,
                ChaveExternaWhatsApp__c,
                FirstName,
                LastName,
                MobilePhone,
                Email,
                CreatedDate,
                Status,
                OwnerId,
                Owner.Name,
                InicioDialogo__c,
                FimDialogo__c,
                UltimaMensagem__c
            FROM Lead
            WHERE Corretor__c = null
        ];
    }
    
    public static List<Lead> obterLeadsPorIdsProprietarios(Set<Id> idsProprietarios) {
        return [
            SELECT 
                Name, 
                Email, 
                CreatedDate, 
                OwnerId, 
                Owner.Name
            FROM Lead 
            WHERE status NOT IN ('Lead Perdido(não trabalho)', 'Conversão', 'Descartado')
            AND OwnerId IN :idsProprietarios
        ];
    }
    
    public static List<Lead> obterLeadsPorIdsCorretores(Set<Id> idsCorretores) {
        return [
            SELECT 
                Name, 
                Email 
            FROM Lead 
            WHERE Corretor__c IN :idsCorretores
        ];
    }
    
    public static List<Lead> obterLeadsPorIdsUsuarios(Set<Id> idsCorretores) {
        // Obtemos os membros da equipe e os nomes das equipes associadas aos corretores
        List<MembroEquipe__c> membros = [
            SELECT Id, Equipe__r.Name 
            FROM MembroEquipe__c 
            WHERE Usuario__r.Id IN :idsCorretores
        ];
    
        // Agora, obtemos os nomes das equipes dos membros
        Set<String> nomesEquipes = new Set<String>();
        for (MembroEquipe__c membro : membros) {
            nomesEquipes.add(membro.Equipe__r.Name);
        }
    
        // Consulta os leads com roleta e cuja equipe está no conjunto de nomes
        List<Lead> leadsComRoleta = [
            SELECT
                Name,
                Email,
                CanalAtendimento__c,
                OwnerId,
                Owner.Name,
                CreatedDate,
                Corretor__r.CargaRestante__c,
                RoletaLeads__r.Name,          
                RoletaLeads__r.Equipe__r.Name
            FROM Lead
            WHERE
                RoletaLeads__r.Id != null 
                AND CorretorContato__c = null 
                AND RoletaLeads__r.Equipe__r.Name IN :nomesEquipes
        ];
    
        // Consulta os leads associados a corretores e que não estão associados ao mesmo corretor
        List<Lead> leadsComEquipe = [
            SELECT
                Name,
                Email,
                CanalAtendimento__c,
                OwnerId,
                Owner.Name,
                CreatedDate,
                Corretor__r.CargaRestante__c
            FROM Lead
            WHERE
                Corretor__r.MembroEquipe__r.Usuario__c IN :idsCorretores
                AND OwnerId NOT IN :idsCorretores
        ];
    
        // Para evitar duplicação, usamos um Set para controlar os IDs dos leads já recuperados
        Set<Id> leadIds = new Set<Id>();
        List<Lead> todosLeads = new List<Lead>();
    
        // Adiciona os leads de RoletaLeads sem duplicação
        for (Lead lead : leadsComRoleta) {
            if (!leadIds.contains(lead.Id)) {
                todosLeads.add(lead);
                leadIds.add(lead.Id);
            }
        }
    
        // Adiciona os leads da equipe sem duplicação
        for (Lead lead : leadsComEquipe) {
            if (!leadIds.contains(lead.Id)) {
                todosLeads.add(lead);
                leadIds.add(lead.Id);
            }
        }
    
        // Retorna a lista combinada sem duplicação
        return todosLeads;
    }
    
    
    public static List<Lead> bolsaoLeads(Set<Id> idsCorretores) {
        return [
            SELECT
                Id,
                Name,
                Email,
                CanalAtendimento__c,
                OwnerId,
                Owner.Name,
                CreatedDate,
                Corretor__r.CargaRestante__c
            FROM Lead
            WHERE
                RoletaLeads__c != ''
                AND CorretorContato__r.Name = ''
                AND OwnerId NOT IN :idsCorretores
        ];
    }
    
    


    public static List<Lead> obterLeadsPorIds(Set<Id> idsLeads) {
        return [
            SELECT
                Name,
                CanalAtendimento__c,
                RoletaLeads__c,
                Corretor__c,
                ChaveExternaWhatsApp__c,
                FirstName,
                LastName,
                MobilePhone,
                Email,
                Status,
                OwnerId,
                CreatedDate,
                Owner.Name,
                InicioDialogo__c,
                FimDialogo__c,
                UltimaMensagem__c,
                EmpreendimentoInteresse__r.Name,
                RemetenteWhatsApp__c,
                Corretor__r.QuantidadeLeadsFaleConosco__c,
                Corretor__r.QuantidadeLeadsChat__c,
                Corretor__r.QuantidadeLeadsWhatsApp__c,
                Corretor__r.QuantidadeLeadsTelefone__c,
                Corretor__r.QuantidadeLeadsLoja__c,
                Corretor__r.QuantidadeLeadsStand__c
            FROM Lead
            WHERE Id IN :idsLeads
        ];
    }
    
    // esse metodo esra esperando um set de ids mas esta passando uma lista o que esra errado 
    // public static List<Lead> obterLeadsPorIds(Set<Id> idsLeads) {
    //     Lead lead = [
    //         SELECT EmpreendimentoInteresse__r.Name 
    //         FROM Lead 
    //         WHERE Id = :idsLeads
    //     ];
    
    //     return [
    //         SELECT
    //             Name,
    //             CanalAtendimento__c,
    //             RoletaLeads__c,
    //             Corretor__c,
    //             ChaveExternaWhatsApp__c,
    //             FirstName,
    //             LastName,
    //             MobilePhone,
    //             Email,
    //             Status,
    //             OwnerId,
    //             CreatedDate,
    //             Owner.Name,
    //             InicioDialogo__c,
    //             FimDialogo__c,
    //             UltimaMensagem__c,
    //             EmpreendimentoInteresse__c,
    //             Corretor__r.QuantidadeLeadsFaleConosco__c,
    //             Corretor__r.QuantidadeLeadsChat__c,
    //             Corretor__r.QuantidadeLeadsWhatsApp__c,
    //             Corretor__r.QuantidadeLeadsTelefone__c,
    //             Corretor__r.QuantidadeLeadsLoja__c,
    //             Corretor__r.QuantidadeLeadsStand__c
    //         FROM Lead
    //         WHERE Id IN :idsLeads
    //     ];
    // }

    public static List<Lead> obterLeadsPorChavesExternasClientes(Set<String> chavesClientes) {
        return [
            SELECT ChaveExternaWhatsApp__c 
            FROM Lead 
            WHERE ChaveExternaWhatsApp__c IN :chavesClientes
        ];
    }

    public static List<Lead> obterLeadsPorInformacoesConcierge(String nomeCompleto, String celular, String email) {
        return Database.query(
            'SELECT ' +
            '    Name, ' +
            '    FirstName, ' +
            '    LastName, ' +
            '    MobilePhone, ' +
            '    Email, ' +
            '    Status, ' +
            '    LeadSource, ' +
            '    CanalAtendimento__c, ' +
            '    Owner.Name ' +
            'FROM Lead ' +
            'WHERE ' +
            '    (Name LIKE \'%' + nomeCompleto + '%\' AND Name != null) OR ' +
            '    (MobilePhone = :celular AND MobilePhone != null) OR ' +
            '    (Email = :email AND Email != null)'
        );
    }

    public static List<Lead> obterLeadsPorInformacoesConcierge(String celular, String email, Boolean isJuridica, String phone) {
        List<String> conditions = new List<String>();
    
        // Construir as condições da consulta dinamicamente
        if (isJuridica) {
            if (String.isNotBlank(phone)) {
                conditions.add('(Phone = :phone)');
            }
            if (String.isNotBlank(email)) {
                conditions.add('(EmailAdicional__c = :email)');
                conditions.add('(Email = :email)');
            }
        } else {
            if (String.isNotBlank(celular)) {
                conditions.add('(MobilePhone = :celular)');
                conditions.add('(CelularAdicional__c = :celular)');
                conditions.add('(CelularAdicional1__c = :celular)');
                conditions.add('(CelularAdicional2__c = :celular)');
                conditions.add('(CelularComercialAdicional__c = :celular)');
            }
            if (String.isNotBlank(email)) {
                conditions.add('(Email = :email)');
                conditions.add('(EmailAdicional__c = :email)');
            }
        }
    
        // Se nenhuma condição for adicionada, retorne uma lista vazia
        if (conditions.isEmpty()) {
            return new List<Lead>();
        }
    
        // Construa a consulta com as condições dinâmicas
        String query = 'SELECT ' +
                       '    Id, ' +
                       '    Name, ' +
                       '    MobilePhone, ' +
                       '    Email, ' +
                       '    Status, ' +
                       '    Owner.Name, ' +
                       '    CorretorContato__r.Name, ' + 
                       '    InicioDialogo__c, ' +
                       '    FimDialogo__c, ' +
                       '    UltimaMensagem__c, ' +
                       '    Phone, ' +
                       '    CreatedDate ' +
                       'FROM Lead ' +
                       'WHERE ' + String.join(conditions, ' OR ') +
                       ' LIMIT 500';
    
        // Realize a consulta usando a string de consulta dinâmica
        return Database.query(query);
    }
    
    
    public static Lead obterMobilePhoneLead(String idLead) {
        return [
            SELECT MobilePhone 
            FROM Lead 
            WHERE Id = :idLead
        ];
    }

    public static Lead obterInfosTemplatePadrao(String idLead) {
        return [
            SELECT 
                MobilePhone,
                FirstName,
                Owner.Name,
                EmpreendimentoInteresse__c,
                ChaveExternaWhatsApp__c
            FROM Lead 
            WHERE Id = :idLead
        ];
    }
}