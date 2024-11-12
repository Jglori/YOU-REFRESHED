@isTest
public class ContratoServiceTest {
    @TestSetup
    static void makeData(){
        Empreendimento__c emp = new Empreendimento__c();
        emp.Name = 'Empreendimento de Teste';
        emp.CNPJEmpreendimento__c = '11084433000199';
        insert emp;
        
        TemplateDocumento__c template = new TemplateDocumento__c(Name = 'Template Test', Empreendimento__c = emp.Id, TipoTemplate__c = 'Contrato', ConteudoTemplate__c = 'Teste Opportunity.Name, OpportunityContactRole.Role', Ativo__c = true);
        insert template;

        Account acc = new Account(Name = 'Conta Teste', CNPJ__c = '11084433000199');
        insert acc;

        Contact cont = new Contact(FirstName = 'Contato', LastName = 'Teste', AccountId = acc.Id, CPF__c = '88637869092');
        insert cont;

        Bloco__c bloco = new Bloco__c(Name = 'Bloco Teste');
        insert bloco;

        Product2 prd = new Product2(Name = 'Produto Teste', Bloco__c = bloco.Id, Status__c = 'Reservada', NumeroDaUnidade__c = 101);
        insert prd;

        Opportunity opp = new Opportunity(AccountId = acc.Id, Name = 'Oportunidade de Teste', Unidade__c = prd.Id, Empreendimento__c = emp.Id, StageName = 'Negociação', CloseDate = Date.today());
        insert opp;

        Contract ctt = new Contract(Name = 'Contrato Teste', AccountId = acc.Id, Status = 'Rascunho', Oportunidade__c = opp.Id);
        insert ctt;

        OpportunityContactRole role = new OpportunityContactRole(Role = 'Fiador', ContactId = cont.Id, OpportunityId = opp.Id);
        insert role;
    }

    @isTest
    static void testContratoText(){
        Opportunity opp = [SELECT Id, Empreendimento__c, AccountId, Unidade__c, Name FROM Opportunity LIMIT 1];
        TemplateDocumento__c template = [SELECT Id, ConteudoTemplate__c FROM TemplateDocumento__c LIMIT 1];
        OpportunityContactRole role = [SELECT Id, Role, ContactId FROM OpportunityContactRole WHERE OpportunityId = :opp.Id LIMIT 1];
        Contact cont = [SELECT Id, Name FROM Contact WHERE Id = :role.ContactId LIMIT 1];

        String text = ContratoService.contratoText(opp, template);
        System.assertNotEquals(null, text);
        System.assertEquals('Teste '+ opp.Name + ', ' + cont.Name + ' - '+ role.Role, text);
    }

    @isTest
    static void testAtualizarPrazoAssinatura(){
        Contract ctt = [SELECT Id, Status, CustomerSignedDate, PrazoAssinatura__c FROM Contract LIMIT 1];

        Test.startTest();
        ContratoService.atualizarPrazoAssinatura(new List<Contract>{ctt});
        Test.stopTest();
    }


    @IsTest
    static void testEvitarGeracaoMultipla() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contract contrato1 = [SELECT Id, Status, Oportunidade__c FROM Contract WHERE Oportunidade__c = :opp.Id LIMIT 1];

        contrato1.Status = 'Contrato Gerado';
        Test.startTest();
        try {
            ContratoService.evitarGeracaoMultipla(new List<Contract>{ contrato1 });
            update contrato1; 
        } catch (Exception e) {
            System.assert(false, 'Nenhuma exceção deveria ter sido lançada: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testVerificaPrazoAssinatura() {
        Opportunity opp = [SELECT Id, StageName, Unidade__c, Empreendimento__c FROM Opportunity LIMIT 1];

        Account acct  = [SELECT Id FROM Account LIMIT 1];
        Contact contato = [SELECT Id, Name FROM Contact WHERE AccountId = :acct.Id LIMIT 1];
        
        OpportunityContactRole role = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId = :opp.Id LIMIT 1];

        Contract contrato = [SELECT Id, Status, CustomerSignedDate, PrazoAssinatura__c, Oportunidade__c FROM Contract LIMIT 1];

        Test.startTest();
        ContratoService.verificaPrazoAssinatura(new List<Contract>{ contrato });
        Test.stopTest();
    }
}