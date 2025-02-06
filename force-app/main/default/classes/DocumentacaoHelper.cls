public class DocumentacaoHelper {
    
    public static List<Documentacao__c> getByAnaliseCredito(Id analiseCreditoId) {
        List<Checklist_de_Documentos__c> cklistDocs = ChecklistHelper.getByAnaliseCredito(analiseCreditoId);
        
        List<Documentacao__c> docs = new List<Documentacao__c>();
        for (Checklist_de_Documentos__c cklistDoc : cklistDocs) {
            docs.add(
                new Documentacao__c(
                    Id = cklistDoc.Documenta_o__c,
                    Name = cklistDoc.Documenta_o__r.Name,
                    Validado__c = cklistDoc.Documenta_o__r.Validado__c,
                    Obrigatorio__c = cklistDoc.Documenta_o__r.Obrigatorio__c, 
                    Entregue__c = cklistDoc.Documenta_o__r.Entregue__c
                )
            );
        }

        return docs;
    }  

    public static List<Documentacao__c> validateDocuments(Set<Id> ids) {
        List<Documentacao__c> documents = DocumentacaoDA.getAllById(ids);

        for (Documentacao__c document : documents) {
            document.Validado__c = true;
        }

        try {
            update documents;
        } catch (DMLException e) {
            System.debug('Erro ao atualizar documentos: ' + e.getMessage());
            throw new DMLException('Erro ao atualizar documentos: ' + e.getMessage());
        }

        return documents;
    }

    public static List<Documentacao__c> invalidateDocuments(Set<Id> ids) {
        List<Documentacao__c> documents = DocumentacaoDA.getAllById(ids);
        
        for (Documentacao__c document : documents) {
            document.Validado__c = false;
        }
 
        try {
            update documents;
        } catch (Exception e) {
            System.debug('Erro ao atualizar documentos: ' + e.getMessage());
            throw new DMLException('Erro ao atualizar documentos: '+ e.getMessage());
        }

        return documents;
    }

    public static void criarDocumentacao(String nomeDocumento) {
        // Cria um novo registro de Documentacao__c
        Documentacao__c doc = new Documentacao__c();
        
        // Define os valores dos campos
        doc.Name = nomeDocumento;
        doc.Obrigatorio__c = true;// Define o papel de contato como Fiador
        
        try {
            // Insere o registro no banco de dados
            insert doc;
            System.debug('Documento criado com sucesso: ' + doc.Id);
        } catch (DmlException e) {
            System.debug('Erro ao criar o documento: ' + e.getMessage());
        }
    }

    public static Documentacao__c create(Id contatoId, Id opportunityId, Boolean obrigatorio, String base64, String title, String fileName, String fileType) {
        if (opportunityId == null) throw new IllegalArgumentException('OpportunityId incorreto, não deve ser null.');
        if (obrigatorio == null) throw new IllegalArgumentException('Obrigatório incorreto, não deve ser null.');
        if (base64 == null || base64 == '') throw new IllegalArgumentException('Base64 incorreto, não deve ser null ou vazio.');
        if (title == null || title == '') throw new IllegalArgumentException('Title incorreto, não deve ser null ou vazio.');
        if (fileName == null || fileName == '') throw new IllegalArgumentException('FileName incorreto, não deve ser null ou vazio.');
        if (fileType == null || fileType == '') throw new IllegalArgumentException('FileType incorreto, não deve ser null ou vazio.');
        

        Documento__mdt docMdt = DocumentacaoDA.getMetadasByName(new Set<String>{ title })[0];
        if (docMdt == null) throw new IllegalArgumentException('Documento Metadata não deve ser null.');

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = title;
        contentVersion.PathOnClient = fileType;
        contentVersion.VersionData = EncodingUtil.base64Decode(base64);
        insert contentVersion;

        ContentVersion cv = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contentVersion.Id
        ];

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = cv.ContentDocumentId;
        contentDocumentLink.LinkedEntityId = opportunityId;
        contentDocumentLink.ShareType = 'I'; 
        contentDocumentLink.Visibility = 'AllUsers';
        insert contentDocumentLink;
        
        Documentacao__c documento = new Documentacao__c();
        documento.Contato__c = contatoId;
        documento.Obrigatorio__c = docMdt.Obrigatorio__c;
        documento.Entregue__c = true;
        documento.Name = docMdt.Nome_do_Documento__c;
        documento.ContentDocumentId_c__c = cv.contentDocumentId;
        documento.DataEntrega__c = Date.today(); 
        insert documento;
    
        Checklist_de_Documentos__c checklist = new Checklist_de_Documentos__c();
        checklist.Oportunidade__c = opportunityId;
        checklist.Documenta_o__c = documento.Id;
        insert checklist;

        return documento;
    }

    public static void deleteById(Id id) {
        Documentacao__c doc = DocumentacaoDA.getById(id);
        if (doc == null) throw new IllegalArgumentException('Id inválido. Documento não encontrado.');
    
        if (doc.ContentDocumentId_c__c != null) {
            List<ContentDocument> contentDoc = [
                SELECT Id
                FROM ContentDocument
                WHERE Id = :doc.ContentDocumentId_c__c
            ];
            if (!contentDoc.isEmpty()) delete contentDoc;
    
            List<ContentDocumentLink> contentDocLink = [
                SELECT Id
                FROM ContentDocumentLink
                WHERE ContentDocumentId = :doc.ContentDocumentId_c__c
            ];
            if (!contentDocLink.isEmpty()) delete contentDocLink;
        }
    
        List<Checklist_de_Documentos__c> cklistDocs = [
            SELECT Id, Oportunidade__c
            FROM Checklist_de_Documentos__c
            WHERE Documenta_o__c = :doc.Id
        ];
        if (!cklistDocs.isEmpty()) {
            System.debug(cklistDocs);

            delete cklistDocs;
            ChecklistHelper.updateOpportunityChecklistStatus(new List<Checklist_de_Documentos__c>(cklistDocs));
        }
    
        delete doc;
    }

    public static Map<String, String> recoverById(Id id) {
        System.debug(id);
        Documentacao__c doc = DocumentacaoDA.getById(id);
        System.debug(doc);
        if (doc == null) throw new IllegalArgumentException('Documento não encontrado');

        // Query para obter o ContentVersion mais recente
        ContentVersion version = [
            SELECT Id, VersionData, PathOnClient
            FROM ContentVersion
            WHERE ContentDocumentId = :doc.ContentDocumentId_c__c
            LIMIT 1
        ];

        System.debug(version);

        if (version == null) throw new IllegalArgumentException('Versão mais recente do documento não encontrada.');

        // Obter o Blob da versão mais recente
        Blob fileContent = version.VersionData;
        String base64String = EncodingUtil.base64Encode(fileContent);
        
        // Determinar o tipo MIME baseado no PathOnClient
        String fileName = version.PathOnClient;
        String mimeType = getMimeTypeFromFileName(fileName);
        
        // Retornar o resultado como JSON
        Map<String, String> result = new Map<String, String>();
        if (mimeType != 'application/pdf') {
            result.put('documentUrl', '/sfc/servlet.shepherd/version/download/' + version.Id);
            result.put('base64Data', base64String);
            result.put('mimeType', mimeType);
            result.put('fileName', fileName);
        }

        return result;
    }

    public static List<Documentacao__c> getByOpportunityIdFilteredByRole(Set<Id> opportunitiesId) {
        Set<String> roles = new Set<String>();
        for (OpportunityContactRole ocr : [ 
                SELECT Role FROM OpportunityContactRole WHERE OpportunityId IN :opportunitiesId 
            ]) {
            roles.add(ocr.Role);
        }
        
        Map<String, Documentacao__c> docMap = new Map<String, Documentacao__c>();

        /* Mapea os documentos mtd para as oportunidades */

        for (Checklist_de_Documentos__c cklistDoc : ChecklistDA.getWithDocumentsByOpportunity( opportunitiesId )) {
            docMap.put(
                cklistDoc.Documenta_o__r.Name, 
                new Documentacao__c(
                    Id = cklistDoc.Documenta_o__c,
                    Contato__c = cklistDoc.Documenta_o__r.Contato__c, 
                    Obrigatorio__c = cklistDoc.Documenta_o__r.Obrigatorio__c, 
                    Entregue__c = cklistDoc.Documenta_o__r.Entregue__c,
                    Name = cklistDoc.Documenta_o__r.Name,
                    DataEntrega__c = cklistDoc.Documenta_o__r.DataEntrega__c
                )
            );
        }

        List<Documentacao__c> docs = new List<Documentacao__c>();
        for (Documento__mdt docMdt : DocumentacaoDA.getMetadasByPapers(roles)) {
            if (docMap.get(docMdt.Nome_do_Documento__c) != null) {
                docs.add(docMap.get(docMdt.Nome_do_Documento__c)); 
            } else {
                docs.add(
                    new Documentacao__c( 
                        Name = docMdt.Nome_do_Documento__c, 
                        Obrigatorio__c = docMdt.Obrigatorio__c,
                        Entregue__c = false
                    )
                );
            }
        }

        return docs;
    }

    public static List<Map<String, Object>> getDocumentsFromOppToContactRoles(Id oppId) {
        List<Map<String, Object>> docForEachContact = new List<Map<String, Object>>();
    
        List<OpportunityContactRole> contactRoles = [
            SELECT ContactId, Role, Contact.Name
            FROM OpportunityContactRole
            WHERE OpportunityId = :oppId AND Role != null
        ];

        if(contactRoles.isEmpty()) {
            return null;
        }
    
        for (OpportunityContactRole cr : contactRoles) {
            Map<String, Object> contactData = new Map<String, Object>();
    
            contactData.put('ContactId', cr.ContactId);
            contactData.put('ContactName', cr.Contact.Name);
            contactData.put('Role', cr.Role);
    
            List<Documento__mdt> listOfMtdDocuments = [
                SELECT Nome_do_Documento__c, Obrigatorio__c, Papel__c
                FROM Documento__mdt
                WHERE Papel__c = :cr.Role
            ];
    
            List<Documentacao__c> documents = new List<Documentacao__c>();
    
            for (Documento__mdt docMdt : listOfMtdDocuments) {
                List<Documentacao__c> existingDocs = [
                    SELECT Name, Contato__c, Obrigatorio__c, Entregue__c, DataEntrega__c
                    FROM Documentacao__c
                    WHERE Contato__c = :cr.ContactId AND Name = :docMdt.Nome_do_Documento__c
                    LIMIT 1
                ];
    
                if (existingDocs.isEmpty()) {
                    Documentacao__c newDoc = new Documentacao__c();
                    newDoc.Contato__c = cr.ContactId;
                    newDoc.Name = docMdt.Nome_do_Documento__c;
                    newDoc.Obrigatorio__c = docMdt.Obrigatorio__c;
                    newDoc.Entregue__c = false;
    
                    documents.add(newDoc);
                } else {
                    documents.add(existingDocs[0]);
                }
            }
    
            contactData.put('Documents', documents);
            docForEachContact.add(contactData);
        }
    
        return docForEachContact;
    }
   

    public static List<Documento__mdt> getMetadasByPapers(List<String> papers) {
        if (papers == null || papers.isEmpty()) throw new IllegalArgumentException('Papeis não deve ser null ou vazio.');
        
        Set<String> setPapers = new Set<String>();
        for (String paper : papers) {
            setPapers.add(paper);
        }
        List<Documento__mdt> docsMdt = DocumentacaoDA.getMetadasByPapers(setPapers);
        if (docsMdt.isEmpty()) throw new IllegalArgumentException('Documentos não encontrados.');

        return docsMdt;
    }

    public static List<Documento__mdt> getMetadasByPaper(String paper) {
        if (paper == null || paper == '') throw new IllegalArgumentException('Papel não deve ser null ou vazio.');
        
        List<Documento__mdt> docsMdt = DocumentacaoDA.getMetadasByPapers(new Set<String>{ paper });
        if (docsMdt.isEmpty()) throw new IllegalArgumentException('Documentos não encontrados.');

        return docsMdt;
    }
    

    public static List<Documentacao__c> getByOpportunityId(Set<Id> opportunitiesId) {
        List<Checklist_de_Documentos__c> checklistDocs = ChecklistHelper.getByOpportunityId(opportunitiesId);
        List<Documentacao__c> docs = new List<Documentacao__c>();
        for (Checklist_de_Documentos__c cklistDoc : checklistDocs) {
            docs.add(
                new Documentacao__c(
                    Id = cklistDoc.Documenta_o__c,
                    Name = cklistDoc.Documenta_o__r.Name,
                    Validado__c = cklistDoc.Documenta_o__r.Validado__c,
                    Obrigatorio__c = cklistDoc.Documenta_o__r.Obrigatorio__c, 
                    Entregue__c = cklistDoc.Documenta_o__r.Entregue__c
                )
            );
        }

        return docs;
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
}