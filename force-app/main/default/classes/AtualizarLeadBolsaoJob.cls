public class AtualizarLeadBolsaoJob implements Schedulable {
    private Id roletaLeadsId;
    public AtualizarLeadBolsaoJob(Id roletaLeadsId) {
        this.roletaLeadsId = roletaLeadsId;
    }
    public void execute(SchedulableContext sc) {
        try {
            List<Lead> leadsToClone = [SELECT Id, LastName, FirstName, RecordTypeId, MobilePhone, Email, LeadSource, Status, OwnerId,
                                              CanalAtendimento__c, ChaveExternaWhatsApp__c, ConfiguracaoDeSLA__c, EmpreendimentoInteresse__c,
                                              MidiaOriginal__c, PrimeiraInteracao__c, RoletaLeads__c, SubProduto__c, IDAnapro__c , Informacoes_Adicionais__c, Phone , Data_Iteracao_MTN__c
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
            Lead leadToClone = leadsToClone[0];
            if (leadToClone.CanalAtendimento__c == 'Oferta Corretor') {
                System.debug('Lead ignorado: Canal de Atendimento é "Oferta Corretor".');
                return;
            }
            delete leadToClone;
            Lead clonedLead = leadToClone.clone(false, true, true, true);
            clonedLead.OwnerId = leadToClone.OwnerId;
            clonedLead.Status = 'Novo';
            insert clonedLead;
            System.debug('Lead clonado e inserido com sucesso. ID: ' + clonedLead.Id);
        } catch (Exception e) {
            System.debug('Erro ao clonar e inserir o lead: ' + e.getMessage());
        }
    }
}