public with sharing class ContractController {
    
    @AuraEnabled(cacheable=true)
    public static Contract infoContrato(String oppId){
        Contract ctt = ContractSelector.getContract(oppId);
        return ctt;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<OpportunityContactRole> rolesContatoOpp(String oppId){
        if(!String.isEmpty(oppId) || oppId != null){
            List<OpportunityContactRole> roles = ContractSelector.getRolesContatoOpp(oppId);
            return !roles.isEmpty() ? roles : new List<OpportunityContactRole>();
        }else{
            return new List<OpportunityContactRole>();
        }
    }
    
    @AuraEnabled
    public static void assinarContrato(String oppId){
        String subject;
        String body;

        try {
            Contract ctt = ContractSelector.getContract(oppId);
            
            if(ctt != null){
                ctt.Status = 'Ativo';
                ctt.CustomerSignedDate = Date.today();
                
                if(ctt.CustomerSignedDate < ctt.PrazoAssinatura__c){
                    subject = 'Seu contrato está ativo';
                    body = 'O contrato foi assinado dentro do prazo.';
                }else{
                    subject = 'Contrato assinado fora do prazo';
                    body = 'O contrato foi assinado fora do prazo.';
                }
                
                List<OpportunityContactRole> contactRoles = ContractSelector.getRolesContatoOpp(oppId);
                
                for(OpportunityContactRole role : contactRoles){
                    Contact cttRole = role.Contact;
                    if (cttRole.Email != null) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new String[] { cttRole.Email });
                        mail.setSubject(subject);
                        mail.setPlainTextBody(body);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    }
                    
                    FeedItem feedItem = new FeedItem();
                    feedItem.ParentId = oppId;
                    feedItem.Body = body;
                    insert feedItem;
                }
                
                update ctt;
            }else{
                throw new AuraHandledException('Contrato não encontrado');
            }
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao assinar contrato');
        }
        
    }
    
    @AuraEnabled
    public static ContentVersion retornarContratoGerado(String oppId, String templateId){
        if(oppId != null || templateId != null){
            Contract ctt = ContractSelector.getContract(oppId);
            ctt.Status = 'Contrato Gerado';
            update ctt;
            
            PageReference pageRef = Page.ContratoPDF;
            pageRef.getParameters().put('oppId', oppId);
            pageRef.getParameters().put('templateId', templateId);
            
            ContentVersion contVersion = new ContentVersion();
            contVersion.ContentLocation = 'S';
            contVersion.Title = 'Contrato'+ DateTime.now().format(' dd/MM/yyyy - HH:mm:ss');
            contVersion.PathOnClient = 'Contrato' + Datetime.now().format(' dd/MM/yyyy - HH:mm:ss') + '.pdf';
            contVersion.VersionData = (!Test.isRunningTest()) ? pageRef.getContentAsPDF() : Blob.valueOf('TEST');
            insert contVersion;
            
            ContentVersion contentVersion_1 = [SELECT Id,  ContentDocumentId, Title FROM ContentVersion WHERE Id = :contVersion.Id LIMIT 1];
            ContentDocumentLink contDocumentLink = new ContentDocumentLink();
            contDocumentLink.ContentDocumentId = contentVersion_1.ContentDocumentId;
            contDocumentLink.LinkedEntityId = oppId;
            contDocumentLink.shareType = 'V';
            insert contDocumentLink;
            
            return contentVersion_1;
            
        }
        
        return null;
        
    }
    
    @AuraEnabled
    public static ContentDocumentLink obterPDFContrato(String oppId){
        ContentDocumentLink content = [SELECT ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :oppId AND ContentDocument.Title LIKE 'Contrato %' LIMIT 1];
        
        return content != null ? content : null;
    }
}