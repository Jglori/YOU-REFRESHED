public class OpportunityProductsHelper {
    public static void validateOpportunityLineItemsForDelete(Map<Id, OpportunityLineItem> oldItems) {
      
        if (oldItems == null || oldItems.isEmpty()) {
            return;
        }

      
        Set<Id> opportunityIds = new Set<Id>();
        for (OpportunityLineItem item : oldItems.values()) {
            opportunityIds.add(item.OpportunityId);
        }

        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>(
            [SELECT Id FROM Opportunity WHERE Id IN :opportunityIds]
        );

        
        for (OpportunityLineItem item : oldItems.values()) {
            Opportunity opp = opportunities.get(item.OpportunityId);

            if (opp != null) {
               
                item.addError('Não é permitido excluir produtos diretamente na oportunidade.');
            }
        }
    }
}