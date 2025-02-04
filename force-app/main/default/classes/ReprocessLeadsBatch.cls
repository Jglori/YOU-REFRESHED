public class ReprocessLeadsBatch implements Database.Batchable<SObject> {
    public Id corretorId;
    
    public ReprocessLeadsBatch(Id corretorId) {
        this.corretorId = corretorId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query para buscar os leads não processados
        return Database.getQueryLocator([
            SELECT Id, Processed_c__c  
            FROM Lead 
            WHERE CorretorContato__c = :corretorId
            AND Processed_c__c = false  // Só pega os que ainda não foram processados
        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Lead> leadsToUpdate = (List<Lead>)scope;
        
        for (Lead lead : leadsToUpdate) {
            lead.Processed_c__c = true;
        }
        
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'ewertonzorolima@gmail.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch de reprocessamento de leads concluída');
        mail.setPlainTextBody('O processamento da batch de reprocessamento de leads foi concluído com sucesso.');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}