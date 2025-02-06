@isTest
public class EmpreendimentoHelperTest {

    @isTest
    public static void testVerifyEmpreendimentoCNPJPasses() {
        // Cria um registro fictício de Empreendimento__c para simular a entrada de teste
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Empreendimento Teste',
            CNPJEmpreendimento__c = '12345678000195' // CNPJ de exemplo
        );

        // Inicia o teste
        Test.startTest();
        
        // Insere o registro
        insert empreendimento;

        // Chama o método estático verifyEmpreendimentoCNPJ
        List<Empreendimento__c> empreendimentos = [SELECT Id, Name, CNPJEmpreendimento__c FROM Empreendimento__c WHERE Id = :empreendimento.Id];
        EmpreendimentoHelper.verifyEmpreendimentoCNPJ(empreendimentos);

        // Termina o teste
        Test.stopTest();
    }
}