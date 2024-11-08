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
    public static String retornarPapeisDeContato(Id oportunityId){
        List<OpportunityContactRole> roles = [SELECT ContactId, Contact.Name , Role
                                              FROM OpportunityContactRole 
                                              WHERE OpportunityId = :oportunityId];
        
        // Criar uma lista para armazenar apenas os IDs e os Nomes
        List<Map<String, String>> contactDetails = new List<Map<String, String>>();
        
        // Preencher a lista com os dados necessários
        for(OpportunityContactRole role : roles) {
            Map<String, String> contact = new Map<String, String>();
            contact.put('ContactId', role.ContactId);
            contact.put('ContactName', role.Contact.Name);
            contact.put('Role', role.Role);
            contactDetails.add(contact);
        }
        
        return JSON.serialize(contactDetails);
    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunityContactRole> getContactRoles(String contactId) {
        if (String.isEmpty(contactId)) {
            throw new IllegalArgumentException('ContactId não pode ser nulo ou vazio.');
        }
        
        // Realiza a consulta SOQL
        List<OpportunityContactRole> roles = [SELECT Role
                                              FROM OpportunityContactRole
                                              WHERE ContactId = :contactId
                                              LIMIT 200];
        
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
            List<Documento__mdt> documentos = [
                SELECT Nome_do_Documento__c, Obrigatorio__c, Papel__c
                FROM Documento__mdt 
                WHERE Papel__c IN :papeis
            ];
            
            System.debug('Documentos encontrados: ' + documentos);
            return documentos;
        } catch (Exception e) {
            System.debug('Erro na consulta de documentos: ' + e.getMessage());
            throw new AuraHandledException('Erro ao buscar documentos: ' + e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Documento__mdt> getDocumentosPorPapel(String papel) {
        try {
            List<Documento__mdt> documentos = [
                SELECT Nome_do_Documento__c, Obrigatorio__c, Papel__c
                FROM Documento__mdt 
                WHERE Papel__c = :papel
            ];
            
            System.debug('Documentos encontrados: ' + documentos);
            return documentos;
        } catch (Exception e) {
            System.debug('Erro na consulta de documentos: ' + e.getMessage());
            throw new AuraHandledException('Erro ao buscar documentos: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void salvarImagem(String contatoId, String opportunityId, Boolean obrigatorio, String fileName, String base64Data , String tipoDocumento) {
        try {
            // Criar a versão do conteúdo
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = tipoDocumento;
            contentVersion.VersionData = EncodingUtil.base64Decode(base64Data);
            insert contentVersion;

            System.debug('Contact ID: ' + contatoId);
            System.debug('Opportunity ID: ' + opportunityId);
            System.debug('Obrigatório: ' + obrigatorio);
            System.debug('Nome do Arquivo: ' + fileName);
            System.debug('Base64 Data: ' + base64Data);
            System.debug('Tipo de Documento: ' + tipoDocumento);
        
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
        
            // Criar o registro de Checklist_de_Documentos__c
            Checklist_de_Documentos__c checklist = new Checklist_de_Documentos__c();
            checklist.Oportunidade__c = opportunityId;
            checklist.Contato__c = contatoId;
            checklist.Documenta_o__c = documento.Id;
            insert checklist;
        
            System.debug('Imagem salva com sucesso');
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
            throw new AuraHandledException('Erro ao salvar a imagem: ' + e.getMessage());
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
    // @AuraEnabled
    // public static Map<String, List<DocumentStatus>> verificarDocumentosEntreguesIndividuais(Id contatoId) {
    //     // Mapa para armazenar os resultados
    //     Map<String, List<DocumentStatus>> statusMap = new Map<String, List<DocumentStatus>>();
        
    //     // Consulta para obter os registros de Documentacao__c associados ao contato
    //     List<Documentacao__c> documentRecords = [
    //         SELECT Name, Obrigatorio__c, Entregue__c
    //         FROM Documentacao__c
    //         WHERE Contato__c = :contatoId
    //     ];
        
    //     // Mapa para armazenar os resultados e filtrar documentos repetidos
    //     Map<String, DocumentStatus> tempMap = new Map<String, DocumentStatus>();
        
    //     // Itera sobre os registros encontrados
    //     for (Documentacao__c record : documentRecords) {
    //         DocumentStatus status = new DocumentStatus(
    //             record.Name,
    //             record.Obrigatorio__c,
    //             record.Entregue__c
    //         );
            
    //         // Adiciona ou atualiza o status do documento no mapa
    //         tempMap.put(record.Name, status);
    //     }
        
    //     // Preenche o statusMap com o resultado, convertendo o mapa interno para uma lista
    //     statusMap.put(String.valueOf(contatoId), new List<DocumentStatus>(tempMap.values()));
        
    //     return statusMap;
    // }
    
    

    // @AuraEnabled
    // public static Map<String, List<DocumentStatus>> verificarDocumentosEntreguesIndividuais(Id contatoId) {
    //     // Mapa para armazenar os resultados
    //     Map<String, List<DocumentStatus>> statusMap = new Map<String, List<DocumentStatus>>();
        
    //     // Consulta para obter os registros de Checklist_de_Documentos__c associados ao contato
    //     List<Checklist_de_Documentos__c> checklistRecords = [
    //         SELECT Contato__c, Nome_do_Documento__c, IsDelivered__c
    //         FROM Checklist_de_Documentos__c
    //         WHERE Contato__c = :contatoId
    //     ];
        
    //     // Mapa para armazenar os resultados e filtrar documentos repetidos
    //     Map<String, DocumentStatus> tempMap = new Map<String, DocumentStatus>();
        
    //     // Itera sobre os registros encontrados
    //     for (Checklist_de_Documentos__c record : checklistRecords) {
    //         DocumentStatus status = new DocumentStatus();
    //         status.documentName = record.Nome_do_Documento__c;
    //         status.isDelivered = record.IsDelivered__c;
            
    //         // Adiciona ou atualiza o status do documento no mapa
    //         tempMap.put(record.Nome_do_Documento__c, status);
    //     }
        
    //     // Preenche o statusMap com o resultado, convertendo o mapa interno para uma lista
    //     statusMap.put(String.valueOf(contatoId), new List<DocumentStatus>(tempMap.values()));
        
    //     return statusMap;
    // }
    
@AuraEnabled
public static void deletarDocumento(String contatoId, String fileName) {
   try {
        // Depuração: inicio da operação
        System.debug('Iniciando atualização do documento. ContatoId: ' + contatoId + ', Nome do Documento: ' + fileName);

        // Localiza os registros de Documentacao__c
        List<Documentacao__c> documentacoesToUpdate = [
            SELECT Id, Entregue__c
            FROM Documentacao__c
            WHERE Contato__c = :contatoId
            AND Name = :fileName
        ];
        
        // Depuração: documentos a serem atualizados na tabela Documentacao__c
        System.debug('Documentos a serem atualizados na tabela Documentacao__c: ' + documentacoesToUpdate);

        // Verifica se encontrou registros
        if (!documentacoesToUpdate.isEmpty()) {
            // Atualiza o campo Entregue__c para false
            for (Documentacao__c doc : documentacoesToUpdate) {
                doc.Entregue__c = false;
            }
            update documentacoesToUpdate;
            
            System.debug('Atualização do documento concluída com sucesso.');
        } else {
            throw new AuraHandledException('Documento não encontrado na tabela Documentacao__c.');
        }
    } catch (Exception e) {
        // Depuração: capturando exceção
        System.debug('Erro ao atualizar documento: ' + e.getMessage());
        throw new AuraHandledException('Erro ao atualizar documento: ' + e.getMessage());
    }
}

    
@AuraEnabled(cacheable=true)
public static String recuperar(String contactId, String nomeDocumento) {
    try {
        // Query para encontrar o ContentDocumentId baseado no contato e nome do documento
        List<Checklist_de_Documentos__c> checklistDocs = [
            SELECT Documenta_o__r.ContentDocumentId_c__c
            FROM Checklist_de_Documentos__c
            WHERE Contato__c = :contactId
            AND Documenta_o__r.Name = :nomeDocumento AND Documenta_o__r.Entregue__c = true
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        if (checklistDocs.isEmpty()) {
            return JSON.serialize(new Map<String, String>{'message' => 'Documento não encontrado.'});
        }

        // Obter o ContentDocumentId
        String contentDocumentId = checklistDocs[0].Documenta_o__r.ContentDocumentId_c__c;
        
        // Query para obter o ContentVersion mais recente
        List<ContentVersion> versions = [
            SELECT Id, VersionData, PathOnClient
            FROM ContentVersion
            WHERE ContentDocumentId = :contentDocumentId
            AND IsLatest = true
            LIMIT 1
        ];
        
        if (versions.isEmpty()) {
            return JSON.serialize(new Map<String, String>{'message' => 'Versão mais recente do documento não encontrada.'});
        }

        // Obter o Blob da versão mais recente
        Blob fileContent = versions[0].VersionData;
        String base64String = EncodingUtil.base64Encode(fileContent);
        
        // Determinar o tipo MIME baseado no PathOnClient
        String fileName = versions[0].PathOnClient;
        String mimeType = getMimeTypeFromFileName(fileName);
        
        // Retornar o resultado como JSON
        Map<String, String> result = new Map<String, String>();
        if (mimeType == 'application/pdf') {
            result.put('message', 'Não é possível visualizar documentos PDF.');
        } else {
            result.put('documentUrl', '/sfc/servlet.shepherd/version/download/' + versions[0].Id);
            result.put('mimeType', mimeType);
        }
        
        return JSON.serialize(result);

    } catch (Exception e) {
        throw new AuraHandledException('Erro ao recuperar o documento: ' + e.getMessage());
    }
}
@AuraEnabled(cacheable=true)
public static String baixarDocumento(String contactId, String nomeDocumento) {
    try {
        // Query para encontrar o ContentDocumentId baseado no contato e nome do documento
        List<Checklist_de_Documentos__c> checklistDocs = [
            SELECT Documenta_o__r.ContentDocumentId_c__c
            FROM Checklist_de_Documentos__c
            WHERE Contato__c = :contactId
            AND Documenta_o__r.Name = :nomeDocumento AND Documenta_o__r.Entregue__c = true
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (checklistDocs.isEmpty()) {
            throw new AuraHandledException('Documento não encontrado.');
        }

        // Obter o ContentDocumentId
        String contentDocumentId = checklistDocs[0].Documenta_o__r.ContentDocumentId_c__c;

        // Query para obter o ContentVersion mais recente
        List<ContentVersion> versions = [
            SELECT Id, VersionData, PathOnClient
            FROM ContentVersion
            WHERE ContentDocumentId = :contentDocumentId
            AND IsLatest = true
            LIMIT 1
        ];

        if (versions.isEmpty()) {
            throw new AuraHandledException('Versão mais recente do documento não encontrada.');
        }

        // Obter o Blob da versão mais recente
        Blob fileContent = versions[0].VersionData;
        String base64String = EncodingUtil.base64Encode(fileContent);
        
        // Determinar o tipo MIME baseado na extensão do arquivo
        String fileName = versions[0].PathOnClient;

        System.debug('File Name: ' + fileName);
        String mimeType = getMimeTypeFromFileName(fileName);    
        
        System.debug('MIME Type: ' + mimeType);
        // Criar um objeto JSON para retornar a string base64 e o tipo MIME
        Map<String, String> result = new Map<String, String>();
        result.put('base64Data', base64String);
        result.put('mimeType', mimeType);
        result.put('fileName', fileName); // Inclua o nome do arquivo no retorno
        
        return JSON.serialize(result);

    } catch (Exception e) {
        throw new AuraHandledException('Erro ao recuperar o documento: ' + e.getMessage());
    }
}

private static String getMimeTypeFromFileName(String fileName) {
    if (fileName == 'image/png') {
        return 'image/png';
    } 
    if (fileName == 'image/jpeg') {
        return 'image/jpeg';
    }
    if (fileName == 'application/pdf') {
        return 'image/pdf';
    } else {
        return 'application/octet-stream';
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