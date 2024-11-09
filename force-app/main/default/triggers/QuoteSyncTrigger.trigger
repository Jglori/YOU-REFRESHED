trigger QuoteSyncTrigger on Quote (before insert, before update) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        QuoteSyncTriggerHandler.handleBeforeInsertOrUpdate(Trigger.new);
    }
}