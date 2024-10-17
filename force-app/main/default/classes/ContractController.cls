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

    @AuraEnabled(cacheable=true)
    public static String retornarContratoGerado(String oppId, String templateId){
        Opportunity opp = (Opportunity) QueryHelper.selectAllFields('Opportunity', oppId);
        TemplateDocumento__c template = TemplateSelector.getTemplateById(templateId);
        String contratoGerado;

        if(opp != null || template != null){
            contratoGerado = ContratoService.contratoText(opp, template);
            return contratoGerado;
        }

        return contratoGerado != null ? contratoGerado : 'N/A';
    }
}