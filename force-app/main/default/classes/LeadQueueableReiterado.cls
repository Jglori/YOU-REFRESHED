public class LeadQueueableReiterado implements Queueable, Database.AllowsCallouts {
    private List<Lead> leadsToUpdate;

    public LeadQueueableReiterado(List<Lead> leads) {
        this.leadsToUpdate = leads;
    }

    public void execute(QueueableContext context) {
        update leadsToUpdate;
    }
}