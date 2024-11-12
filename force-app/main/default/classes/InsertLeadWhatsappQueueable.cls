public class InsertLeadWhatsappQueueable implements Queueable, Database.AllowsCallouts {
    private List<Lead> leads;

    public InsertLeadWhatsappQueueable(List<Lead> leads) {
        this.leads = leads;
    }

    public void execute(QueueableContext context) {
        try {
            RoletaLeads__c roleta = [SELECT Id FROM RoletaLeads__c WHERE Name = 'Roleta Online' LIMIT 1];
            
            for (Lead lead : leads) {
                lead.RoletaLeads__c = roleta.Id;
            }
            
            // Inserir os leads com a Roleta atribuída
            insert leads;
        } catch (DmlException e) {
            System.debug('Erro ao inserir leads de whatsapp: ' + e.getMessage());
        } catch (QueryException qe) {
            System.debug('Erro na consulta de RoletaLeads: ' + qe.getMessage());
        }
    }
}