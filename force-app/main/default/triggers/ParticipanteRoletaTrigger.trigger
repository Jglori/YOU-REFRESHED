trigger ParticipanteRoletaTrigger on ParticipanteRoleta__c (before insert, before update, after insert, after update) {
    new ParticipantesRoletasTriggerHandler().run();
}