@isTest
private class ContractSelectorTest {

    @TestSetup
    static void makeData(){
        Account acc = new Account(Name = 'Conta Teste', CNPJ__c = '11084433000199');
        insert acc;

        Contact cont = new Contact(FirstName = 'Contato', LastName = 'Teste', AccountId = acc.Id, CPF__c = '88637869092');
        insert cont;

        Empreendimento__c emp = new Empreendimento__c();
        emp.Name = 'Empreendimento de Teste';
        emp.CNPJEmpreendimento__c = '11084433000199';
        insert emp;

        Opportunity opp = new Opportunity(Name = 'Oportunidade de Teste', Empreendimento__c = emp.Id, StageName = 'Negociação', CloseDate = Date.today());
        insert opp;

        Contract ctt = new Contract(Name = 'Contrato Teste', AccountId = acc.Id, Status = 'Rascunho', Oportunidade__c = opp.Id);
        insert ctt;
    }

    @isTest
    static void testGetById() {
        Contract ctr = [
            SELECT Id FROM Contract
        ];

        Test.startTest();
        Contract result = ContractSelector.getById(ctr.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Deveria vir um contrato como resultado.');
    }

    @isTest
    static void testGetContracts(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        Contract contract = ContractSelector.getContract(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, contract);
    }

    @isTest
    static void testGetContractsByOpps(){
        List<Opportunity> opps = [SELECT Id FROM Opportunity];

        Set<Id> oppIds = new Set<Id>();

        for(Opportunity opp : opps){
            oppIds.add(opp.Id);
        }

        Test.startTest();
        List<Contract> contracts = ContractSelector.getContractsByOpp(oppIds);
        Test.stopTest();

        System.assertNotEquals(null, contracts);
    }

    @IsTest
    static void testGetRolesContatoOpp() {
        Opportunity opp = [
            SELECT Id FROM Opportunity
        ];

        Test.startTest();
        List<OpportunityContactRole> result = ContractSelector.getRolesContatoOpp(opp.Id);
        Test.stopTest();
    }

    @IsTest
    static void testGetByOpportunityId() {
        Opportunity opp = [
            SELECT Id FROM Opportunity
        ];

        Test.startTest();
        List<Contract> result = ContractSelector.getByOpportunityId(opp.Id);
        Test.stopTest();

        List<Contract> expected = [
            SELECT Id FROM Contract
        ];

        System.assertEquals(expected.size(), result.size(), 'Deveria ter um contrato na lista');
    }
}