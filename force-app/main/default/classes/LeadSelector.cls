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
        return [
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
    }
    
    public static List<Lead> obterLeadsPorIds(Set<Id> idsLeads) {
        Lead lead = [
            SELECT EmpreendimentoInteresse__r.Name 
            FROM Lead 
            WHERE Id = :idsLeads
        ];
    
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
                EmpreendimentoInteresse__c,
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

    public static List<Lead> obterLeadsPorChavesExternasClientes(Set<String> chavesClientes) {
        return [
            SELECT ChaveExternaWhatsApp__c 
            FROM Lead 
            WHERE ChaveExternaWhatsApp__c IN :chavesClientes
        ];
    }

    // public static List<Lead> obterLeadsPorInformacoesConcierge(String nomeCompleto, String celular, String email) {
    //     return Database.query(
    //         'SELECT ' +
    //         '    Name, ' +
    //         '    FirstName, ' +
    //         '    LastName, ' +
    //         '    MobilePhone, ' +
    //         '    Email, ' +
    //         '    Status, ' +
    //         '    LeadSource, ' +
    //         '    CanalAtendimento__c, ' +
    //         '    Owner.Name ' +
    //         'FROM Lead ' +
    //         'WHERE ' +
    //         '    (Name LIKE \'%' + nomeCompleto + '%\' AND Name != null) OR ' +
    //         '    (MobilePhone = :celular AND MobilePhone != null) OR ' +
    //         '    (Email = :email AND Email != null)'
    //     );
    // }

    public static List<Lead> obterLeadsPorInformacoesConcierge(String celular, String email, Boolean isJuridica, String phone) {
        String query = 'SELECT ' +
                       '    Id, ' +
                       '    Name, ' +
                       '    MobilePhone, ' +
                       '    Email, ' +
                       '    Status, ' +
                       '    Owner.Name, ' +
                       '    CorretorContato__r.Name, ' + // Campo de relacionamento adicionado
                       '    InicioDialogo__c, ' +
                       '    FimDialogo__c, ' +
                       '    UltimaMensagem__c, ' +
                       '    Phone, ' +
                       '    CreatedDate ' +
                       'FROM Lead ' +
                       'WHERE ';

        if (isJuridica) {
            query += '(Phone = :phone AND Phone != null) OR ' +
                     '(Email = :email AND Email != null)';
        } else {
            query += '(MobilePhone = :celular AND MobilePhone != null) OR ' +
                     '(Email = :email AND Email != null)';
        }

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