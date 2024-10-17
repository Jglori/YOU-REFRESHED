public with sharing class LeadTriggerHandler extends TriggerHandler {
    
    public override void beforeUpdate() {
        LeadHelper.verifyCNPJ(Trigger.new);
        LeadHelper.verifyCPF(Trigger.new);
        LeadHelper.updateLeadConversionDate(Trigger.new, (Map<Id, Lead>) Trigger.oldMap);
        LeadHelper.setInitialEnterpriseInterest(Trigger.new, (Map<Id, Lead>) Trigger.oldMap);
        // LeadHelper.verifyLeadControlSLA(Trigger.new);
        LeadHelper.statusValidate(Trigger.new, (Map<Id, Lead>) Trigger.oldMap);
        // LeadHelper.checkAndUpdateLeadsWithTasks(Trigger.new, (Map<Id, Lead>) Trigger.oldMap);
        LeadHelper.verifyLeadControlSLA(Trigger.new, (Map<Id, Lead>) Trigger.oldMap);
        
        LeadHelper.additionalValidations(Trigger.new, (Map<Id, Lead>) Trigger.oldMap);
        // LeadHelper.verificarReiteracao(Trigger.new);
        LeadHelper.setLeadSource(Trigger.new);
        LeadHelper.setPrimeiraIteracao(Trigger.new, (Map<Id, Lead>) Trigger.oldMap);
        LeadHelper.setPrimeiroEmprrendimentoInteresse(Trigger.new, (Map<Id, Lead>) Trigger.oldMap);
        LeadHelper.getContactFromCorretor(Trigger.new);
        LeadHelper.getContactFromOwner(Trigger.new);

    }
    
    public override void beforeInsert(){
        LeadHelper.verifyCNPJ(Trigger.new);
        LeadHelper.verifyCPF(Trigger.new);
        LeadHelper.setInitialEnterpriseInterest(Trigger.new, null);
        LeadHelper.verifyLeadControlSLA(Trigger.new, (Map<Id, Lead>) Trigger.oldMap);
        LeadHelper.setInterestedEnterprise(Trigger.new);
        // LeadHelper.verificarReiteracao(Trigger.new);
        LeadHelper.setLeadSource(Trigger.new);
        LeadHelper.SetQuantidadeDeReiteracoes(Trigger.new);
        LeadHelper.getContactFromCorretor(Trigger.new);
        LeadHelper.getContactFromOwner(Trigger.new);
    }
    public override void afterUpdate(){
        LeadHelper.scheduleLeadChange(Trigger.new, (Map<Id, Lead>) Trigger.oldMap);
        DistribuirLeadsService.distribuirLeads((List<Lead>)Trigger.new);
        LeadHelper.sendNotificationToUser((List<Lead>)Trigger.new, (Map<Id, Lead>) Trigger.oldMap);
        LeadHelper.changeOppOwner((List<Lead>)Trigger.new, (Map<Id,Lead>) Trigger.oldMap);
    }

    public override void afterInsert(){
        LeadHelper.scheduleLeadChange(Trigger.new,(Map<Id,Lead>)Trigger.oldMap);
        DistribuirLeadsService.distribuirLeads((List<Lead>)Trigger.new);
        LeadHelper.sendNotificationToUser((List<Lead>)Trigger.new, (Map<Id, Lead>) Trigger.oldMap);

    }
 
    public static void scheduleLeadChange(List<Lead> leadList, Map<Id, Lead> oldLeads) {
        LeadHelper.scheduleLeadChange(leadList, oldLeads);
    }
}