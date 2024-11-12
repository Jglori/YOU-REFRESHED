trigger EventTrigger on Event (before insert, before update, after insert, after update) {
    new EventTriggerHandler().run();
}