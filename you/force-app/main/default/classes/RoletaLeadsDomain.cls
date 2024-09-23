public class RoletaLeadsDomain {
    public static Map<Id, List<RoletaLeads__c>> obterRoletasLeadsPorIdsEquipes(Set<Id> idsMembros) {
        List<RoletaLeads__c> roletasLeads = RoletaLeadsSelector.obterRoletasLeadsPorIdsMembros(idsMembros);

        return obterRoletasLeadsPorIdsEquipes(roletasLeads);
    }

    public static Map<Id, List<RoletaLeads__c>> obterRoletasLeadsPorIdsEquipes(List<RoletaLeads__c> roletasLeads) {
        Map<Id, List<RoletaLeads__c>> roletasLeadsPorIdsEquipes = new Map<Id, List<RoletaLeads__c>>();
        for(RoletaLeads__c roletaLeads : roletasLeads) {
            if(!roletasLeadsPorIdsEquipes.containsKey(roletaLeads.Equipe__c)) {
                roletasLeadsPorIdsEquipes.put(roletaLeads.Equipe__c, new List<RoletaLeads__c>());
            }

            roletasLeadsPorIdsEquipes.get(roletaLeads.Equipe__c).add(roletaLeads);
        }

        return roletasLeadsPorIdsEquipes;
    }

    public static Set<String> obterCanaisAtendimento(List<RoletaLeads__c> roletasLeads) {
        Set<String> canaisAtendimento = new Set<String>();
        for(RoletaLeads__c roletaLeads : roletasLeads) {
            if(String.isBlank(roletaLeads.CanaisAtendimento__c)) { continue; }

            canaisAtendimento.addAll(roletaLeads.CanaisAtendimento__c.split(';'));
        }

        return canaisAtendimento;
    }

    /**
     * Método responsável pela obtenção das roletas de lead recebidas separadas 
     * por canal de atendimento.
     */
    public static Map<String, List<RoletaLeads__c>> obterRoletasLeadsPorCanalAtendimento(List<RoletaLeads__c> roletasLeads) {
        Map<String, List<RoletaLeads__c>> roletasLeadsCanalAtendimento = new Map<String, List<RoletaLeads__c>>();
        for(RoletaLeads__c roletaLeads : roletasLeads) {
            for(String canalAtendimento : obterCanaisAtendimento(roletaLeads.CanaisAtendimento__c)) {
                if(!roletasLeadsCanalAtendimento.containsKey(canalAtendimento)) {
                    roletasLeadsCanalAtendimento.put(canalAtendimento, new List<RoletaLeads__c>());
                }
    
                roletasLeadsCanalAtendimento.get(canalAtendimento).add(roletaLeads);
            }
        }

        return roletasLeadsCanalAtendimento;
    }

    public static List<String> obterCanaisAtendimento(String canaisAtendimento) {
        return String.isBlank(canaisAtendimento) ? new List<String>() : canaisAtendimento.split(';');
    }
}