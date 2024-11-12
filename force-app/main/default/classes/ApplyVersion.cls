global class ApplyVersion implements Schedulable {
    public DateTime limitDate;

    
    public ApplyVersion(Datetime limitDate){
        this.limitDate = limitDate;
    }

    global void execute(SchedulableContext SC) {
     
        List<Lead> leadsToUpdate = [SELECT Id,
                                   Status,
                                   DataHoraVencimento__c,
                                   ConfiguracaoDeSLA__c,
                                   ConfiguracaoDeSLA__r.FaseParaRedirecionamentoDoLead__c,
                                   ConfiguracaoDeSLA__r.Fase__c,
                                   ConfiguracaoDeSLA__r.FilaParaRedirecionamentoDoLead__c
                                FROM Lead
                                WHERE DataHoraVencimento__c <: this.limitDate];

        
        List<Lead> leadsToUpdateList = new List<Lead>();

        for (Lead ld : leadsToUpdate) {
            if (ld.Status.equalsIgnoreCase(ld.ConfiguracaoDeSLA__r.Fase__c) && ld.DataHoraVencimento__c < DateTime.now()) {
                List<Group> grupos = [SELECT Id FROM Group WHERE Name =: ld.ConfiguracaoDeSLA__r.FilaParaRedirecionamentoDoLead__c];
                if (!grupos.isEmpty()) {
                    ld.OwnerId = grupos[0].Id; 
                    ld.Status = ld.ConfiguracaoDeSLA__r.FaseParaRedirecionamentoDoLead__c;
                    leadsToUpdateList.add(ld); 
                } else {
                    System.debug('Nenhum grupo encontrado com o nome: ' + ld.ConfiguracaoDeSLA__r.FilaParaRedirecionamentoDoLead__c);
                }
            }
        }

        
        if (!leadsToUpdateList.isEmpty()) {
            TriggerHandler.bypass('LeadTriggerHandler');
            update leadsToUpdateList;
            TriggerHandler.clearBypass('LeadTriggerHandler');
        }

      
         scheduleNextJob();
    }

   private void scheduleNextJob() {
    
    DateTime newDate = Datetime.now().addMinutes(5);

    
    List<CronTrigger> existingJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'ApplyVersionJob'];

    
    if (!existingJobs.isEmpty()) {
        for (CronTrigger job : existingJobs) {
            System.abortJob(job.Id);
        }
    }

    // Ajuste para garantir que os valores de hora e minuto sejam válidos
    Integer second = newDate.second();
    Integer minute = newDate.minute();
    Integer hour = newDate.hour();

    // Constrói a expressão cron para agendar o job
    String cron = '0 ' + minute + ' ' + hour + ' * * ?';
    
    // Agenda um novo job com a nova expressão cron
    System.schedule('ApplyVersionJob', cron, new ApplyVersion(newDate));
}
}