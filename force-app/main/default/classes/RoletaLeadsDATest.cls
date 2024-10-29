@isTest
private class RoletaLeadsDATest {
    
    @isTest
    static void testLimparParticipantesRoleta() {
      
        RoletaLeads__c roleta = new RoletaLeads__c(Name = 'Roleta Teste Limpar Participantes');
        insert roleta;
        
        
        List<ParticipanteRoleta__c> participantes = new List<ParticipanteRoleta__c>();
        participantes.add(new ParticipanteRoleta__c(RoletaLeads__c = roleta.Id));
        participantes.add(new ParticipanteRoleta__c(RoletaLeads__c = roleta.Id));
        insert participantes;
        
        Test.startTest();
       
        RoletaLeadsDA.limparParticipantesRoleta(roleta.Id);
        Test.stopTest();
        
     
        List<ParticipanteRoleta__c> participantesExistentes = [SELECT Id FROM ParticipanteRoleta__c WHERE RoletaLeads__c = :roleta.Id];
        System.assertEquals(0, participantesExistentes.size(), 'Deveria ter excluído todos os participantes associados à roleta.');
    }
}