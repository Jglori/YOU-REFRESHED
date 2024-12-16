trigger ProdutoTrigger on Product2 (before insert, before update, after insert, after update) {
    new ProdutoTriggerHandler().run();
}