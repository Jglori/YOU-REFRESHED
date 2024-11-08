@isTest
public class AnaliseCreditoDATest {
    
    @isTest
    public static void testGetById() {
        // Prepare test data
        List<AnaliseCredito__c> analises = new List<AnaliseCredito__c>();
        for (Integer i = 0; i < 5; i++) {
            analises.add(new AnaliseCredito__c(
                Name = 'Analise ' + i,
                NomeComprador__c = 'Comprador ' + i,
                Status__c = 'Aprovada'
            ));
        }
        insert analises;

        // Call the method to test
        Set<Id> ids = new Set<Id>();
        for (AnaliseCredito__c analise : analises) {
            ids.add(analise.Id);
        }

        List<AnaliseCredito__c> result = AnaliseCreditoDA.getById(ids);

        // Verify the results
        System.assertEquals(5, result.size(), 'A quantidade de registros retornados está incorreta.');
        System.assertEquals(analises[0].Id, result[0].Id, 'Os IDs não correspondem.');
    }

    @isTest
    public static void testGetOpportunityById() {
        // Prepare test data
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = '001XXXXXXXXXXXXXXX', // Use a valid Account ID for testing or create a mock Account
            StageName = 'Prospecting',
            Type = 'New Business'
        );
        insert opp;

        AnaliseCredito__c analise = new AnaliseCredito__c(
            Name = 'Test Analise',
            NomeComprador__c = 'Comprador Teste',
            Opportunity__c = opp.Id,
            Status__c = 'Aprovada'
        );
        insert analise;

        // Call the method to test
        List<Opportunity> result = AnaliseCreditoDA.getOpportunityById(analise.Id);

        // Verify the results
        System.assertEquals(1, result.size(), 'O número de oportunidades retornadas está incorreto.');
        System.assertEquals(opp.Id, result[0].Id, 'O ID da oportunidade não corresponde.');
    }

    @isTest
    public static void testGetByIdWithNullIds() {
        // Call the method with null or empty Set
        List<AnaliseCredito__c> result = AnaliseCreditoDA.getById(null);
        System.assertEquals(0, result.size(), 'O resultado não deveria ter registros.');
    }

    @isTest
    public static void testGetOpportunityByIdWithNullId() {
        // Call the method with null Id
        List<Opportunity> result = AnaliseCreditoDA.getOpportunityById(null);
        System.assertEquals(0, result.size(), 'O resultado não deveria ter oportunidades.');
    }
}