public class ProcessLeadMtnQueueable implements Queueable, Database.AllowsCallouts {
    private List<Lead_MTN__c> leadsToProcess;
    private Integer index;

    public ProcessLeadMtnQueueable(List<Lead_MTN__c> leadsToProcess, Integer index) {
        this.leadsToProcess = leadsToProcess;
        this.index = index;
    }

    public void execute(QueueableContext context) {
        if (index < leadsToProcess.size()) {
            // Processa o Lead_MTN__c atual
            Lead_MTN__c leadMTN = leadsToProcess[index];

            // Verifica se há um participante validado na roleta
            List<ParticipanteRoleta__c> participantes = [
                SELECT Name, PresencaValidada__c, RoletaLeads__r.Name, RoletaLeads__c 
                FROM ParticipanteRoleta__c 
                WHERE RoletaLeads__c = :leadMTN.Roleta_de_leads__c AND PresencaValidada__c = true
                LIMIT 1
            ];

            // Se houver pelo menos um participante validado, processa o lead
            if (!participantes.isEmpty()) {
                LeadMtnHelper.criarLeads(new List<Lead_MTN__c>{leadMTN});
            }

            // Agenda o próximo processamento após 20 segundos (ou 1 minuto)
            Integer nextIndex = index + 1;
            if (nextIndex < leadsToProcess.size()) {
                System.enqueueJob(new ProcessLeadMtnQueueable(leadsToProcess, nextIndex));

                Long waitTime = 15000;
                        DateTime now = DateTime.now();
                        while (DateTime.now().getTime() < now.getTime() + waitTime) {
                            // Espera
                        }
            }
        }
    }
}