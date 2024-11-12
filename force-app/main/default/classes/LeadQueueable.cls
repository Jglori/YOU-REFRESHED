public class LeadQueueable implements Queueable, Database.AllowsCallouts {

    private List<Lead> leadsToInsert;

    public LeadQueueable(List<Lead> leads) {
        this.leadsToInsert = leads;
    }

    public void execute(QueueableContext context) {
        try {
            List<Lead> leadsWhatsapp = new List<Lead>();
            List<Lead> leadsToUpdate = new List<Lead>();
            List<Lead> leadsToInsertFinal = new List<Lead>();
            Set<Id> leadIdsToUpdate = new Set<Id>();

            // Filtrando os leads com 'LeadSource' igual a 'Whatsapp'
            for (Lead l : leadsToInsert) {
                if (l.LeadSource == 'Whatsapp') {  leadsWhatsapp.add(l);
                } else {
                    leadsToInsertFinal.add(l);
                }
            }

            if (!leadsWhatsapp.isEmpty()) {
                RoletaLeads__c roleta = [SELECT Id FROM RoletaLeads__c WHERE Name = 'Roleta Online' LIMIT 1];

                if (roleta != null) {
                    for (Lead lead : leadsWhatsapp) {
                        lead.RoletaLeads__c = roleta.Id;
                    }

                    for (Lead lead : leadsWhatsapp) {
                        if (lead.Id != null && !leadIdsToUpdate.contains(lead.Id)) {
                            leadsToUpdate.add(lead);
                            leadIdsToUpdate.add(lead.Id);
                        } else {
                            leadsToInsertFinal.add(lead);
                        }
                    }
                } else {
                    System.debug('Roleta Online não encontrada.');
                }
            }

            if (!leadsToInsertFinal.isEmpty()) {
                insert leadsToInsertFinal;
            }

            if (!leadsToUpdate.isEmpty()) {
                update leadsToUpdate;
            }

        } catch (DmlException e) {
            System.debug('Falha ao inserir ou atualizar leads: ' + e.getMessage());
        }
    }
}