trigger TaskTrigger on Task (before insert, before delete,before update ,  after delete, after insert, after update) {
    new TaskTriggerHandler().run();
}