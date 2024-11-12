public with sharing class ChecklistController {
    @AuraEnabled(cacheable=true)
    public static List<String> getDistinctContactRoles() {
        // Usar AggregateResult para realizar a consulta corretamente
        List<AggregateResult> groupedResults = [
            SELECT Role FROM OpportunityContactRole GROUP BY Role
        ];
        
        List<String> distinctRoles = new List<String>();
        for (AggregateResult ar : groupedResults) {
            distinctRoles.add((String)ar.get('Role'));
        }
        
        return distinctRoles;
    }
}