public with sharing class ContractController {

    @AuraEnabled(cacheable=true)
    public static List<Contract> getByOpportunityId(Id oppId){
        try {
            return ContractHelper.getByOpportunityId(oppId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Contract infoContrato(String oppId){
        // Contract ctt = ContractSelector.getContract(oppId);
        Contract ctt = new Contract();
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
    public static Contract create(Map<String, Object> data){
        try {
            return ContractHelper.create(data);
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ContentDocumentLink obterPDFContrato(String oppId){
        List<ContentDocumentLink> content = [SELECT ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :oppId AND ContentDocument.Title LIKE 'Contrato%' LIMIT 1];
        if (content == null || content.isEmpty()) {
            return null;
        }
        return content[0];
    }
}