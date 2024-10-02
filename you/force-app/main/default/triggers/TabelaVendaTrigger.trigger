trigger TabelaVendaTrigger on TabelaVendas__c (after insert, after update) {
    new TabelaVendaHandler().run();
}