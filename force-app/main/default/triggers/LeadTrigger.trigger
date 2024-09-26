trigger LeadTrigger on Lead (before update, before insert, after insert, after update) {
       new LeadTriggerHandler().run();
}