public with sharing class ContractController {
    
    @AuraEnabled(cacheable=true)
    public static Contract infoContrato(String oppId){
        if(!String.isEmpty(oppId) || oppId != null){
            Contract ctt = ContractSelector.getContract(oppId);
            return ctt != null ? ctt : new Contract();
        }else{
            return new Contract();
        }
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