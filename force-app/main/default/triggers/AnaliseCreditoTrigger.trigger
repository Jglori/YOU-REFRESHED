trigger AnaliseCreditoTrigger on AnaliseCredito__c (before insert, before update, after insert, after update) {
    new AnaliseCreditoTriggerHandler().run();
}