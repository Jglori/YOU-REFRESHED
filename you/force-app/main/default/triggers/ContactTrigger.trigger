trigger ContactTrigger on Contact (before insert, after insert, before update, after update) {
    ContatoTriggerHandler handler = new ContatoTriggerHandler();
    handler.run();
}