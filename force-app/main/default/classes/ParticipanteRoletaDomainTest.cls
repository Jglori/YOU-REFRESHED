@isTest
public class ParticipanteRoletaDomainTest {
    @testSetup
    static void setup() {
        // Criação de uma Roleta Leads de teste
        RoletaLeads__c roleta = new RoletaLeads__c(Name = 'Roleta Teste', Ativa__c = true);
        insert roleta;

        // Criar uma equipe
        Equipe__c equipe = new Equipe__c(Name = 'Equipe Teste');
        insert equipe;

        // Criação de um Membro de Equipe
        MembroEquipe__c membro = new MembroEquipe__c(Name = 'Membro Teste', Equipe__c = equipe.Id);
        insert membro;

        // Criação de Participantes Roleta
        List<ParticipanteRoleta__c> participantes = new List<ParticipanteRoleta__c>();
        for (Integer i = 0; i < 5; i++) {
            participantes.add(new ParticipanteRoleta__c(
                MembroEquipe__c = membro.Id,
                RoletaLeads__c = roleta.Id,
                Posicao__c = i + 1
            ));
        }
        insert participantes;
    }

    @isTest
    static void testObterParticipantesPorIdMembro() {
        // Obter dados de teste
        List<ParticipanteRoleta__c> participantes = [SELECT Id, MembroEquipe__c FROM ParticipanteRoleta__c];
        
        // Chamar o método a ser testado
        Map<Id, List<ParticipanteRoleta__c>> participantesPorIdMembro = ParticipanteRoletaDomain.obterParticipantesPorIdMembro(participantes);
        
        // Verificar resultados
        System.assertEquals(1, participantesPorIdMembro.size(), 'Deveria haver 1 entrada no mapa para um único membro de equipe.');
        System.assertEquals(5, participantesPorIdMembro.values().get(0).size(), 'Deveria haver 5 participantes para o membro da equipe.');
    }

    @isTest
    static void testObterParticipantesPorIdRoleta() {
        // Obter dados de teste
        List<ParticipanteRoleta__c> participantes = [SELECT Id, RoletaLeads__c FROM ParticipanteRoleta__c];
        
        // Chamar o método a ser testado
        Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoleta = ParticipanteRoletaDomain.obterParticipantesPorIdRoleta(participantes);
        
        // Verificar resultados
        System.assertEquals(1, participantesPorIdRoleta.size(), 'Deveria haver 1 entrada no mapa para uma única roleta.');
        System.assertEquals(5, participantesPorIdRoleta.values().get(0).size(), 'Deveria haver 5 participantes para a roleta.');
    }

    @isTest
    static void testObterParticipantesPorSorteios() {
        // Criar sorteios de teste
        RoletaLeads__c roleta = [SELECT Id FROM RoletaLeads__c LIMIT 1];
        Sorteio__c sorteio = new Sorteio__c(RoletaLeads__c = roleta.Id);
        insert sorteio;

        List<Sorteio__c> sorteios = [SELECT Id, RoletaLeads__c FROM Sorteio__c];

        // Chamar o método a ser testado
        List<ParticipanteRoleta__c> participantes = ParticipanteRoletaDomain.obterParticipantesPorSorteios(sorteios);
        
        // Verificar resultados
        System.assertEquals(5, participantes.size(), 'Deveria haver 5 participantes retornados para o sorteio.');
    }
}