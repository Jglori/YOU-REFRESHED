global class RoletaCleanUpScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<RoletaLeads__c> roletaList = [
            SELECT Id 
            FROM RoletaLeads__c 
        ];

        for (RoletaLeads__c roleta : roletaList) {
            RoletaLeadsHelper.limparParticipantesRoleta(roleta.Id);
        }
    }
}