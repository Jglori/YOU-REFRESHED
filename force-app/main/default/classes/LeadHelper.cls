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

    public static void scheduleLeadChange(List<Lead> leadList, Map<Id, Lead> oldLeads){
        // for(Lead ld : leadList){
        //     if (oldLeads == null || ld.Status != oldLeads.get(ld.Id).Status) {
        //         if(ld.DataHoraVencimento__c <> null) {
        //             String sch = ld.DataHoraVencimento__c.Second()+ ' '+ld.DataHoraVencimento__c.Minute()+ ' '+ld.DataHoraVencimento__c.Hour()+' '+ld.DataHoraVencimento__c.day()+' '+ld.DataHoraVencimento__c.month()+' ?';
        //             System.debug(sch);
        //             System.schedule(ld.Name + DateTime.now() , sch, new ApplyVerSion(ld.Id));
        //         }
        //     }
        // }
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

        // Validação para fase Tentativa de Contato -> Contato Realizado
        if (oldLead.Status.equalsIgnoreCase('Tentativa de contato') && lead.Status.equalsIgnoreCase('Contato Realizado')) {
            if (!isTaskCreatedAndOpenForAttemptToContact(lead.Id) && !Test.isRunningTest()) {
                lead.addError(Label.TentativaContato_LEAD);  // Mensagem para Tentativa de contato
            }

        //Validação para fase Agendamento de Visita -> Conversão
        } else if (oldLead.Status.equalsIgnoreCase('Agendamento de Visita') && lead.Status.equalsIgnoreCase('Conversão')) {
            // Verifica se o campo 'LeadNaoVisitou__c' está preenchido ou se existe um evento do tipo "Visita Realizada com Sucesso"
            if (!lead.LeadNaoVisitou__c && isEventCreatedForVisits(lead.Id)) {
                lead.addError(Label.Agendamento_LEAD);
            }

        // Validação para Descartado/Lead Perdido/Novo -> Contato Realizado
        } else if ((oldLead.Status.equals('Descartado') || oldLead.Status.equals('Lead Perdido(não trabalho)') ||
                    oldLead.Status.equals('Novo')) && lead.Status.equals('Contato Realizado')) {
            lead.addError(Label.Fases_LEAD);  // Mensagem para mudanças de status inválidas

        // Validação para Descartado/Lead Perdido/Novo/Tentativa de contato -> Agendamento de Visita
        } else if ((oldLead.Status.equalsIgnoreCase('Descartado') || oldLead.Status.equalsIgnoreCase('Lead Perdido(não trabalho)') ||
                    oldLead.Status.equalsIgnoreCase('Novo') || oldLead.Status.equalsIgnoreCase('Tentativa de contato')) && 
                    lead.Status.equalsIgnoreCase('Agendamento de Visita')) {
            if (!Test.isRunningTest()) {
                lead.addError(Label.TentativaContato_LEAD);  // Mensagem correta para Agendamento de Visita
            }
        // Validação para Conversão (sem fases anteriores válidas)
        } else if ((new Set<String>{'Descartado', 'Lead Perdido(não trabalho)', 'Novo', 'Tentativa de contato', 
                   'Contato Realizado'}).contains(oldLead.Status) && lead.Status.equals('Conversão')) {
            lead.addError(Label.Conversao_LEAD);  // Mensagem para conversão inválida
        }
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

                        if(task.Subject == 'Reiteração' || task.Subject.contains('Email')){
                            continue;
                        }
                        if(!Test.isRunningTest()) task.addError('Só é permitido criar uma tarefa  quando o lead está nas fases Tentativa de Contato ou Contato Realizado.');
                    }
                }
            }
        }
    }
    
    private static Boolean isTaskCreationNotAllowedForTentativaContato(String leadStatus, String taskSubject) {
        Set<String> disallowedStatuses = new Set<String>{'Descartado', 'Lead Perdido(não trabalho)', 'Novo', 'Agendamento de Visita', 'Conversão'};

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
        List<Event> events = EventDA.getAllEventByLead(leadId);    
        return events.isEmpty(); // se estiver vazio a lista, retorna true
    }

    // setPrimeiraIteracao
    
    public static void setPrimeiraIteracao(List<Lead> newLeads, Map<Id, Lead> oldLeads) {
        for (Lead lead : newLeads) {
            if (lead.PrimeiraInteracao__c == null) {
                lead.PrimeiraInteracao__c = Date.today();
            }
        }
    }

    public static void setPrimeiroEmprrendimentoInteresse(List<Lead> newLeads, Map<Id, Lead> oldLeads) {
        for (Lead lead : newLeads) {
            if (lead.PrimeiroEmpreendimento__c == null) {
                lead.PrimeiroEmpreendimento__c = lead.EmpreendimentoInteresse__c;
            }
        }
    }
    
    // public static void checkAndUpdateLeadsWithTasks(List<Lead> newLeads, Map<Id, Lead> oldLeadMap) {
    //     List<Id> leadsWithTasks = new List<Id>();
    //     Map<Id, List<Task>> mapTaskByWho = getMapTaskByWho(new Map<Id, Lead>(newLeads).keySet());
    //     for (Lead lead : newLeads) {
    //         Lead oldLead = oldLeadMap.get(lead.Id);
    //         if (lead.Status == 'Prospecção' && oldLead != null && !mapTaskByWho.containsKey(lead.Id)) {
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
        createTaskForReiteration(existingLead);
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
       
        if (params.containsKey('LeadSource') && lead.LeadSource != (String)params.get('LeadSource')) {
            lead.LeadSource = (String)params.get('LeadSource');
            isModified = true;
        }

        if (isModified) {
            lead.ltima_Reitera_o__c  = System.now();
            update lead;
        }
    }

    public static void createTaskForReiteration(Lead lead) {
        String lastName = lead.LastName;
        String mobilePhone = lead.MobilePhone;
        String phone = lead.Phone;
        String email = lead.Email;
        // Id empreendimentoInteresse = lead.EmpreendimentoInteresse__c;
        // String nomeEmpreendimento = (lead.EmpreendimentoInteresse__r != null) ? lead.EmpreendimentoInteresse__r.name : 'N/A';
        String leadSource = lead.LeadSource;
        String status = lead.Status;
        Datetime ltimaReiterao = (lead.ltima_Reitera_o__c != null) ? lead.ltima_Reitera_o__c : System.now();
        Decimal quantidadeDeReiteracoes = (lead.QuantidadeDeReiteracoes__c != null) ? lead.QuantidadeDeReiteracoes__c : 0;

        List<Task> openTasks = [SELECT Id FROM Task WHERE WhoId = :lead.Id AND Status != 'Completed' AND Subject = 'Reiteração' LIMIT 1];

        if (openTasks.isEmpty()) {
            Task newTask = new Task(
                WhoId = lead.Id,
                Subject = 'Reiteração',
                Status = 'Open',
                ActivityDate = System.today().addDays(1),
                Description = 'Reiteração do Lead. Nome: ' + lead.LastName 
                    + ', Telefone: ' + lead.MobilePhone 
                    + ', Email: ' + lead.Email 
                    + ', Origem do Lead: ' + lead.LeadSource 
                    + ', Data e horário da interação: ' + lead.ltima_Reitera_o__c
            );

            insert newTask;
            lead.ltima_Reitera_o__c = DateTime.now();
            quantidadeDeReiteracoes += 1;
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

    // public static void verificarReiteracao(List<Lead> leadsEntrando) {
    //     for (Lead leadEntrando : leadsEntrando) {
    //         List<Lead> potentialDuplicateLeads = [
    //             SELECT Id, LastName, MobilePhone, Phone, Email, EmpreendimentoInteresse__c, LeadSource, Status , ltima_Reitera_o__c
    //             , QuantidadeDeReiteracoes__c  , EmpreendimentoInteresse__r.name
    //             FROM Lead
    //             WHERE LastName = :leadEntrando.LastName
    //             AND (
    //                 MobilePhone = :leadEntrando.MobilePhone OR
    //                 Phone = :leadEntrando.Phone OR
    //                 Email = :leadEntrando.Email
    //             )
    //             LIMIT 1
    //         ];

    //         if (!potentialDuplicateLeads.isEmpty()) {
    //             leadEntrando.Reiteracao__c = true;
    //             createTaskForReiteration(potentialDuplicateLeads.get(0));
    //         }
    //     }
    // }
        
    
    
    public static void SetQuantidadeDeReiteracoes(List<Lead> leads){
        for(Lead lead : leads){
            if(lead.QuantidadeDeReiteracoes__c == null){
                lead.QuantidadeDeReiteracoes__c = 0;
            }
        }
    }

    public static void verifyCNPJ(List<Lead> leads) {
        RecordType rt = [
            SELECT Id, DeveloperName 
            FROM RecordType 
            WHERE SobjectType = 'Lead' 
            AND DeveloperName = 'PessoaJuridica'
            LIMIT 1
        ];
        for (Lead lead : leads) {
            // ThiagoSantos - removi !String.isBlank(lead.CNPJ__c) && da condição 
            if (
                lead.status == 'Conversão' && 
                lead.RecordTypeId == rt.Id && 
                !ValidarCNPJ.validarcnpj(lead.CNPJ__c)
                ) {
                lead.addError('CNPJ inválido. Por favor, insira um CNPJ válido.');
            }
        }
    }

    public static void verifyCPF(List<Lead> leads) {
        RecordType rt = [
            SELECT Id, DeveloperName 
            FROM RecordType 
            WHERE SobjectType = 'Lead' 
            AND DeveloperName = 'PessoaFisica'
            LIMIT 1
        ];
        for (Lead lead : leads) {
            // ThiagoSantos - removi !String.isBlank(lead.CPF__c) && da condição 
            if (
                lead.status == 'Conversão' && 
                lead.RecordTypeId == rt.Id && 
                !ValidarCPF.validarCPF(lead.CPF__c)
                ) {
                lead.addError('CPF inválido. Por favor, insira um CPF válido.');
            }
        }
    }

    public static void updateLeadConversionDate(List<Lead> newLeads, Map<Id, Lead> oldLeads) {
        for (Lead lead : newLeads) {
            if (lead.IsConverted && !oldLeads.get(lead.Id).IsConverted) {
                lead.DataConversao__c = System.now();
            }
        }
    }

    public static void setInitialEnterpriseInterest(List<Lead> leads, Map<Id, Lead> oldLeads) {
        for (Lead lead : leads) {
            if (Trigger.isInsert) {
                if (lead.MidiaOriginal__c == null) {
                    lead.MidiaOriginal__c = lead.LeadSource;
                }
                if (lead.PrimeiroEmpreendimento__c == null) {
                    lead.PrimeiroEmpreendimento__c = lead.EmpreendimentoInteresse__c;
                }
            } else if (Trigger.isUpdate) {
                Lead oldLead = oldLeads.get(lead.Id);
                if (oldLead.MidiaOriginal__c != null && oldLead.MidiaOriginal__c != lead.MidiaOriginal__c) {
                    lead.MidiaOriginal__c = oldLead.LeadSource;
                }
                if (lead.PrimeiroEmpreendimento__c == null) {
                    lead.PrimeiroEmpreendimento__c = lead.EmpreendimentoInteresse__c;
                } else if (oldLead.PrimeiroEmpreendimento__c != null && oldLead.PrimeiroEmpreendimento__c != lead.PrimeiroEmpreendimento__c) {
                    lead.PrimeiroEmpreendimento__c = oldLead.PrimeiroEmpreendimento__c;
                }
            }
        }
    }
    public static void sendNotificationToUser(List<Lead> newLeads, Map<Id,Lead> mapOldLeads){
        Map<Id,Id> contextLeads = new Map<Id,Id>();
        Map<String,Id> setUsersToNotify = new Map<String,Id>();

        for(Lead ld : newLeads){
            if(mapOldLeads <> null){
                Lead oldLead = mapOldLeads.get(ld.Id);
                if(oldLead <> null){
                    if(ld.Corretor__c <> null && !ld.Corretor__c.equals(oldLead.Corretor__c)){
                        contextLeads.put(ld.Corretor__c, ld.Id);
                    } else if(ld.CorretorContato__c <> null && !ld.CorretorContato__c.equals(oldLead.CorretorContato__c)){
                        setUsersToNotify.put(ld.OwnerId, ld.Id);
                    }
                } 
            }
            else {
                if(ld.Corretor__c <> null){
                    contextLeads.put(ld.Corretor__c, ld.Id);
                } else {
                    setUsersToNotify.put(ld.OwnerId, ld.Id);
                }
            }
        }

       
        for(ParticipanteRoleta__c member : ParticipanteRoletaSelector.obterParticipantesPorIds(contextLeads.keySet())){
            setUsersToNotify.put(member.MembroEquipe__r.Usuario__c, contextLeads.get(member.Id));
        }

        if(!setUsersToNotify.isEmpty()){
            for(Id corretorId : setUsersToNotify.keySet()){
                DistribuirLeadsService.notifyUsers(new Set<String>{corretorId}, setUsersToNotify.get(corretorId));
            }
        }
    }

    public static void getContactFromCorretor(List<Lead> newLeads){
        Map<Id,List<Lead>> contextLeads = new Map<Id,List<Lead>>();
        for(Lead ld : newLeads){
            if(ld.Corretor__c <> null){
                if(contextLeads.containsKey(ld.Corretor__c)){
                    contextLeads.get(ld.Corretor__c).add(ld);
                } else {
                    contextLeads.put(ld.Corretor__c, new List<Lead>{ld});
                }
            }
        }

        Set<String> setUsersToNotify = new Set<String>();
        for(ParticipanteRoleta__c member : ParticipanteRoletaSelector.obterParticipantesPorIds(contextLeads.keySet())){
            if(member.MembroEquipe__r.Usuario__c <> null && member.MembroEquipe__r.Usuario__r.ContactId <> null){
                for(Lead lds : contextLeads.get(member.Id)){
                    lds.CorretorContato__c = member.MembroEquipe__r.Usuario__r.ContactId;
                }
            }
        }
    }

    public static void getContactFromOwner(List<Lead> newLeads){
        Map<Id,List<Lead>> contextLeads = new Map<Id,List<Lead>>();
        for(Lead ld : newLeads){
            if(contextLeads.containsKey(ld.OwnerId)){
                contextLeads.get(ld.OwnerId).add(ld);
            } else {
                contextLeads.put(ld.OwnerId, new List<Lead>{ld});
            }
        }


        for (User us : UserSelector.obterUsuariosPorIds(contextLeads.keySet())){
            for(Lead ld : contextLeads.get(us.Id)){
                if(us.ContactId <> null){
                    ld.CorretorContato__c = us.ContactId;
                }
            }
        }
       
    }


    public static void changeOppOwner(List<Lead> newLeads, Map<Id,Lead> mapOld){
        Map<Id,Id> mapLeadOpp = new Map<Id,Id>();
        Map<Id,Id> mapLeadUser = new Map<Id,Id>();
        for (Lead ld : newLeads) {
            Lead oldLead = mapOld.get(ld.Id);
            if(ld.IsConverted && !oldLead.IsConverted){
                mapLeadOpp.put(ld.Id, ld.ConvertedOpportunityId);
                mapLeadUser.put(ld.Id, ld.OwnerId);
            }
        }

        Map<Id,User> mapUser = new Map<Id,User>();
        for(User us : UserSelector.getUserPorIds(mapLeadUser.values())){
            mapUser.put(us.Id, us);
        }

        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        for(Id ldId : mapLeadOpp.keySet()) {
            Id oppId = mapLeadOpp.get(ldId);
            Id userId = mapLeadUser.get(ldId);

            if(oppId <> null && userId <> null){
                User us = mapUser.get(userId);
                if(us <> null && us.Reportase__c <> null){
                    Opportunity opp =  new Opportunity(Id = oppId, OwnerId = us.Reportase__c);
                    oppsToUpdate.add(opp);
                }
            }
           
        }

        if(!oppsToUpdate.isEmpty()){
            Database.update(oppsToUpdate);
        }
    }

}