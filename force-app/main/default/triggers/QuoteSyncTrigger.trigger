trigger QuoteSyncTrigger on Quote (before insert, before update) {
    new QuoteSyncTriggerHandler().run();
}