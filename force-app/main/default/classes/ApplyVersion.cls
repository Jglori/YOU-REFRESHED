global class ApplyVersion implements Schedulable {
    public Id leadid;
    public DateTime limitDate;
    
    public ApplyVersion(Datetime limitDate){
        this.limitDate = limitDate;
    }
    
    global void execute(SchedulableContext SC) {
        Lead ld = [Select id, Name,
                       Status, 
                       DataHoraVencimento__c,
                       ConfiguracaoDeSLA__c, 
                       ConfiguracaoDeSLA__r.FaseParaRedirecionamentoDoLead__c, 
                       ConfiguracaoDeSLA__r.Fase__c, 
                       ConfiguracaoDeSLA__r.FilaParaRedirecionamentoDoLead__c
                   FROM Lead
                   Where DataHoraVencimento__c <: this.limitDate
                  ];
        
        if(ld.Status.equalsIgnoreCase(ld.ConfiguracaoDeSLA__r.Fase__c) && ld.DataHoraVencimento__c < DateTime.Now()){
            ld.OwnerId = [Select Id from Group where Name =: ld.ConfiguracaoDeSLA__r.FilaParaRedirecionamentoDoLead__c].Id;
            ld.Status = ld.ConfiguracaoDeSLA__r.FaseParaRedirecionamentoDoLead__c;
            TriggerHandler.bypass('LeadTriggerHandler');
            if(!Test.isRunningTest()) update ld;
            TriggerHandler.clearBypass('LeadTriggerHandler');
        }

        Datetime newDate =  Datetime.now().addMinutes(30);
        String sch = newDate.Second()+ ' '+newDate.Minute()+ ' '+newDate.Hour()+' '+newDate.day()+' '+newDate.month()+' ?';
        System.schedule(ld.Name + DateTime.now() , sch, new ApplyVerSion(newDate));


    }
}