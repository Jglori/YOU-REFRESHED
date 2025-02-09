public class ChecklistHelper {

    public static void updateOpportunityChecklistStatus(List<Checklist_de_Documentos__c> checklists) {
        if (checklists == null || checklists.isEmpty()) {
            return;
        }

        Set<Id> opportunityIds = new Set<Id>();
        for (Checklist_de_Documentos__c checklist : checklists) {
            if (checklist.Oportunidade__c != null) {
                opportunityIds.add(checklist.Oportunidade__c);
            }
        }
    
        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>(
            [SELECT Id, StageName, FarolChecklistDocumento__c
             FROM Opportunity
             WHERE Id IN :opportunityIds]
        );
    
        Map<Id, List<String>> oppToRolesMap = new Map<Id, List<String>>();
        for (OpportunityContactRole contactRole : [
            SELECT OpportunityId, Role 
            FROM OpportunityContactRole 
            WHERE OpportunityId IN :opportunityIds
        ]) {
            if (!oppToRolesMap.containsKey(contactRole.OpportunityId)) {
                oppToRolesMap.put(contactRole.OpportunityId, new List<String>());
            }
            oppToRolesMap.get(contactRole.OpportunityId).add(contactRole.Role);
        }
    
        Map<String, List<Documento__mdt>> roleToDocumentsMap = new Map<String, List<Documento__mdt>>();
        for (Documento__mdt doc : [SELECT Nome_do_Documento__c, Obrigatorio__c, Papel__c FROM Documento__mdt]) {
            if (!roleToDocumentsMap.containsKey(doc.Papel__c)) {
                roleToDocumentsMap.put(doc.Papel__c, new List<Documento__mdt>());
            }
            roleToDocumentsMap.get(doc.Papel__c).add(doc);
        }

        Map<Id, List<Checklist_de_Documentos__c>> oppToDocumentsMap = new Map<Id, List<Checklist_de_Documentos__c>>();
        List<Checklist_de_Documentos__c> relatedChecklists = [
            SELECT Oportunidade__c, Documenta_o__r.Obrigatorio__c, Documenta_o__r.Entregue__c
            FROM Checklist_de_Documentos__c
            WHERE Oportunidade__c IN :opportunityIds
        ];
    
        for (Checklist_de_Documentos__c checklist : relatedChecklists) {
            if (!oppToDocumentsMap.containsKey(checklist.Oportunidade__c)) {
                oppToDocumentsMap.put(checklist.Oportunidade__c, new List<Checklist_de_Documentos__c>());
            }
            oppToDocumentsMap.get(checklist.Oportunidade__c).add(checklist);
        }
    
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
    
        for (Id oppId : opportunityIds) {
            Opportunity opp = opportunities.get(oppId);
            List<Checklist_de_Documentos__c> documents = oppToDocumentsMap.get(oppId);
    
            if (opp == null || documents == null || documents.isEmpty()) continue;
    
            Integer totalMandatoryCount = 0;
            Integer totalOptionalCount = 0;
            Integer deliveredMandatoryCount = 0;
            Integer deliveredOptionalCount = 0;
    
            List<String> roles = oppToRolesMap.get(oppId);
            if (roles != null) {
                for (String role : roles) {
                    List<Documento__mdt> documentsForRole = roleToDocumentsMap.get(role);
                    if (documentsForRole != null) {
                        for (Documento__mdt doc : documentsForRole) {
                            if (doc.Obrigatorio__c) {
                                totalMandatoryCount++;
                            } else {
                                totalOptionalCount++;
                            }
                        }
                    }
                }
            }
    
            for (Checklist_de_Documentos__c checklist : documents) {
                if (checklist.Documenta_o__r == null) continue;
    
                if (checklist.Documenta_o__r.Obrigatorio__c) {
                    if (checklist.Documenta_o__r.Entregue__c) {
                        deliveredMandatoryCount++;
                    }
                } else {
                    if (checklist.Documenta_o__r.Entregue__c) {
                        deliveredOptionalCount++;
                    }
                }
            }

            System.debug(totalMandatoryCount);
            System.debug(deliveredMandatoryCount);
            
            if (deliveredMandatoryCount < totalMandatoryCount) {
                opp.FarolChecklistDocumento__c = 'Vermelho';
            } else if (deliveredMandatoryCount == totalMandatoryCount &&
                       deliveredMandatoryCount + deliveredOptionalCount < totalMandatoryCount + totalOptionalCount) {
                opp.FarolChecklistDocumento__c = 'Verde';
            } else if (deliveredMandatoryCount + deliveredOptionalCount == totalMandatoryCount + totalOptionalCount) {
                opp.FarolChecklistDocumento__c = 'Azul';
            }
    
            opportunitiesToUpdate.add(opp);
        }
    
        // Atualizar as oportunidades no banco
        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }

    public static List<Checklist_de_Documentos__c> getByOpportunityId(Set<Id> opportunitiesId) {        
        List<Checklist_de_Documentos__c> checklists = ChecklistDA.getWithDocumentsByOpportunity( opportunitiesId );
        if (checklists.isEmpty()) throw new IllegalArgumentException('Nenhum Checklist de Documentos encontrada.');

        return checklists;
    }

    public static List<Checklist_de_Documentos__c> getByAnaliseCredito(Id analiseCreditoId) {
        List<Opportunity> opps = OpportunityDA.getByAnaliseCreditoId(analiseCreditoId);
        if (opps.isEmpty()) throw new IllegalArgumentException('Nenhuma Oportunidade relacionada à Análise de Crédito: '+ analiseCreditoId);

        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : opps) {
            oppIds.add(opp.Id);
        }

        List<Checklist_de_Documentos__c> checklists = ChecklistDA.getWithDocumentsByOpportunity( oppIds );
        if (checklists.isEmpty()) throw new IllegalArgumentException('Nenhum Checklist de Documentos encontrada.');

        return checklists;
    }

}