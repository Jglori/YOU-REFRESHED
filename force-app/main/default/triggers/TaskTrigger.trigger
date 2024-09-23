trigger TaskTrigger on Task (before insert, before delete, after delete, after insert, after update) {
    new TaskTriggerHandler().run();
}