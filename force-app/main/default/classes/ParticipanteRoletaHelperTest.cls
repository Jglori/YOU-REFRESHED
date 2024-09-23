@isTest
public class ParticipanteRoletaHelperTest {

    @isTest
    static void testSetParticipanteName() {
        // Configurar dados de teste
        // Criar um registro de RoletaLeads__c para associar aos participantes
        RoletaLeads__c roletaLeads = new RoletaLeads__c(Name = 'Roleta Teste');
        insert roletaLeads;

        // Criar participantes associados ao RoletaLeads__c
        List<ParticipanteRoleta__c> participantes = new List<ParticipanteRoleta__c>();
        for (Integer i = 0; i < 3; i++) {
            ParticipanteRoleta__c participante = new ParticipanteRoleta__c();
            participante.Name = 'Participante ' + i;
            participante.RoletaLeads__c = roletaLeads.Id; // Associar ao RoletaLeads__c criado
            participantes.add(participante);
        }
        
        // Inserir os registros para que eles tenham Ids e possam ser atualizados
        insert participantes;
        
        // Modificar os nomes dos participantes para simular uma mudança
        for (ParticipanteRoleta__c p : participantes) {
            p.Name = 'Novo Nome ' + p.Id;
        }
        
        // Executar o método que será testado
        Test.startTest();
        ParticipanteRoletaHelper.setParticipanteName(participantes);
        Test.stopTest();
        
        // Recarregar os registros do banco de dados para verificar as alterações
        List<ParticipanteRoleta__c> updatedParticipantes = [
            SELECT Id, Name FROM ParticipanteRoleta__c WHERE Id IN :participantes
        ];
        
      
    }
}