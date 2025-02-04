public class NotificarLeadBatch implements Database.Batchable<SObject> {
    
    public Id userId;
    public Id leadId;
    
    // Construtor que recebe os parâmetros leadId e userId
    public NotificarLeadBatch(Id leadId, Id userId) {
        this.leadId = leadId;
        this.userId = userId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Consulta os leads que serão processados (ajuste a consulta conforme necessário)
        return Database.getQueryLocator([
            SELECT Id, FirstName, LastName FROM Lead WHERE Id = :leadId
        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> scope) {
        // Processa cada lead encontrado
        for (Lead lead : scope) {
            // Recupera o usuário
            User user = [SELECT Id, Name FROM User WHERE Id = :userId];
            
            // Cria o post no Chatter
            FeedItem post = new FeedItem();
            post.ParentId = lead.Id;
            post.Body = user.Name + ' aceitou o lead ' + lead.FirstName + ' ' + lead.LastName + '.';
            post.Type = 'LinkPost';  
            insert post;
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        // Log ou outras ações após o batch ser concluído, se necessário
        System.debug('Batch process completed');
    }
}