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
}