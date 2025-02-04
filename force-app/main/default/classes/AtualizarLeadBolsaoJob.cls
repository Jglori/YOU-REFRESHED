public class AtualizarLeadBolsaoJob implements Schedulable {
    private Id roletaLeadsId;

    public AtualizarLeadBolsaoJob(Id roletaLeadsId) {
        this.roletaLeadsId = roletaLeadsId;
    }

    public void execute(SchedulableContext sc) {
        try {
            List<Lead> leadsToClone = [SELECT id, lastname, FirstName, RecordTypeId, MobilePhone, Email, LeadSource, Status, OwnerId, CanalAtendimento__c, ChaveExternaWhatsApp__c, ConfiguracaoDeSLA__c, EmpreendimentoInteresse__c, MidiaOriginal__c, PrimeiraInteracao__c, RoletaLeads__c, SubProduto__c
                                       FROM Lead 
                                       WHERE CorretorContato__r.Name = '' 
                                       AND RoletaLeads__c != null
                                       AND RoletaLeads__r.Id = :roletaLeadsId
                                       AND Status = 'Novo'  
                                       LIMIT 1];
            
            if (leadsToClone.isEmpty()) {
                System.debug('Não há leads para clonar.');
                return;
            }

            delete leadsToClone;

            Lead leadToClone = leadsToClone[0];
            Lead clonedLead = leadToClone.clone(false, true, true, true);
            clonedLead.Status = 'Novo';

            insert clonedLead;

            System.debug('Lead clonado e inserido com sucesso.');
        } catch (Exception e) {
            System.debug('Erro ao clonar e inserir o lead: ' + e.getMessage());
        }
    }
}