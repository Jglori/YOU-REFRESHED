@isTest
public class EquipeDomainTest {

    @isTest
    static void testObterIdsEquipes() {
        // Criação de dados de teste
        Equipe__c equipe1 = new Equipe__c(Name = 'Equipe 1');
        Equipe__c equipe2 = new Equipe__c(Name = 'Equipe 2');
        insert new List<Equipe__c>{equipe1, equipe2};

        MembroEquipe__c membro1 = new MembroEquipe__c(Equipe__c = equipe1.Id);
        MembroEquipe__c membro2 = new MembroEquipe__c(Equipe__c = equipe2.Id);
        MembroEquipe__c membro3 = new MembroEquipe__c(Equipe__c = equipe1.Id);
        insert new List<MembroEquipe__c>{membro1, membro2, membro3};

        // Executar o método que está sendo testado
        List<MembroEquipe__c> membrosEquipes = [SELECT Id, Equipe__c FROM MembroEquipe__c];
        Set<Id> result = EquipeDomain.obterIdsEquipes(membrosEquipes);

        // Verificar os resultados
        System.assert(result.contains(equipe1.Id), 'O conjunto de IDs deve conter o ID da equipe 1');
        System.assert(result.contains(equipe2.Id), 'O conjunto de IDs deve conter o ID da equipe 2');
        System.assertEquals(2, result.size(), 'O conjunto de IDs deve conter exatamente 2 IDs de equipe');
    }
}