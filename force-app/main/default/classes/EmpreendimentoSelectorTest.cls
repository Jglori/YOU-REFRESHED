@isTest
public class EmpreendimentoSelectorTest {

    @isTest
    static void testGetEmpreendimentoRecords() {
        
        Empreendimento__c emp1 = new Empreendimento__c(Name = 'Empreendimento A',CNPJEmpreendimento__c = '11084433000199');
        Empreendimento__c emp2 = new Empreendimento__c(Name = 'Empreendimento B',CNPJEmpreendimento__c = '11084433000199');
        insert new List<Empreendimento__c>{emp1, emp2};

        Test.startTest();
        
       
        List<Empreendimento__c> empreendimentos = EmpreendimentoSelector.getEmpreendimentoRecords();
        
        Test.stopTest();

       
        System.assertNotEquals(null, empreendimentos, 'A lista de empreendimentos não deve ser nula.');
        System.assertEquals(2, empreendimentos.size(), 'Deve haver 2 registros de empreendimentos.');

        // Verificar o conteúdo dos registros
        System.assertEquals('Empreendimento A', empreendimentos[0].Name, 'O nome do primeiro empreendimento deve ser "Empreendimento A".');
        System.assertEquals('Empreendimento B', empreendimentos[1].Name, 'O nome do segundo empreendimento deve ser "Empreendimento B".');
    }

    @isTest
    static void testObterNomeEmpreendimentoById() {
     
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Empreendimento Teste',CNPJEmpreendimento__c = '11084433000199');
        insert empreendimento;

        Test.startTest();
        
      
        Empreendimento__c result = EmpreendimentoSelector.obterNomeEmpreendimentoById(empreendimento.Id);
        
        Test.stopTest();

        
        System.assertNotEquals(null, result, 'O registro de empreendimento não deve ser nulo.');
        System.assertEquals(empreendimento.Id, result.Id, 'O ID deve ser o mesmo do registro criado.');
        System.assertEquals('Empreendimento Teste', result.Name, 'O nome do empreendimento deve ser "Empreendimento Teste".');
    }
}