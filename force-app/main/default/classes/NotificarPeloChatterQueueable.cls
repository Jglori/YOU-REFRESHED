public class NotificarPeloChatterQueueable implements Queueable {
    private List<Id> leadIds;
    private Id userId;

    public NotificarPeloChatterQueueable(List<Id> leadIds, Id userId) {
        this.leadIds = leadIds;
        this.userId = userId;
    }

    public void execute(QueueableContext context) {
        List<FeedItem> posts = new List<FeedItem>();

        List<Lead> leads = [SELECT Id, FirstName, LastName FROM Lead WHERE Id IN :leadIds];
        User user = [SELECT Id, Name FROM User WHERE Id = :userId];

        for (Lead lead : leads) {
            FeedItem post = new FeedItem();
            post.ParentId = lead.Id;
            post.Body = user.Name + ' aceitou o lead ' + lead.FirstName + ' ' + lead.LastName + '.';
            post.Type = 'LinkPost';
            posts.add(post);
        }

        if (!posts.isEmpty()) {
            insert posts;
        }
    }
}