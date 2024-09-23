trigger LeadTrigger on Lead (before update, before insert , before delete, after update, after insert, after delete, after undelete) {
    new LeadTriggerHandler().run();
}