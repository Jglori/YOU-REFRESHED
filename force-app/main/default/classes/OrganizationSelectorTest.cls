@isTest
private class OrganizationSelectorTest {

    @isTest
    static void testObterNomeOrganizacao() {
        // Inicia o contexto de teste
        Test.startTest();
        
        // Invoca o método da classe OrganizationSelector
        Organization org = OrganizationSelector.obterNomeOrganizacao();
        
        // Verifica se o resultado não é nulo
        System.assertNotEquals(null, org, 'A organização retornada deve ser diferente de nula');
        
        // Verifica se o campo Name da organização não é nulo ou vazio
        System.assertNotEquals(null, org.Name, 'O nome da organização não deve ser nulo');
        System.assertNotEquals('', org.Name, 'O nome da organização não deve estar vazio');
        
        // Finaliza o contexto de teste
        Test.stopTest();
    }
}