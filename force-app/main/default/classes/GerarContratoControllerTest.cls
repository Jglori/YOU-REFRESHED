@isTest
public class GerarContratoControllerTest {

    @TestSetup
    static void makeData(){
         Empreendimento__c emp = new Empreendimento__c();
        emp.Name = 'Empreendimento de Teste';
        emp.CNPJEmpreendimento__c = '11084433000199';
        insert emp;

         Bloco__c bloco = new Bloco__c(
            Name = 'Nome do Bloco',
            DataLancamento__c = Date.today(),
            DataEntrega__c = Date.today().addMonths(12),
            Empreendimento__c = emp.Id,
            QuantidadeAndares__c = 10,
            TotalUnidades__c = 50
        );
        insert bloco;

         Product2 testProduct = new Product2(
            Name='Test Product',
            NumeroDaUnidade__c = 8,
            IsActive= true,
            Status__c = 'Reservada',
            Bloco__c = bloco.Id            
        );
        insert testProduct;

        Account conta = new Account();
        conta.Name = 'Test Account';
        conta.CNPJ__c = '11084433000199';
        insert conta;
        
        Opportunity testOpportunity = new Opportunity(
            Name='Test Opportunity',
            StageName='Negociação',
            CloseDate=System.today().addMonths(1),
            Empreendimento__c = emp.id,
            AccountId = conta.Id,
            Unidade__c = testProduct.Id
            );
        insert testOpportunity;

          TemplateDocumento__c template = new TemplateDocumento__c();
        template.Name = 'Test Template';
        template.ConteudoTemplate__c = 'Test Body Oportunidade: Opportunity.Name Empreendimento: Empreendimento__r.Name';
        template.Ativo__c = true;
        template.TipoTemplate__c = 'Contrato';
        template.Empreendimento__c = emp.Id;
        insert template;

        TemplateDocumento__c template1 = new TemplateDocumento__c();
        template1.Name = 'Test Template';
        template1.ConteudoTemplate__c = 'Test Body Oportunidade: Opportunity.Name Empreendimento: Empreendimento__r.Name';
        template1.Ativo__c = true;
        template1.TipoTemplate__c = 'Contrato';
        template1.Empreendimento__c = emp.Id;
        insert template1;
    }
    @isTest
    static void testGerarContratoController() {

    TemplateDocumento__c template = [SELECT Id FROM TemplateDocumento__c LIMIT 1];
    Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

    PageReference pageRef = Page.ContratoPDF;
    Test.setCurrentPage(pageRef);

    pageRef.getParameters().put('oppId', testOpportunity.Id);
    pageRef.getParameters().put('templateId', template.Id);
    Test.startTest();
    GerarContratoController controller = new GerarContratoController();
    Test.stopTest();

    }
}