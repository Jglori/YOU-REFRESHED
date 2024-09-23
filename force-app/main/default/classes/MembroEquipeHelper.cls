public class MembroEquipeHelper {
    public static void checkDuplicatedMember(List<MembroEquipe__c> newList){
        Map<Id,MembroEquipe__c> membroUserID = new Map<Id,MembroEquipe__c>();
        for(MembroEquipe__c member : newList){
            membroUserID.put(member.Usuario__c, member);
        }
        
        for(MembroEquipe__c memberBase : MembroEquipeSelector.obterMembrosPorIdsUsuarios(membroUserID.keyset())){
            MembroEquipe__c ableToDuplicated = membroUserID.get(memberBase.Usuario__c);
            if(ableToDuplicated.Equipe__c.equals(memberBase.Equipe__c)){
                ableToDuplicated.addError('Este usuário ja eta presente na equipe.');
            }
        }
    }
}