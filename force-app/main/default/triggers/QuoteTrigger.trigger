trigger QuoteTrigger on Quote (after update) {
    new QuoteTriggerHandler().run();
}