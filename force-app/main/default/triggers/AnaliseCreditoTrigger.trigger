trigger AnaliseCreditoTrigger on AnaliseCredito__c (before insert, before update) {
    new AnaliseCreditoTriggerHandler().run();
}