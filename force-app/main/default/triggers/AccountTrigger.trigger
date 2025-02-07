trigger AccountTrigger on Account (before update, before insert , before delete, after update, after insert, after delete, after undelete) {
    new AccountTriggerHandler().run();
}