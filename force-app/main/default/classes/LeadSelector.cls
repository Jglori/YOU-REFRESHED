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
                Owner.Name,
                CorretorContato__r.Name
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
                Corretor__r.CargaRestante__c,
                CorretorContato__r.Name
            FROM Lead
            WHERE
                Corretor__r.MembroEquipe__r.Usuario__c IN :idsCorretores 
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
        if (isJuridica) {if (String.isNotBlank(phone)) {conditions.add('(Phone = :phone)');}if (String.isNotBlank(email)) {conditions.add('(EmailAdicional__c = :email)');conditions.add('(Email = :email)');
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
    
    
    /**
     * Método que verifica se o email informado já existe na base de leads.
     * @param requests Lista de leads a serem verificados.
     * @return Lista de Ids dos leads que possuem email igual.
     */
    @InvocableMethod(label='Verificar E-mail valido' description='Verifica se o email esta disponível dentro da base.')
    public static List<Id> obterLeadsEmailValido(List<Lead> requests) {
        List<Id> responses = new List<Id>();
        if(requests == null || requests.isEmpty()) { responses = new List<Id>(); }
        
        for (Lead request : requests) {
            List<Lead> leadsEmailIgual = [
                SELECT Email
                FROM Lead
                WHERE Email = :request.Email
            ];
            
            if (!leadsEmailIgual.isEmpty()) {
                responses.add(request.Id);
            } else {
                responses.add(request.Id);
            }
        }
        return responses;
    }
}