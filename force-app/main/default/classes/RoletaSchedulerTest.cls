@isTest
private class RoletaSchedulerTest {
    @isTest
    static void testRoletaSchedulerExecution() {
        RoletaLeads__c roleta = new RoletaLeads__c(); 
        insert roleta;

        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(RoletaLeads__c = 'a0Y89000001YSvLEAW');
        insert participante;

        List<ParticipanteRoleta__c> participantesAntes = [SELECT Id FROM ParticipanteRoleta__c WHERE RoletaLeads__c = 'a0Y89000001YSvLEAW'];
        System.assertEquals(1, participantesAntes.size(), 'Deve haver um participante antes da execução do agendador.');

        RoletaScheduler scheduler = new RoletaScheduler('a0Y89000001YSvLEAW');

        Test.startTest();
        scheduler.execute(null);
        Test.stopTest();

        List<ParticipanteRoleta__c> participantesDepois = [SELECT Id FROM ParticipanteRoleta__c WHERE RoletaLeads__c = 'a0Y89000001W8l4EAC'];
        System.assertEquals(0, participantesDepois.size(), 'Não deve haver participantes após a execução do agendador.');
    }
}