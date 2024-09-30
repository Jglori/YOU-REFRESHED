public class ChecklistDA {
    public static Map<Id, List<Checklist_de_Documentos__c>> getChecklistDocumentsWithDetails(Set<Id> opportunityIds) {
        Map<Id, List<Checklist_de_Documentos__c>> checklistMap = new Map<Id, List<Checklist_de_Documentos__c>>();

        List<Checklist_de_Documentos__c> checklists = [
            SELECT Id, Oportunidade__c, Documenta_o__c,
                   Documenta_o__r.Obrigatorio__c, Documenta_o__r.Entregue__c
            FROM Checklist_de_Documentos__c
            WHERE Oportunidade__c IN :opportunityIds
        ];

        for (Checklist_de_Documentos__c checklist : checklists) {
            if (!checklistMap.containsKey(checklist.Oportunidade__c)) {
                checklistMap.put(checklist.Oportunidade__c, new List<Checklist_de_Documentos__c>());
            }
            checklistMap.get(checklist.Oportunidade__c).add(checklist);
        }

        return checklistMap;
    }
}