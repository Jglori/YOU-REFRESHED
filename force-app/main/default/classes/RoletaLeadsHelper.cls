public class RoletaLeadsHelper {

    public static void LeadsBolsao(List<RoletaLeads__c> listaRoletas) {
        Set<Id> idsLeads = new Set<Id>();
    
        System.debug('Lista Roletas: ' + listaRoletas.size());
    
        for (RoletaLeads__c roleta : listaRoletas) { 
            Time horaInicio = roleta.HoraInicio__c;
            System.debug('Hora Inicio: ' + horaInicio);
            Datetime startDateTime = Datetime.newInstance(System.today(), horaInicio);
            System.debug('Start Date Time: ' + startDateTime);
            String baseJobName = 'Bolsao de Leads da Roleta ' + roleta.Id;
    
            System.debug('Base Job Name: ' + baseJobName);
    
            Datetime jobStartTime = startDateTime.addMinutes(5);
    
            List<Lead> leadsBolsao = [
                SELECT Id  
                FROM Lead 
                WHERE RoletaLeads__c != NULL 
                AND CorretorContato__r.Name = ''
                AND Status = 'Novo' 
                AND RoletaLeads__r.Id = :roleta.Id 
                LIMIT 100
            ];
    
            System.debug('Leads Bolsao: ' + leadsBolsao.size());
    
            if (!leadsBolsao.isEmpty()) {
                for (Integer i = 1; i <= leadsBolsao.size(); i++) {
                    if (jobStartTime < System.now()) {
                        jobStartTime = System.now().addMinutes(10);
                    }
    
                    String uniqueJobName = baseJobName + ' - Job ' + i + ' - ' + Datetime.now().getTime();
    
                    List<CronTrigger> jobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :uniqueJobName];
    
                    if (jobs.isEmpty()) {
                        String sch = '0 ' + jobStartTime.minute() + ' ' + jobStartTime.hour() + ' ' + jobStartTime.day() + ' ' + jobStartTime.month() + ' ? ' + jobStartTime.year();
    
                        try {
                            System.schedule(uniqueJobName, sch, new AtualizarLeadBolsaoJob(roleta.Id));
                            idsLeads.add(roleta.Id);
    
                            jobStartTime = jobStartTime.addMinutes(3);
                        } catch (Exception e) {
                            System.debug('Erro ao agendar o job: ' + e.getMessage());
                        }
                    }
                }
            }
        }
    }
    


    public static void LeadsBolsaoHorarioAgendado(List<RoletaLeads__c> listaRoletas, Time horaInicio) {
        Set<Id> idsLeads = new Set<Id>();
        
        System.debug('Lista Roletas: ' + listaRoletas.size());
        
        for (RoletaLeads__c roleta : listaRoletas) {
            System.debug('Hora Inicio: ' + horaInicio);
            Datetime startDateTime = Datetime.newInstance(System.today(), horaInicio);
            System.debug('Start Date Time: ' + startDateTime);
            String baseJobName = 'Bolsao de Leads da Roleta ' + roleta.Id;
            
            System.debug('Base Job Name: ' + baseJobName);
            
            Datetime jobStartTime = startDateTime.addMinutes(5);
            
            List<Lead> leadsBolsao = [
                SELECT Id
                FROM Lead
                WHERE RoletaLeads__c != NULL
                AND CorretorContato__r.Name = ''
                AND RoletaLeads__r.Id = :roleta.Id
                AND Status = 'Novo'
                LIMIT 100
            ];
            
            System.debug('Leads Bolsao: ' + leadsBolsao.size());
            
            // Verifica se já existem jobs agendados com base no nome base do job
            List<AsyncApexJob> existingJobs = [
                SELECT Id, Status, CronTrigger.CronJobDetail.Name 
                FROM AsyncApexJob 
                WHERE (Status = 'Preparing' OR Status = 'Processing' OR Status = 'Queued') 
                AND CronTrigger.CronJobDetail.Name LIKE :('%' + baseJobName + '%')
            ];
            
            if (existingJobs.isEmpty()) {
                if (!leadsBolsao.isEmpty()) {
                    for (Integer i = 1; i <= leadsBolsao.size(); i++) {
                        if (jobStartTime < System.now()) {
                            jobStartTime = System.now().addMinutes(10);
                        }
                        
                        String uniqueJobName = baseJobName + ' - Job ' + i + ' - ' + Datetime.now().getTime();
                        
                        List<CronTrigger> jobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :uniqueJobName];
                        
                        if (jobs.isEmpty()) {
                            String sch = '0 ' + jobStartTime.minute() + ' ' + jobStartTime.hour() + ' ' + jobStartTime.day() + ' ' + jobStartTime.month() + ' ? ' + jobStartTime.year();
                            
                            try {
                                System.schedule(uniqueJobName, sch, new AtualizarLeadBolsaoJob(roleta.Id));
                                idsLeads.add(roleta.Id);
                                
                                jobStartTime = jobStartTime.addMinutes(3);
                            } catch (Exception e) {
                                System.debug('Erro ao agendar o job: ' + e.getMessage());
                            }
                        }
                    }
                }
            } else {
                System.debug('Já existem jobs agendados para ' + baseJobName + '. Nenhum novo job será criado.');
            }
        }
    }
    
    public static void limparParticipantesRoleta(Id roletaId) {
        try {
            List<ParticipanteRoleta__c> participantes = [
                SELECT Id 
                FROM ParticipanteRoleta__c 
                WHERE RoletaLeads__c = :roletaId
            ];  
            if (!participantes.isEmpty()) {
                delete participantes;
            }
        } catch (Exception e) {
            System.debug('Erro ao limpar participantes da roleta: ' + e.getMessage());
        }
    }
}