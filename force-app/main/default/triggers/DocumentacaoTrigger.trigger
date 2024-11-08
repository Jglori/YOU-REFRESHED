trigger DocumentacaoTrigger on Documentacao__c (after insert, after update) {
    new DocumentacaoTriggerHandler().run();
}