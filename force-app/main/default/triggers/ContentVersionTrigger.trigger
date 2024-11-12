trigger ContentVersionTrigger on ContentVersion (after insert) {
    ContentVersionTriggerHandler handler = new ContentVersionTriggerHandler();
    handler.run();
}