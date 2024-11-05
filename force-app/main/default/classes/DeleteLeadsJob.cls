public class DeleteLeadsJob implements System.Queueable {
    private List<Lead> leadsToDelete;

    public DeleteLeadsJob(List<Lead> leadsToDelete) {
        this.leadsToDelete = leadsToDelete;
    }

    public void execute(System.QueueableContext context) {
        delete leadsToDelete;
    }
}