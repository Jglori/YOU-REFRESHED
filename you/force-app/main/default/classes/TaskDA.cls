public with sharing class TaskDA {
    public static List<Task> getContactTasksByWhoId(Set<Id> leadsId, Boolean completed) {
        String subjectCondition = '(Subject = \'Chamada\' OR Subject = \'Email\' OR Subject = \'Whatsapp\')';
        String statusCondition = completed ? 'Status = \'Completed\'' : 'Status != \'Completed\'';
        String query = 'SELECT Id, WhoId, Subject FROM Task WHERE WhoId IN :leadsId AND ' + statusCondition + ' AND ' + subjectCondition;
        return Database.query(query);
    }
    
    // Sobrecarga do método para aceitar uma string como status
    public static List<Task> getContactTasksByWhoId(Set<Id> leadsId, String status) {
        String subjectCondition = '(Subject = \'Chamada\' OR Subject = \'Email\' OR Subject = \'Whatsapp\')';
        String statusCondition = 'Status = \'' + status + '\'';
        String query = 'SELECT Id, WhoId, Subject FROM Task WHERE WhoId IN :leadsId AND ' + statusCondition + ' AND ' + subjectCondition;
        return Database.query(query);
    }

    public static Lead getLeadByLeadId(String leadId) {
        String query = 'SELECT Id FROM Lead WHERE Id = :leadId';
        List<Lead> leads = Database.query(query);
        if (!leads.isEmpty()) {
            return leads[0];
        } else {
            return null;
        }
    }

    public static List<CampaignMember> buscarUltimasCampanhasLeadId(Id leadId){
        String query = 'SELECT Lead.Id, Lead.FirstName, Lead.LastName, Lead.Email, Lead.Phone, Campaign.Name ' +
                       'FROM CampaignMember ' +
                       'WHERE LeadId = :leadId';
    
        return Database.query(query);
    }
    
    public static CampaignMember buscarUltimaCampanha(Id leadId){
        String query = 'SELECT Id, Campaign.Name, LeadId ' +
                       'FROM CampaignMember ' +
                       'WHERE LeadId = :leadId ' +
                       'ORDER BY CreatedDate DESC ' +
                       'LIMIT 1';
        List<CampaignMember> campaignMembers = Database.query(query);
        if (!campaignMembers.isEmpty()) {
            return campaignMembers[0];
        } else {
            return null;
        }
    }

    public static String buscarNomeCampanha(Id campaignId) {
        Campaign campaign = [SELECT Name FROM Campaign WHERE Id = :campaignId LIMIT 1];
        return campaign.Name;
    }

    public static CampaignMember leadParticipaDeCampanha(Id leadId){
        List<CampaignMember> campaignMembers = [
            SELECT LeadId, CampaignId 
            FROM CampaignMember 
            WHERE LeadId = :leadId 
            LIMIT 1
        ];
    
        if (!campaignMembers.isEmpty()) {
            return campaignMembers[0];
        } else {
            return null;
        }
    }
}