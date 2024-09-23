@isTest
public class RoletaLeadsDTOTest {

    @testSetup
    static void setup() {
        // Criar um registro RoletaLeads__c para o teste
        RoletaLeads__c roletaLeads = new RoletaLeads__c(
            Name = 'Roleta Teste',
            CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone;Loja;Stand',
            HoraInicio__c = Time.newInstance(9, 0, 0, 0),
            HoraFim__c = Time.newInstance(18, 0, 0, 0)
        );
        insert roletaLeads;
    }

    @isTest
    static void testRoletaLeadsDTO() {
        // Obter o registro RoletaLeads__c criado no setup
        RoletaLeads__c roletaLeads = [SELECT Id, Name, CanaisAtendimento__c, HoraInicio__c, HoraFim__c FROM RoletaLeads__c LIMIT 1];

        // Criar uma instância do DTO com o registro de RoletaLeads__c
        RoletaLeadsDTO dto = new RoletaLeadsDTO(roletaLeads);

        // Verificar se os valores foram corretamente atribuídos
        System.assertEquals(roletaLeads.Id, dto.id, 'O campo Id deveria ser igual');
        System.assertEquals(roletaLeads.Name, dto.nome, 'O campo Nome deveria ser igual');
        System.assertEquals(roletaLeads.CanaisAtendimento__c, dto.canaisAtendimento, 'O campo CanaisAtendimento deveria ser igual');
        System.assertEquals(roletaLeads.HoraInicio__c, dto.horaInicio, 'O campo HoraInicio deveria ser igual');
        System.assertEquals(roletaLeads.HoraFim__c, dto.horaFim, 'O campo HoraFim deveria ser igual');
    }
}