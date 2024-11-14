public class ChecklistHelper {

    public static void updateOpportunityChecklistStatus(List<Checklist_de_Documentos__c> checklists) {
        Set<Id> opportunityIds = new Set<Id>();

        for (Checklist_de_Documentos__c checklist : checklists) {
            if (checklist.Oportunidade__c != null) {
                opportunityIds.add(checklist.Oportunidade__c);
            }
        }

        if (opportunityIds.isEmpty()) {
            System.debug('Nenhuma oportunidade encontrada.');
            return;
        }

        Map<Id, List<Checklist_de_Documentos__c>> checklistDocsMap = ChecklistDA.getChecklistDocumentsWithDetails(opportunityIds);
        
        List<String> papeisParaVerificar = new List<String>{
            'Comprador', 
            'Fiador', 
            'Outro', 
            'Procurador'
        };
        
        List<Documento__mdt> documentosMetadados = ChecklistDA.getRequiredDocumentsByPapeis(papeisParaVerificar);
        
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

        for (Id oppId : opportunityIds) {
            List<Checklist_de_Documentos__c> docs = checklistDocsMap.get(oppId);
            Boolean anyMandatoryNotDelivered = false;
            Boolean allMandatoryDelivered = true; 
            Boolean allDocumentsDelivered = true; 

            if (docs != null && !docs.isEmpty()) {
                for (Documento__mdt documento : documentosMetadados) {
                    Boolean documentDelivered = false;

                    for (Checklist_de_Documentos__c checklist : docs) {
                        if (checklist.Documenta_o__r != null) {
                            if (checklist.Documenta_o__r.Id == documento.Id) {
                                if (documento.Obrigatorio__c) {
                                    if (!checklist.Documenta_o__r.Entregue__c) {
                                        anyMandatoryNotDelivered = true;
                                        allMandatoryDelivered = false;
                                    } else {
                                        documentDelivered = true;
                                    }
                                }

                                if (!checklist.Documenta_o__r.Entregue__c) {
                                    allDocumentsDelivered = false;
                                }
                            }
                        }
                    }

                    if (!documentDelivered && !documento.Obrigatorio__c) {
                        allDocumentsDelivered = false;
                    }
                }
            }

            String newFarolStatus = 'Vermelho';

            if (!anyMandatoryNotDelivered) {
                if (allMandatoryDelivered && allDocumentsDelivered) {
                    newFarolStatus = 'Azul'; 
                } else if (allMandatoryDelivered) {
                    newFarolStatus = 'Verde'; 
                }
            }

            Opportunity opp = new Opportunity(Id = oppId, FarolChecklistDocumento__c = newFarolStatus);
            opportunitiesToUpdate.add(opp);
        }

        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }

    public static List<Checklist_de_Documentos__c> getByAnalisesCredito(Set<Id> analisesCreditoId) {
        List<Opportunity> opps = OpportunityHelper.getByAnalisesCredito(analisesCreditoId);
        Set<Id> oppIds = new Set<Id>();
        
        for (Opportunity opp : opps) {
            oppIds.add(opp.Id);
        }

        List<Checklist_de_Documentos__c> checklists = ChecklistDA.getWithDocumentsByOpportunity( oppIds );
        if (checklists.isEmpty()) throw new IllegalArgumentException('Nunhuma Checklist de Documentos encontrada.');

        return checklists;
    }
}