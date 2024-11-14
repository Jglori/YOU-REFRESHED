public class ChecklistDA {
    
    public static List<Checklist_de_Documentos__c> getWithDocumentsByOpportunity(Set<Id> opportunityIds) {
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            return new List<Checklist_de_Documentos__c>();
        }

        return [
            SELECT Id, Oportunidade__c, Documenta_o__c, 
                Documenta_o__r.Obrigatorio__c, 
                Documenta_o__r.Entregue__c,
                Documenta_o__r.Validado__c,
                Documenta_o__r.Name
            FROM Checklist_de_Documentos__c
            WHERE Oportunidade__c IN :opportunityIds
        ];
    }

    public static Map<Id, List<Checklist_de_Documentos__c>> getChecklistDocumentsWithDetails(Set<Id> opportunityIds) {
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            return new Map<Id, List<Checklist_de_Documentos__c>>();
        }

        List<Checklist_de_Documentos__c> checklists = [
            SELECT Id, Oportunidade__c, Documenta_o__c,
                   Documenta_o__r.Obrigatorio__c, Documenta_o__r.Entregue__c,
                   Documenta_o__r.Name
            FROM Checklist_de_Documentos__c
            WHERE Oportunidade__c IN :opportunityIds
        ];
        
        Map<Id, List<Checklist_de_Documentos__c>> checklistMap = new Map<Id, List<Checklist_de_Documentos__c>>();
        
        for (Checklist_de_Documentos__c checklist : checklists) {
            if (!checklistMap.containsKey(checklist.Oportunidade__c)) {
                checklistMap.put(checklist.Oportunidade__c, new List<Checklist_de_Documentos__c>());
            }
            checklistMap.get(checklist.Oportunidade__c).add(checklist);
        }

        return checklistMap;
    }

   public static List<Documento__mdt> getRequiredDocumentsByPapeis(List<String> papeis) {
    if (papeis == null || papeis.isEmpty()) {
        return new List<Documento__mdt>();
    }

    return [
        SELECT Id, Nome_do_Documento__c, Papel__c, Obrigatorio__c
        FROM Documento__mdt 
        WHERE (Obrigatorio__c = true OR Obrigatorio__c = false)
              AND Papel__c IN :papeis
    ];
   }
}