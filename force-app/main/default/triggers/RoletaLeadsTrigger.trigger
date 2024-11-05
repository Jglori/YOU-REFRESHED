trigger RoletaLeadsTrigger on RoletaLeads__c (after insert, after update) {
    new RoletaLeadsTriggerHandler().run();
}