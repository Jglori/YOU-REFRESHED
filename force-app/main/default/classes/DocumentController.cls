public with sharing class DocumentController {

    @AuraEnabled
    public static List<Documentacao__c> validateDocument(Id id){
        try {
            return DocumentacaoHelper.validateDocuments(new Set<Id>{ id });
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Documentacao__c> invalidateDocument(Id id){
        try {
            return DocumentacaoHelper.invalidateDocuments(new Set<Id>{ id });
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    @AuraEnabled(cacheable=true)
    public static List<Documentacao__c> getDocumentosByAnaliseCredito(Id analiseCreditoId){
        try {
            return DocumentacaoHelper.getByAnaliseCredito(analiseCreditoId);
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao buscar documentos: '+ e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Documentacao__c> getByOpportunity(Id opportunityId) {
        try {
            return DocumentacaoHelper.getByOpportunityId(new Set<Id>{ opportunityId });
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao buscar documentos: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunityContactRole> getOpportunityContactRoleByOpportunityId(Id opportunityId){
        List<OpportunityContactRole> roles = [
            SELECT ContactId, Contact.Name, Role
            FROM OpportunityContactRole 
            WHERE OpportunityId = :opportunityId AND Role != null
        ];
        
        return roles;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getDocumentsForEachContactRole(Id opportunityId) {
        try {
            return DocumentacaoHelper.getDocumentsFromOppToContactRoles(opportunityId);
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao buscar documentos: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunityContactRole> getContactRoles(String contactId) {
        if (String.isEmpty(contactId)) {
            throw new IllegalArgumentException('ContactId não pode ser nulo ou vazio.');
        }
        
        // Realiza a consulta SOQL
        List<OpportunityContactRole> roles = [
            SELECT Role
            FROM OpportunityContactRole
            WHERE ContactId = :contactId
            LIMIT 200
        ];
        
        return roles;
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsByAccountId(Id accountId) {
        return [SELECT Id, Name, AccountId FROM Contact WHERE AccountId = :accountId OR Id = :accountId];
    }

    @AuraEnabled(cacheable=true)
    public static List<Checklist_de_Documentos__c> documentosEntregues(Id contactId) {
        // Verifica se o contactId foi fornecido
        if (contactId == null) {
            throw new AuraHandledException('O ID do contato não pode ser nulo.');
        }
        
        // Executa a query para obter os documentos entregues
        List<Checklist_de_Documentos__c> documentos = [
            SELECT Documenta_o__r.Name,
                   Documenta_o__r.ContentDocumentId_c__c,
                   Documenta_o__r.Contato__c,
                   Documenta_o__r.Entregue__c
            FROM Checklist_de_Documentos__c
            WHERE Documenta_o__r.Contato__c = :contactId
        ];
        
        return documentos;
    }

    @AuraEnabled(cacheable=true)
    public static List<Documentacao__c> buscarDocumento(String papelContato) {
        // Verifica se o parâmetro não é nulo ou vazio
        if (String.isEmpty(papelContato)) {
            return new List<Documentacao__c>(); // Retorna uma lista vazia se o parâmetro estiver vazio
        }
        
        return [
            SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Contato__c, Obrigatorio__c
            FROM Documentacao__c 
            WHERE Obrigatorio__c = true 
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Documento__mdt> getDocumentosPorPapeis(List<String> papeis) {
        try {
            return DocumentacaoHelper.getMetadasByPapers(papeis);
        } catch (Exception e) {
            System.debug('Erro na consulta de documentos: ' + e.getMessage());
            throw new AuraHandledException('Erro ao buscar documentos: ' + e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Documento__mdt> getDocumentosPorPapel(String paper) {
        try {
            return DocumentacaoHelper.getMetadasByPaper(paper);
        } catch (Exception e) {
            System.debug('Erro na consulta de documentos: ' + e.getMessage());
            throw new AuraHandledException('Erro ao buscar documentos: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Documentacao__c salvarImagem(Id contactId, Id opportunityId, Boolean obrigatorio, String title, String fileName, String base64, String fileType) {
        try {
            return DocumentacaoHelper.create(contactId, opportunityId, obrigatorio, base64, title, fileName, fileType);
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao salvar a imagem: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void salvarImagemContato(String contatoId, Boolean obrigatorio, String fileName, String base64Data) {
        try {
            // Criar a versão do conteúdo
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.VersionData = EncodingUtil.base64Decode(base64Data);
            insert contentVersion;
        
            // Obter o ID do documento de conteúdo
            ContentVersion insertedContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
            String contentDocumentId = insertedContentVersion.ContentDocumentId;
        
            // Criar o link do documento de conteúdo
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = contentDocumentId;
            contentDocumentLink.LinkedEntityId = contatoId; // Associação com o contato
            contentDocumentLink.ShareType = 'I'; 
            contentDocumentLink.Visibility = 'AllUsers';
            insert contentDocumentLink;
        
            // Obter informações do Documento__mdt
            Documento__mdt docConfig = [SELECT Nome_do_Documento__c, Obrigatorio__c, Papel__c
                                        FROM Documento__mdt
                                        WHERE Nome_do_Documento__c = :fileName
                                        LIMIT 1];
        
            // Criar o registro de Documentacao__c
            Documentacao__c documento = new Documentacao__c();
            documento.Contato__c = contatoId;
            documento.Obrigatorio__c = docConfig.Obrigatorio__c;
            documento.Entregue__c = true;
            documento.Name = docConfig.Nome_do_Documento__c;
            documento.ContentDocumentId_c__c = contentDocumentId;
            insert documento;

            Checklist_de_Documentos__c checklist = new Checklist_de_Documentos__c();
            checklist.Contato__c = contatoId;
            checklist.Documenta_o__c = documento.Id;
            insert checklist;
        
            System.debug('Imagem salva com sucesso');
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao salvar a imagem contato: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<Id, List<DocumentStatus>> verificarDocumentosEntregues(List<Id> contatoIds) {
        // Cria um mapa para armazenar os resultados
        Map<Id, List<DocumentStatus>> resultado = new Map<Id, List<DocumentStatus>>();
        
        // Consulta para recuperar documentos entregues
        List<Documentacao__c> documentacoes = [
            SELECT Contato__c, Name, Entregue__c, CreatedDate
            FROM Documentacao__c
            WHERE Contato__c IN :contatoIds
        ];
        
        // Preenche o mapa com os documentos entregues
        for (Documentacao__c doc : documentacoes) {
            if (!resultado.containsKey(doc.Contato__c)) {
                resultado.put(doc.Contato__c, new List<DocumentStatus>());
            }
            
            DocumentStatus status = new DocumentStatus();
            status.nomeDoDocumento = doc.Name;
            status.entregue = doc.Entregue__c;
            status.dataEntrega = doc.CreatedDate;
            
            resultado.get(doc.Contato__c).add(status);
        }
        
        return resultado;
    }

    @AuraEnabled
    public static Map<Id , List<DocumentStatus>> verificarDocumentosEntreguesIndividuais(Id contactId){
        Map<Id, List<DocumentStatus>> resultado = new Map<Id, List<DocumentStatus>>();
        
        List<Documentacao__c> documentacoes = [
            SELECT Contato__c, Name, Entregue__c
            FROM Documentacao__c
            WHERE Contato__c = :contactId
        ];


        for (Documentacao__c doc : documentacoes) {
            if (!resultado.containsKey(doc.Contato__c)) {
                resultado.put(doc.Contato__c, new List<DocumentStatus>());
            }

            DocumentStatus status = new DocumentStatus();
            status.nomeDoDocumento = doc.Name;
            status.entregue = doc.Entregue__c;

            resultado.get(doc.Contato__c).add(status);
        }

        return resultado;
    }
    
@AuraEnabled
public static void deletar(Id id) {
   try {
        DocumentacaoHelper.deleteById(id);
    } catch (Exception e) {
        throw new AuraHandledException('Erro ao deletar documento: ' + e.getMessage());
    }
}

    
@AuraEnabled(cacheable=true)
public static Map<String, String> recuperar(Id id) {
    try {
        return DocumentacaoHelper.recoverById(id);
    } catch (Exception e) {
        throw new AuraHandledException('Erro ao recuperar o documento: ' + e.getMessage());
    }
}

@AuraEnabled(cacheable=true)
public static Map<String, String> baixarDocumento(Id id) {
    try {
        return DocumentacaoHelper.recoverById(id);
    } catch (Exception e) {
        throw new AuraHandledException('Erro ao recuperar o documento: ' + e.getMessage());
    }
}

@AuraEnabled(cacheable=true)
public static List<Map<String, Object>> getDeliveredDocumentsByAccountId(String accountId) {
    if (String.isEmpty(accountId)) {
        throw new AuraHandledException('Account ID cannot be null or empty');
    }

    // Obter todas as oportunidades associadas à conta
    List<Opportunity> opportunities = [
        SELECT Id
        FROM Opportunity
        WHERE AccountId = :accountId
    ];

    if (opportunities.isEmpty()) {
        return new List<Map<String, Object>>();
    }

    // Obter todos os contatos associados às oportunidades
    List<OpportunityContactRole> roles = [
        SELECT ContactId
        FROM OpportunityContactRole
        WHERE OpportunityId IN :opportunities
    ];

    if (roles.isEmpty()) {
        return new List<Map<String, Object>>();
    }

    Set<Id> contactIds = new Set<Id>();
    for (OpportunityContactRole role : roles) {
        contactIds.add(role.ContactId);
    }

    // Obter todos os documentos associados aos contatos
    List<Checklist_de_Documentos__c> allDocuments = [
        SELECT Nome_do_Documento__c, IsDelivered__c, Contato__c
        FROM Checklist_de_Documentos__c
        WHERE Contato__c IN :contactIds
    ];

    List<Map<String, Object>> results = new List<Map<String, Object>>();

    for (Checklist_de_Documentos__c doc : allDocuments) {
        Map<String, Object> docData = new Map<String, Object>();
        docData.put('DocumentName', doc.Nome_do_Documento__c);
        docData.put('IsDelivered', doc.IsDelivered__c);
        docData.put('ContactId', doc.Contato__c);
        results.add(docData);
    }

    return results;
}



public class DocumentStatus {
    @AuraEnabled public String nomeDoDocumento { get; set; }
    @AuraEnabled public Boolean entregue { get; set; }
    @AuraEnabled public Datetime dataEntrega { get; set; }
}



    
    public class ContactRoleWrapper {
        @AuraEnabled
        public Id ContactId;
        @AuraEnabled
        public String ContactName;

        @AuraEnabled
        public String Role;

        public ContactRoleWrapper(Id contactId, String contactName , String role) {
            this.ContactId = contactId;
            this.ContactName = contactName;
            this.Role = role;
        }
    }


}