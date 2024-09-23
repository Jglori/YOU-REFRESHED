public class SorteioDomain {
    public static Set<Id> obterIdsRoletas(List<Sorteio__c> sorteios) {
        Set<Id> idsRoletas = new Set<Id>();
        for(Sorteio__c sorteio : sorteios) {
            if (sorteio.RoletaLeads__c != null) { 
                idsRoletas.add(sorteio.RoletaLeads__c);
            }
        }

        return idsRoletas;
    }
}