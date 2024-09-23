public class CRECIStatusHandler {
    public static void updateCRECIStatus(List<Contact> records) {
        Date dataAtual = Date.today();
        
        for (Contact record : records) {
            if (record.DatadeVencimento__c != null) {
                if (record.DatadeVencimento__c >= dataAtual) {
                    record.CRECIAtivo__c = true;
                } else {
                    record.CRECIAtivo__c = false;
                }
            }
        }
    }
}