@isTest
public class ParticipanteRoletaSelectorTest {

    @testSetup
    static void setup() {
        // Criação de uma Roleta Leads de teste
        RoletaLeads__c roleta = new RoletaLeads__c(Name = 'Roleta Teste', Ativa__c = true);
        insert roleta;

        //Criar uma equipe
        Equipe__c eq = new Equipe__c(Name = 'eq');
        insert eq;

        // Criação de um Membro de Equipe
        MembroEquipe__c membro = new MembroEquipe__c(Name = 'Membro Teste', Equipe__c = eq.Id); // Certifique-se de preencher todos os campos obrigatórios
        insert membro;

        // Criação de um Participante Roleta
        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            MembroEquipe__c = membro.Id,
            RoletaLeads__c = roleta.Id,
            Posicao__c = 1
        );
        insert participante;
    }

    @isTest
    static void testObterParticipantesPorIdsMembros() {
        // Obtenção do ID do membro
        MembroEquipe__c membro = [SELECT Id FROM MembroEquipe__c LIMIT 1];

        Test.startTest();
        
        List<ParticipanteRoleta__c> participantes = ParticipanteRoletaSelector.obterParticipantesPorIdsMembros(new Set<Id>{membro.Id});
        
        Test.stopTest();
        
        // Verificação se o participante foi retornado
        //System.assertEquals(1, participantes.size(), 'Deve haver um participante retornado.');
    }

    @isTest
    static void testObterParticipantesPorIdsRoleta() {
        // Obtenção do ID da Roleta
        RoletaLeads__c roleta = [SELECT Id FROM RoletaLeads__c LIMIT 1];

        Test.startTest();
        
        List<ParticipanteRoleta__c> participantes = ParticipanteRoletaSelector.obterParticipantesPorIdsRoleta(new Set<Id>{roleta.Id});
        
        Test.stopTest();
        
        // Verificação se o participante foi retornado
        System.assertEquals(1, participantes.size(), 'Deve haver um participante retornado.');
    }

    @isTest
    static void testObterParticipantesPorIds() {
        // Obtenção do ID do Participante
        ParticipanteRoleta__c participante = [SELECT Id FROM ParticipanteRoleta__c LIMIT 1];

        Test.startTest();
        
        List<ParticipanteRoleta__c> participantes = ParticipanteRoletaSelector.obterParticipantesPorIds(new Set<Id>{participante.Id});
        
        Test.stopTest();
        
        // Verificação se o participante foi retornado
        System.assertEquals(1, participantes.size(), 'Deve haver um participante retornado.');
    }
}