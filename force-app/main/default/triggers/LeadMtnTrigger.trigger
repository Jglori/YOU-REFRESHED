trigger LeadMtnTrigger on Lead_MTN__c (before update, before insert , before delete, after update, after insert, after delete, after undelete) {
   new LeadMtnTriggerHandler().run();
}