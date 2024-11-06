global class VerificaPrazoAssinaturaBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Status, StartDate, Account.Name, CustomerSignedDate, DataEnvioAssinatura__c, PrazoAssinatura__c FROM Contract WHERE PrazoAssinatura__c < :Date.today() AND Status = \'Em Assinatura\'';

        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        ContratoService.verificaPrazoAssinatura((List<Contract>) scope);
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('VerificaPrazoAssinaturaBatch implementada!');
    }
}