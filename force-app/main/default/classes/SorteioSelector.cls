public without sharing class SorteioSelector {
    public static List<Sorteio__c> obterSorteiosAtivos() {
        return [SELECT RoletaLeads__c, Status__c FROM Sorteio__c WHERE Inicio__c <= :System.now() AND Status__c = 'Criado'];
    }
}