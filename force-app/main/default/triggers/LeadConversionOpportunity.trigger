trigger LeadConversionOpportunity on Lead (after update) {
    List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

    for (Lead lead : Trigger.new) {
       
        if (lead.IsConverted && lead.ConvertedOpportunityId != null &&
            lead.IsConverted != Trigger.oldMap.get(lead.Id).IsConverted) {
            
            try {
               
                Opportunity opp = [
                    SELECT Id, StageName
                    FROM Opportunity
                    WHERE Id = :lead.ConvertedOpportunityId
                    LIMIT 1
                ];

              
                if (opp.StageName != 'Negociação') {
                    opp.StageName = 'Negociação'; 
                    opportunitiesToUpdate.add(opp);
                }
            } catch (QueryException e) {
                System.debug('Erro ao buscar a Oportunidade: ' + e.getMessage());
            }
        }
    }

    
    if (!opportunitiesToUpdate.isEmpty()) {
        try {
            update opportunitiesToUpdate;  
        } catch (DmlException e) {
            System.debug('Erro ao atualizar as Oportunidades: ' + e.getMessage());
        }
    }
}