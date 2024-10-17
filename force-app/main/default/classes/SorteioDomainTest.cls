@isTest
public class SorteioDomainTest {
    
    @isTest
    static void testObterIdsRoletas() {
        // Criar registros de RoletaLeads__c para referência
        RoletaLeads__c roleta1 = new RoletaLeads__c(Name = 'Roleta You - Corretores novo' , CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone;Loja;Stand' , DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira');
        insert roleta1;

        RoletaLeads__c roleta2 = new RoletaLeads__c(Name = 'Roleta You - Corretores novo' , CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone;Loja;Stand'  , DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado');
        insert roleta2;

        // Criar registros de Sorteio__c com referência aos registros de RoletaLeads__c
        Sorteio__c sorteio1 = new Sorteio__c(RoletaLeads__c = roleta1.Id);
        insert sorteio1;

        Sorteio__c sorteio2 = new Sorteio__c(RoletaLeads__c = roleta2.Id);
        insert sorteio2;

        // Obter a lista de Sorteio__c criada
        List<Sorteio__c> sorteios = [SELECT Id, RoletaLeads__c FROM Sorteio__c];

        Test.startTest();
        
        // Chamar o método para obter IDs de RoletaLeads
        Set<Id> idsRoletas = SorteioDomain.obterIdsRoletas(sorteios);
        
        Test.stopTest();

        // Verificar se os IDs de RoletaLeads foram retornados corretamente
        System.assertEquals(2, idsRoletas.size(), 'Deve haver dois IDs de RoletaLeads retornados');
        System.assert(idsRoletas.contains(roleta1.Id), 'Deve conter o ID do Roleta 1');
        System.assert(idsRoletas.contains(roleta2.Id), 'Deve conter o ID do Roleta 2');
    }
}