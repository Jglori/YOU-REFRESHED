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


        System.debug('Oportunidade IDs: ' + opportunityIds);
        Map<Id, List<Checklist_de_Documentos__c>> checklistDocsMap = ChecklistDA.getChecklistDocumentsWithDetails(opportunityIds);
        System.debug('Map de documentos: ' + checklistDocsMap);

        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

       
        for (Id oppId : opportunityIds) {
            List<Checklist_de_Documentos__c> docs = checklistDocsMap.get(oppId);

         
            System.debug('Oportunidade ID: ' + oppId + ', Documentos: ' + docs);

        
            Boolean anyMandatoryNotDelivered = false;  // Algum documento obrigatório não foi entregue
            Boolean allMandatoryDelivered = true;      // Todos os documentos obrigatórios foram entregues
            Boolean allDocumentsDelivered = true;      // Todos os documentos (obrigatórios e não obrigatórios) foram entregues

            if (docs != null && !docs.isEmpty()) {
                for (Checklist_de_Documentos__c checklist : docs) {
                    if (checklist.Documenta_o__c != null) {
                        if (checklist.Documenta_o__r.Obrigatorio__c) {
                            System.debug('Documento obrigatório encontrado: ' + checklist.Documenta_o__c + ', Entregue: ' + checklist.Documenta_o__r.Entregue__c + ',Obrigatorio:' + checklist.Documenta_o__r.Obrigatorio__c);
                            if (!checklist.Documenta_o__r.Entregue__c) {
                                anyMandatoryNotDelivered = true;
                                allMandatoryDelivered = false;
                                System.debug('Documento obrigatório NÃO foi entregue: ' + checklist.Documenta_o__c);
                            } else {
                                System.debug('Documento obrigatório foi entregue: ' + checklist.Documenta_o__c);
                            }
                        }

                      
                        if (!checklist.Documenta_o__r.Entregue__c) {
                            allDocumentsDelivered = false;
                            System.debug('Documento NÃO foi entregue: ' + checklist.Documenta_o__c);
                        }
                    }
                }
            }

           
            System.debug('Oportunidade ID: ' + oppId);
            System.debug('anyMandatoryNotDelivered: ' + anyMandatoryNotDelivered);
            System.debug('allMandatoryDelivered: ' + allMandatoryDelivered);
            System.debug('allDocumentsDelivered: ' + allDocumentsDelivered);

            // Define o status do farol baseado nas condições
            String newFarolStatus = 'Vermelho';

            if (!anyMandatoryNotDelivered) {
                if (allMandatoryDelivered && allDocumentsDelivered) {
                    newFarolStatus = 'Azul'; 
                    System.debug('Farol definido como Azul');
                } else if (allMandatoryDelivered) {
                    newFarolStatus = 'Verde'; 
                    System.debug('Farol definido como Verde');
                }
            } else {
                System.debug('Farol definido como Vermelho');
            }

            Opportunity opp = new Opportunity(Id = oppId, FarolChecklistDocumento__c = newFarolStatus);
            opportunitiesToUpdate.add(opp);
        }
        if (!opportunitiesToUpdate.isEmpty()) {
            System.debug('Oportunidades a serem atualizadas: ' + opportunitiesToUpdate);
            update opportunitiesToUpdate;
        } else {
            System.debug('Nenhuma oportunidade a ser atualizada.');
        }
    }
}