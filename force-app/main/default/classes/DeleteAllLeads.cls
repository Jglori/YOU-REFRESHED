public class DeleteAllLeads {
    public static void deleteAll() {
        List<Lead> leadsToDelete = [SELECT Id FROM Lead LIMIT 10000]; 
        delete leadsToDelete;
    }
}