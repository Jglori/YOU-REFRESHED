public class DocumentacaoHelper {
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

    public static List<Documentacao__c> getByAnaliseCredito(Id analiseCreditoId) {
        List<Checklist_de_Documentos__c> cklistDocs = ChecklistHelper.getByAnalisesCredito(new Set<Id>{analiseCreditoId});
        
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
}