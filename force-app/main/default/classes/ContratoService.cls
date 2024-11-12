public class ContratoService {
    public static String contratoText(Opportunity opp, TemplateDocumento__c template) {
        String text = template.ConteudoTemplate__c;

        Empreendimento__c emp = EmpreendimentoSelector.getEmpreendimentoById(opp.Empreendimento__c);
        Account conta = (Account) QueryHelper.selectAllFields('Account', opp.AccountId);
        Product2 prd = (Product2) QueryHelper.selectAllFields('Product2', opp.Unidade__c);
        Bloco__c bloco = (Bloco__c) QueryHelper.selectAllFields('Bloco__c', prd.Bloco__c);
        List<OpportunityContactRole> roles = [SELECT Id, ContactId, Role, Contact.Name FROM OpportunityContactRole WHERE OpportunityId = :opp.Id];

        Map<String, SObject> sObjectsMap = new Map<String, SObject>{
            'Opportunity.' => opp,
            'Empreendimento__r.' => emp,
            'Account.' => conta,
            'Bloco__r.' => bloco,
            'Product2.' => prd
        };

        Map<String, Map<String, Schema.SObjectField>> tagFields = new Map<String, Map<String, Schema.SObjectField>>{
            'Opportunity.' => Schema.SObjectType.Opportunity.fields.getMap(),
            'Empreendimento__r.' => Schema.SObjectType.Empreendimento__c.fields.getMap(),
            'Account.' => Schema.SObjectType.Account.fields.getMap(),
            'Bloco__r.' => Schema.SObjectType.Bloco__c.fields.getMap(),
            'Product2.' => Schema.SObjectType.Product2.fields.getMap()
        };

        for (String tagPrefix : tagFields.keySet()) {
            Map<String, Schema.SObjectField> fieldsMap = tagFields.get(tagPrefix);
            SObject relatedSObject = sObjectsMap.get(tagPrefix); 

            if (relatedSObject != null) {
                for (String fieldName : fieldsMap.keySet()) {
                    String apiName = fieldsMap.get(fieldName).getDescribe().getName();
                    String fullTag = tagPrefix + apiName;

                    if (text.contains(fullTag)) {
                        String fieldValue = relatedSObject.get(apiName) == null ? 'N/A' : String.valueOf(relatedSObject.get(apiName));
                        text = text.replace(fullTag, fieldValue);
                    }
                }
            }
        }

        Map<String, Schema.SObjectField> opportunityContactRoleFieldsMap = Schema.SObjectType.OpportunityContactRole.fields.getMap();

        if (text.contains('OpportunityContactRole.Role')) {
            List<String> signatariosList = new List<String>();

            for (OpportunityContactRole role : roles) {
                for (String fieldName : opportunityContactRoleFieldsMap.keySet()) {
                    String apiName = opportunityContactRoleFieldsMap.get(fieldName).getDescribe().getName();
                    String fullTag = 'OpportunityContactRole.' + apiName;

                    if (text.contains(fullTag)) {
                        if (apiName == 'Role' || apiName == 'Contact.Name') {
                            String fieldValue = role.get(apiName) == null ? 'N/A' : String.valueOf(role.get(apiName));
                            signatariosList.add(role.Contact.Name + ' - ' + role.Role);
                        }
                    }
                }
            }

            String signatariosText = String.join(signatariosList, ', ');

            text = text.replace('OpportunityContactRole.Role', signatariosText);
        }

        return text;
    }

    public static void atualizarPrazoAssinatura(List<Contract> contratos) {
        List<Contract> contratosToUpdate = new List<Contract>();
        Date diaAtual = Date.today();

        for (Contract contrato : contratos) {
            if (contrato.Status == 'Em Assinatura') {
                diaAtual = diaAtual.addDays(5);
                contrato.PrazoAssinatura__c = diaAtual;
                contratosToUpdate.add(contrato);
            }
        }

        if (!contratosToUpdate.isEmpty()) {
            update contratosToUpdate;
        }
    }

    public static void evitarGeracaoMultipla(List<Contract> contracts) {
        Set<Id> oppIds = new Set<Id>();
    
        for (Contract ctt : contracts) {
            oppIds.add(ctt.Oportunidade__c);
        }
    
        Map<Id, Integer> oppContratoCount = new Map<Id, Integer>();
        List<Contract> contratosExistentes = [
            SELECT Id, Oportunidade__c
            FROM Contract 
            WHERE Oportunidade__c IN :oppIds AND Status = 'Contrato Gerado'
        ];
    
        for (Contract cttExistente : contratosExistentes) {
            if (oppContratoCount.containsKey(cttExistente.Oportunidade__c)) {
                oppContratoCount.put(cttExistente.Oportunidade__c, oppContratoCount.get(cttExistente.Oportunidade__c) + 1);
            } else {
                oppContratoCount.put(cttExistente.Oportunidade__c, 1);
            }
        }
    
        for (Contract ctt : contracts) {
            if (ctt.Status == 'Contrato Gerado') {
                Integer count = oppContratoCount.get(ctt.Oportunidade__c);
                if (count != null && count >= 1) {
                    ctt.addError('Já existe um contrato gerado para oportunidade deste contrato');
                }
            }
        }
        
    }
    
  
    public static void verificaPrazoAssinatura(List<Contract> contracts){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<FeedItem> chatterPosts = new List<FeedItem>();

        for(Contract ctt : contracts){
            List<OpportunityContactRole> roles = ContractSelector.getRolesContatoOpp(ctt.Oportunidade__c);

            if(ctt.PrazoAssinatura__c < Date.today() && ctt.Status == 'Em Assinatura'){
                
                for(OpportunityContactRole role : roles){
                    Contact cttRole = role.Contact;
                    if (cttRole.Email != null) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new String[] { cttRole.Email });
                        mail.setSubject('Prazo de Assinatura Expirado! ');
                        mail.setPlainTextBody('O prazo de assinatura para o contrato foi expirado. Favor procurar um responsável.');
                        emails.add(mail);
                    }
                }

                FeedItem post = new FeedItem();
                post.ParentId = ctt.Oportunidade__c;
                post.Body = 'O prazo de assinatura para o contrato expirou. Favor verificar com o responsável.';
                chatterPosts.add(post);
            }
        }

        Messaging.sendEmail(emails);
        insert chatterPosts;
    }
  
}