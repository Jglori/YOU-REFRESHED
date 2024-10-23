@isTest
public class ContractControllerTest {
    
    @TestSetup
    static void makeData(){
        
        Empreendimento__c emp = new Empreendimento__c();
        emp.Name = 'Empreendimento de Teste';
        emp.CNPJEmpreendimento__c = '11084433000199';
        insert emp;
        
        TemplateDocumento__c template = new TemplateDocumento__c(Name = 'Template Test', Empreendimento__c = emp.Id, TipoTemplate__c = 'Contrato', ConteudoTemplate__c = 'Teste de conteudo', Ativo__c = true);
        insert template;

        Account acc = new Account(Name = 'Conta Teste', CNPJ__c = '11084433000199');
        insert acc;

        Contact cont = new Contact(FirstName = 'Contato', LastName = 'Teste', AccountId = acc.Id, CPF__c = '88637869092');
        insert cont;

        Contract ctt = new Contract(Name = 'Contrato Teste', AccountId = acc.Id, Status = 'Rascunho');
        insert ctt;

        List<Opportunity> oppsTeste = new List<Opportunity>();

        Opportunity opp = new Opportunity(Name = 'Oportunidade de Teste', Empreendimento__c = emp.Id, StageName = 'Negociação', CloseDate = Date.today(), ContractId = ctt.Id);
        oppsTeste.add(opp);

        Opportunity opp2 = new Opportunity(Name = 'Oportunidade de Teste 2', Empreendimento__c = emp.Id, StageName = 'Negociação', CloseDate = Date.today(), ContractId = ctt.Id);
        oppsTeste.add(opp2);
        insert oppsTeste;

        OpportunityContactRole oppRole = new OpportunityContactRole(OpportunityId = opp.Id, Role = 'Comprador', ContactId = cont.Id);
        insert oppRole;
    }

    @isTest
    static void testInfoContrato(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        Contract ctt = ContractController.infoContrato(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, ctt);
    }

    @isTest
    static void testRolesContatoOpp(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Oportunidade de Teste' LIMIT 1];
        Opportunity opp2 = [SELECT Id FROM Opportunity WHERE Name = 'Oportunidade de Teste 2' LIMIT 1];

        List<OpportunityContactRole> roles = ContractController.rolesContatoOpp(opp.Id);
        System.Assert.isTrue(!roles.isEmpty());

        List<OpportunityContactRole> roles2 = ContractController.rolesContatoOpp(opp2.Id);
        System.Assert.isTrue(roles2.isEmpty());
    }

    @isTest
    static void testRetornarContratoGerado(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Oportunidade de Teste' LIMIT 1];
        TemplateDocumento__c template = [SELECT Id FROM TemplateDocumento__c LIMIT 1];

        Test.startTest();
        ContentVersion contVersion = ContractController.retornarContratoGerado(opp.Id, template.Id);
        Test.stopTest();

        System.assertNotEquals(null, contVersion);
    }


}