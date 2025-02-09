public with sharing class ContractHelper {

    public static Contract create(Map<String, Object> data) {
        String status = (String) data.get('status');
        Date dataInicioContrato = Date.valueOf((String) data.get('dataInicioContrato'));
        Date dataEnvioAssinatura = Date.valueOf((String) data.get('dataEnvioParaAssinatura'));
        Date dataAssinaturaClienteDocuSign = Date.valueOf((String) data.get('dataAssinaturaCliente'));
        Map<String, String> contaMap = (Map<String, String>) JSON.deserialize(JSON.serialize(data.get('conta')), Map<String, String>.class);
        Id templateId = (Id) data.get('template');
        List<Map<String, String>> contactsMaps = (List<Map<String, String>>) JSON.deserialize(JSON.serialize(data.get('signatarios')), List<Map<String, String>>.class);
        Id oppId = (Id) data.get('oportunidade');

        try {
            Contract ctr = new Contract(
                Status = 'Rascunho',
                DataInicioContrato__c = dataInicioContrato,
                Name = contaMap.get('Name'), // Contrato está com o nome da conta
                DataEnvioAssinatura__c = dataEnvioAssinatura,
                DataAssinaturaClienteDocuSign__c = dataAssinaturaClienteDocuSign,
                Template__c = templateId,
                AccountId = contaMap.get('Id'),
                Oportunidade__c = oppId
            );
            insert ctr;
            ctr.Status = 'ContratoGerado';
            update ctr;

            List<ContractContactRole> ccrs = new List<ContractContactRole>();
            for (Map<String, String> contactMap : contactsMaps) {
                ccrs.add(
                    new ContractContactRole(
                        ContactId = contactMap.get('value'),
                        ContractId = ctr.Id,
                        Role = contactMap.get('role')
                    )
                );
            }
            insert ccrs;
            
            PageReference pageRef = Page.ContratoPDF;
            pageRef.getParameters().put('oppId', oppId);
            pageRef.getParameters().put('templateId', templateId);

            String ctrName = 'Contract: '+ ctr.Id;
            ContentVersion contVersion = new ContentVersion();
            contVersion.ContentLocation = 'S'; // Indíca que será armazenado diretamente no Salesforce 
            contVersion.Title = ctrName;
            contVersion.PathOnClient = ctrName + '.pdf';
            contVersion.VersionData = Test.isRunningTest() ? Blob.valueOf('Contract') : pageRef.getContentAsPDF();
            insert contVersion;

            ContentVersion contentVersion_1 = [SELECT Id,  ContentDocumentId, Title FROM ContentVersion WHERE Id = :contVersion.Id LIMIT 1];
            ContentDocumentLink contDocumentLink = new ContentDocumentLink();
            contDocumentLink.ContentDocumentId = contentVersion_1.ContentDocumentId;
            contDocumentLink.LinkedEntityId = ctr.Id;
            contDocumentLink.shareType = 'V';
            insert contDocumentLink;

            return ctr;
        } catch (Exception e) {
            System.debug('Erro na criação do contrato: '+ e.getMessage());
            throw new AuraHandledException('Erro na criação do contrato: '+ e.getMessage());
        }
    }

    public static void deleteById(Id id) {
        Contract ctr = [
            SELECT Id FROM Contract WHERE Id = :id
        ];
        List<ContractContactRole> ccrs = [
            SELECT Id FROM ContractContactRole WHERE ContractId = :id
        ];

        String title = 'Contract: ' + id;
        ContentVersion cv = [
            SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = :title
        ];

        ContentDocument cd = [
            SELECT Id FROM ContentDocument WHERE Id = :cv.ContentDocumentId
        ];

        ContentDocumentLink cdl = [
            SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :cv.ContentDocumentId AND LinkedEntityId = :id
        ];

        delete ctr;
        // delete ccrs;
        delete cd;
        // delete cdl;
    }

    public static List<Contract> getByOpportunityId(Id oppId) {
        if (oppId == null) return null;
        
        List<Contract> ctrs = ContractSelector.getByOpportunityId(oppId);
        if (ctrs == null || ctrs.isEmpty()) return null;

        return ctrs;
    }

    public static void sendNotification(List<Contract> ctrs) {
        if (ctrs == null || ctrs.isEmpty()) {
            throw new IllegalArgumentException('A lista de Contrato não deve ser nula ou vazia.');
        }
            
        Set<Id> ctrIds = new Set<Id>();
        for (Contract ctr : ctrs) {
            ctrIds.add(ctr.Id);
        }
        
        Map<Id, List<Contact>> ccMap = new Map<Id, List<Contact>>();
        for (ContractContactRole ccr : [SELECT Contact.Id, Contact.Email, ContractId FROM ContractContactRole WHERE ContractId IN :ctrIds]) {
            Id ctrId = ccr.ContractId;
            
            if (!ccMap.containsKey(ctrId)) {
                ccMap.put(ctrId, new List<Contact>());
            }
            ccMap.get(ctrId).add(
                new Contact(Id = ccr.Contact.Id, Email = ccr.Contact.Email)
            );
        }
        if (ccMap.isEmpty()) return; 
        
        List<FeedItem> feeds = new List<FeedItem>();
        String message = 'O contrato foi assinado dentro do prazo estipulado.';
        
        for (Contract ctr : ctrs ) {

            for (Contact ctt : ccMap.get(ctr.Id)) {
                if (ctt.Id == null) throw new IllegalArgumentException('Id do Contato não deve ser null.');
                if (ctt.Email == null) throw new IllegalArgumentException('Email do Contato não deve ser null.');

                feeds.add(
                    new FeedItem(
                        ParentId = ctt.Id, 
                        Body = message
                    )
                );
                EmailManager.sendMail(ctt.Email, 'Assinatura do Contrato', message);
            }
        }

        if (!feeds.isEmpty()) {
            insert feeds;            
        } 
    }

}