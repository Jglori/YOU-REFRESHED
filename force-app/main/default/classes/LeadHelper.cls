public with sharing class LeadHelper {

    public static void statusValidate(List<Lead> newLeads, Map<Id, Lead> oldLeads){
        Set<String> pegaStatusLead = new Set<String>();
        for (Lead lead : newLeads) {
            Lead oldLead = oldLeads.get(lead.Id);
            if (lead.Status != oldLead.Status) {
                pegaStatusLead.add(lead.Status);
            }
        }
    }


    public static void verifyContactingStatus(Map<String, List<Lead>> statusToLeadsMap){
        List<Lead> openLeads = statusToLeadsMap.get('Open');
        if (openLeads != null) {
            validateContactTasks(openLeads, false);
        }
        List<Lead> completedLeads = statusToLeadsMap.get('Completed');
        if (completedLeads != null) {
            validateContactTasks(completedLeads, true);
        }
    }



    private static void validateContactTasks(List<Lead> leads, Boolean isCompleted) {
        Set<String> allowedSubjects = new Set<String>{'Chamada', 'Email', 'WhatsApp'};
        Map<Id, List<Task>> taskMap = getContactTasksMap(new Map<Id, Lead>(leads).keySet(), isCompleted);
        for (Lead lead : leads) {
            if (!taskMap.containsKey(lead.Id)) {
                String taskType = isCompleted ? 'concluída' : 'não concluída';
                lead.addError('É necessário ter pelo menos uma tarefa ' + taskType + ' do tipo Chamada, Email ou WhatsApp associada a este lead.');
            }
        }
    }
    
    private static Map<Id, List<Task>> getContactTasksMap(Set<Id> leadsId, Boolean isCompleted){
        List<Task> tasks = TaskDA.getContactTasksByWhoId(leadsId, isCompleted);
        Map<Id, List<Task>> taskMap = new Map<Id, List<Task>>();
        for (Task task : tasks) {
            if (!taskMap.containsKey(task.WhoId)) {
                taskMap.put(task.WhoId, new List<Task>());
            }
            taskMap.get(task.WhoId).add(task);
        }
        return taskMap;
    }


    public static void additionalValidations(List<Lead> newLeads, Map<Id, Lead> oldLeads) {
        for (Lead lead : newLeads) {
            Lead oldLead = oldLeads.get(lead.Id);
            if (oldLead.Status.equalsIgnoreCase('Tentativa de contato') && lead.Status.equalsIgnoreCase('Contato Realizado')) {
                if (!isTaskCreatedAndOpenForAttemptToContact(lead.Id)) {
                    lead.addError(Label.TentativaContato_LEAD);
                }
            }else if (oldLead.Status.equalsIgnoreCase('Agendamento de Visita') && lead.Status.equalsIgnoreCase('Qualificação') &&
                     !hasCompletedTaskForLead(lead.Id)) {
                lead.addError(Label.ContatoRealizado_LEAD);
            }else if (((oldLead.Status.equals('Descartado') || oldLead.Status.equals('Lead Perdido(não trabalho)') ||
                  oldLead.Status.equals('Novo') || oldLead.Status.equals('Nutrindo')) &&  lead.Status.equals('Contato Realizado'))) {
                     lead.addError(Label.Fases_LEAD);
            }else if ((oldLead.Status.equalsIgnoreCase('Descartado') || oldLead.Status.equalsIgnoreCase('Lead Perdido(não trabalho)') ||
                  oldLead.Status.equalsIgnoreCase('Novo') || oldLead.Status.equalsIgnoreCase('Nutrindo') ||
                  oldLead.Status.equalsIgnoreCase('Tentativa de contato')) && lead.Status.equalsIgnoreCase('Agendamento de Visita')) {
                  lead.addError(Label.TentativaContato_LEAD);
                  }else if ((lead.Status.equalsIgnoreCase('Qualificação') || oldLead.Status.equalsIgnoreCase('Conversão'))) {
                if (!lead.LeadNaoVisitou__c && isEventCreatedForVisits(lead.Id)) {
                    lead.addError(Label.Agendamento_LEAD);
                }
            }else if ((new Set<String>{'Descartado', 'Lead Perdido(não trabalho)', 'Novo', 'Nutrindo',
                'Tentativa de contato', 'Contato Realizado', 'Agendamento de Visita'}).contains(oldLead.Status) && lead.Status == 'Conversão') {
                lead.addError(Label.Conversao_LEAD);
            }
            if (lead.LeadNaoVisitou__c) {
                Boolean canAdvance = checkPreviousPhaseValidations(oldLead.Status, lead.Status, lead.Id);
                if (!canAdvance) {
                    lead.addError(Label.TentativaContato_LEAD);
                }
            }
        }
    }
    

    private static Boolean checkPreviousPhaseValidations(String oldStatus, String newStatus, Id leadId) {
        if (oldStatus.equalsIgnoreCase('Tentativa de contato') && newStatus.equalsIgnoreCase('Contato Realizado')) {
            return isTaskCreatedAndOpenForAttemptToContact(leadId);
        }
    
        if (oldStatus.equalsIgnoreCase('Agendamento de Visita') && newStatus.equalsIgnoreCase('Qualificação')) {
            return hasCompletedTaskForLead(leadId);
        }
  
        if (newStatus.equalsIgnoreCase('Qualificação')) {
            return !isEventCreatedForVisits(leadId);
        }
        return true;
    }
    
    
    private static Boolean isTaskCreationNotAllowedForTentativaContato(String leadStatus, String taskSubject) {
        Set<String> disallowedStatuses = new Set<String>{'Descartado', 'Lead Perdido(não trabalho)', 'Novo', 'Nutrindo','Agendamento de Visita','Qualificação'};

        if (disallowedStatuses.contains(leadStatus)) {
            return true; 
        }

        Set<String> allowedTaskTypes = new Set<String>{'Chamada', 'Email', 'Whatsapp','Enviar cotação','Visita','Outros'};
        return !allowedTaskTypes.contains(taskSubject);
    }

    



    public static void updateLeadStatusOnTaskCompletion(List<SObject> newTasks, Map<Id, SObject> oldTasks) {
        Set<Id> leadIdsToUpdate = new Set<Id>();
    
        List<Task> newTaskList = (List<Task>)newTasks;
        Map<Id, Task> oldTaskMap = (Map<Id, Task>)oldTasks;
    
        for (Task newTask : newTaskList) {
            Task oldTask = oldTaskMap.get(newTask.Id);
    
          
            if (newTask.Status == 'Completed' && oldTask.Status != 'Completed' &&
            (newTask.Subject == 'Email' || newTask.Subject == 'Whatsapp' || newTask.Subject == 'Chamada')){
                leadIdsToUpdate.add(newTask.WhoId);
            }
        }
    
        if (!leadIdsToUpdate.isEmpty()) {
            List<Lead> leadsToUpdate = LeadDA.getLeadsByIds(leadIdsToUpdate);
    
            for (Lead lead : leadsToUpdate) {
                if (lead.Status == 'Tentativa de contato') {
                    lead.Status = 'Contato Realizado';
                }
            }
    
            update leadsToUpdate;
        }
    }
     
    @TestVisible
    private static Boolean isTaskCreatedAndOpenForAttemptToContact(Id leadId) {  
        List<Task> tasks = TaskDA.getContactTasksByWhoId(new Set<Id>{leadId}, 'Completed');
        return !tasks.isEmpty();
    }

    @TestVisible
    private static Boolean hasCompletedTaskForLead(Id leadId) {
        List<Task> tasks = TaskDA.getContactTasksByWhoId(new Set<Id>{leadId}, 'Completed');return !tasks.isEmpty();
    }


    

    public static Boolean isEventCreatedForVisits(Id leadId) {
        List<Event> events = EventDA.getAllEventByLead(new Set<Id>{leadId});    
        return events.isEmpty(); // se estiver vazio a lista, retorna true
    }

    
    // public static void checkAndUpdateLeadsWithTasks(List<Lead> newLeads, Map<Id, Lead> oldLeadMap) {
    //     List<Id> leadsWithTasks = new List<Id>();
    //     Map<Id, List<Task>> mapTaskByWho = getMapTaskByWho(new Map<Id, Lead>(newLeads).keySet());
    //     for (Lead lead : newLeads) {
    //         Lead oldLead = oldLeadMap.get(lead.Id);
    //         if (lead.Status == 'Prospecção' && oldLead != null && oldLead.Status == 'Nutrindo' && !mapTaskByWho.containsKey(lead.Id)) {
    //             lead.addError('Para evoluir de Nutrindo para Prospecção, pelo menos uma tarefa deve ser criada.'); //Parametrizar mensagem em customLabel
    //         }
    //     }
    // }

    public static void verifyLeadControlSLA(List<Lead> leadList, Map<Id, Lead> oldLeads) {
        LeadSLAHelper.verifyLeadControlSLA(leadList, oldLeads);
    }

    private static Map<Id, List<Task>> getMapTaskByWho(Set<Id> setID){
        Map<Id, List<Task>> result = new Map<Id, List<Task>>();
        List<Task> lstTasks = [SELECT Id, Subject, WhoId FROM Task WHERE WhoId IN :setID];
        for (Task iTask : lstTasks) {
            List<Task> lstToPut = new List<Task>();
            if (result.containsKey(iTask.WhoId)) {
                lstToPut = result.get(iTask.WhoId);
            }
            lstToPut.add(iTask);
            result.put(iTask.WhoId, lstToPut);
        }
        return result;
    }
    public static void handleLeadReiteration(Lead existingLead, Map<String, Object> params) {
        if(params.containsKey('campaignName')){
            String campaignName = (String)params.get('campaignName');
            List<Campaign> campaigns = [SELECT Id FROM Campaign WHERE Name = :campaignName LIMIT 1];
            if(!campaigns.isEmpty()){
                Campaign campaign = campaigns[0];
                CampaignMember campaignMember = new CampaignMember(
                    CampaignId = campaign.Id,
                    LeadId = existingLead.Id
                );
                insert campaignMember;
            }
        }
        updateLeadFields(existingLead, params);
    }

    public static void verificarCampanhas(Id leadId){
      
       System.debug('Id do lead ' + leadId);
       CampaignMember campanha = TaskDA.buscarUltimaCampanha(leadId);
       System.debug('Camapanha ' + campanha);
    }
    

    private static void updateLeadFields(Lead lead, Map<String, Object> params) {
        if (lead.QuantidadeDeReiteracoes__c == null) {
            lead.QuantidadeDeReiteracoes__c = 1;
        } else {
            lead.QuantidadeDeReiteracoes__c += 1;
        }

        Boolean isModified = false;
        if (params.containsKey('MobilePhone') && lead.MobilePhone != (String)params.get('MobilePhone')) {
            lead.MobilePhone = (String)params.get('MobilePhone');
            isModified = true;
        }
        if (params.containsKey('Email') && lead.Email != (String)params.get('Email')) {
            lead.Email = (String)params.get('Email');
            isModified = true;
        }
        if (params.containsKey('EmpreendimentoInteresse__c') && lead.EmpreendimentoInteresse__c != (String)params.get('EmpreendimentoInteresse__c')) {
            lead.EmpreendimentoInteresse__c = (String)params.get('EmpreendimentoInteresse__c');
            isModified = true;
        }
        if (params.containsKey('LeadSource') && lead.LeadSource != (String)params.get('LeadSource')) {
            lead.LeadSource = (String)params.get('LeadSource');
            isModified = true;
        }

        if (isModified) {
            lead.ltima_Reitera_o__c  = System.now();
            update lead;
        }
    }

   
    public static void validateTaskCreation(List<Task> newTasks) {
        Set<Id> leadIds = new Set<Id>();
        for (Task task : newTasks) {
            if (task.WhoId != null && task.WhoId.getSObjectType() == Lead.SObjectType) {
                leadIds.add(task.WhoId);
            }
        }
        if (!leadIds.isEmpty()) {
            Map<Id, Lead> leads = new Map<Id, Lead>([SELECT Id, Status FROM Lead WHERE Id IN :leadIds]);
            for (Task task : newTasks) {
                if (task.WhoId != null && leads.containsKey(task.WhoId)) {
                    Lead lead = leads.get(task.WhoId);
                    if (isTaskCreationNotAllowedForTentativaContato(lead.Status, task.Subject)) {

                        if(task.Subject == 'Reiteração'){
                            continue;
                        }
                        task.addError('Só é permitido criar uma tarefa  quando o lead está nas fases Tentativa de Contato ou Contato Realizado.');
                    }
                }
            }
        }
    }

    public static void setLeadSource(List<Lead> newLeads) {
        for (Lead newLead : newLeads) {
            if (newLead.MidiaOriginal__c == null) {
                newLead.MidiaOriginal__c = newLead.LeadSource;
            }
        }
    }
    public static void setInterestedEnterprise (List<Lead> newLeads) {
        Map<String, List<Lead>> mapLeadStatus = new Map<String, List<Lead>>();
        for (Lead newLead : newLeads) {
            if(newLead.EmpreendimentoInteresse__c == null){
                if(mapLeadStatus.containskey(newLead.EmpreendimentoInteresseWeb__c)){
                    mapLeadStatus.get(newLead.EmpreendimentoInteresseWeb__c).add(newLead);
                }else{
                    mapLeadStatus.put(newLead.EmpreendimentoInteresseWeb__c, new List<Lead>{newLead});
                }
            }
        }
        for(Empreendimento__c empreendimento : [Select Id, Name from Empreendimento__c where name =: mapLeadStatus.keyset()]){
            for(Lead ld : mapLeadStatus.get(empreendimento.name)){
                ld.EmpreendimentoInteresse__c = empreendimento.Id;
            }
        }
    }

    public static void verificarReiteracao(List<Lead> leadsEntrando) {
        for (Lead leadEntrando : leadsEntrando) {
            List<Lead> potentialDuplicateLeads = [
                SELECT Id, LastName, MobilePhone, Phone, Email, EmpreendimentoInteresse__c, LeadSource, Status , ltima_Reitera_o__c
                , QuantidadeDeReiteracoes__c  , EmpreendimentoInteresse__r.name
                FROM Lead
                WHERE LastName = :leadEntrando.LastName
                AND (
                    MobilePhone = :leadEntrando.MobilePhone OR
                    Phone = :leadEntrando.Phone OR
                    Email = :leadEntrando.Email
                )
                LIMIT 1
            ];

            if (!potentialDuplicateLeads.isEmpty()) {
                leadEntrando.Reiteracao__c = true;
            }
        }
    }
        
    
    
    public static void SetQuantidadeDeReiteracoes(List<Lead> leads){
        for(Lead lead : leads){
            if(lead.QuantidadeDeReiteracoes__c == null){
                lead.QuantidadeDeReiteracoes__c = 0;
            }
        }
    }
    public static void createTaskForReiteration(Lead leadExistente) {
        // Consultar o Lead novamente com todos os campos necessários
        leadExistente = [
            SELECT Id, LastName, MobilePhone, Email, LeadSource, ltima_Reitera_o__c, QuantidadeDeReiteracoes__c 
            FROM Lead 
            WHERE Id = :leadExistente.Id 
            LIMIT 1
        ];
    
        // Verificar se já existe uma tarefa aberta e completar a existente
        List<Task> tasksAbertas = [SELECT Id FROM Task WHERE WhoId = :leadExistente.Id AND Status = 'Open' LIMIT 1];
        if (!tasksAbertas.isEmpty()) {
            Task existingTask = tasksAbertas[0];
            existingTask.Status = 'Completed'; // Marcar a tarefa existente como completada
            update existingTask;
        }
    
        DateTime now = DateTime.now();
        leadExistente.ltima_Reitera_o__c = now;
        
        if (leadExistente.QuantidadeDeReiteracoes__c == null) {
            leadExistente.QuantidadeDeReiteracoes__c = 0;
        }
    
        leadExistente.QuantidadeDeReiteracoes__c += 1;
        update leadExistente;
    
        // Criar nova tarefa
        Task newTask = new Task(
            WhoId = leadExistente.Id,
            Subject = 'Reiteração',
            Status = 'Open',
            ActivityDate = Date.today().addDays(1),
            Description = 'Reiteração do Lead. Nome: ' + leadExistente.LastName 
                + ', Telefone: ' + leadExistente.MobilePhone 
                + ', Email: ' + leadExistente.Email 
                + ', Origem do Lead: ' + leadExistente.LeadSource 
                + ', Data e horário da interação: ' + DateTime.now().format('dd/MM/yyyy HH:mm:ss')
        );
    
        insert newTask;
    }
    
    
}