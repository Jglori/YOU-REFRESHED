public with sharing class LeadVencidoSchedule {
    public static void execute(SchedulableContext ctx){
        List<Lead> leads = [SELECT Id, 
        ConfiguracaoDeSLA__r.Fase__c, 
        ConfiguracaoDeSLA__r.motivoDaPerda__c, 
        ConfiguracaoDeSLA__r.FaseParaRedirecionamentoDoLead__c, 
        ConfiguracaoDeSLA__r.FilaParaRedirecionamentoDoLead__c,
        OwnerId
        FROM Lead 
        WHERE Vencido__c = true];

        Map<String, Id> filaNameToIdMap = new Map<String, Id>();
        for (Lead lead : leads) {
            filaNameToIdMap.put(lead.ConfiguracaoDeSLA__r.FilaParaRedirecionamentoDoLead__c, null);
        }

        for (Group fila : [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name IN :filaNameToIdMap.keySet()]) {
            filaNameToIdMap.put(fila.Name, fila.Id);
        }

        for (Lead lead : leads) {
            if (filaNameToIdMap.containsKey(lead.ConfiguracaoDeSLA__r.FilaParaRedirecionamentoDoLead__c)) {
                lead.OwnerId = filaNameToIdMap.get(lead.ConfiguracaoDeSLA__r.FilaParaRedirecionamentoDoLead__c);
            }
        }

        for (Lead lead : leads) {
            lead.Status = lead.ConfiguracaoDeSLA__r.Fase__c;
            lead.MotivoNaoQualificacao__c = lead.ConfiguracaoDeSLA__r.motivoDaPerda__c;
        }

        update leads;
    }
}