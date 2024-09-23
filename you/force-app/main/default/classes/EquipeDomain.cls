public class EquipeDomain {
    public static Set<Id> obterIdsEquipes(List<MembroEquipe__c> membrosEquipes) {
        Set<Id> idsEquipes = new Set<Id>();
        for(MembroEquipe__c membroEquipe : membrosEquipes) {
            idsEquipes.add(membroEquipe.Equipe__c);
        }

        return idsEquipes;
    }
}