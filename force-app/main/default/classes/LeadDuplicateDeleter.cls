public without sharing class LeadDuplicateDeleter {
    /**
     * Metodo responsavel por deletar leads duplicados.
     * @param leads Lista de leads a serem verificados.
     * @return Lista de Ids dos leads deletados.
     */
    @InvocableMethod(label='Delete Leads Duplicate' description='Deleta Leads duplicados')
    public static List<Id> deleteLeadsDuplicate(List<Lead> leads) {
        Set<String> emails = new Set<String>();
        Set<String> phones = new Set<String>();
        Set<Id> originalIds = new Set<Id>();

        for (Lead lead : leads) {
            if (lead.Email != null) emails.add(lead.Email);
            if (lead.MobilePhone != null) phones.add(lead.MobilePhone);
            originalIds.add(lead.Id);
        }

        List<Lead> duplicateLeads = [
            SELECT Id, Email, MobilePhone
            FROM Lead
            WHERE (Email IN :emails OR MobilePhone IN :phones)
        ];

        List<Id> idsToDelete = new List<Id>();

        for (Lead lead : duplicateLeads) {
            if (!originalIds.contains(lead.Id)) {
                idsToDelete.add(lead.Id);
            }
        }

        if (!idsToDelete.isEmpty()) {
            delete [SELECT Id FROM Lead WHERE Id IN :idsToDelete];
        }

        return idsToDelete;
    }
}