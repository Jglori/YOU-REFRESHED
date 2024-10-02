trigger UnidadeTabelaVendasTrigger on UnidadeTabelaVendas__c (after update) {
    new UnidadeTabelaTriggerHandler().run();
}