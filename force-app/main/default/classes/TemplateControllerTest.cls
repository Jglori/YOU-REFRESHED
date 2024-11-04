@isTest
public class TemplateControllerTest {
    @TestSetup
    static void makeData(){
        Empreendimento__c emp = new Empreendimento__c();
        emp.Name = 'Empreendimento de Teste';
        emp.CNPJEmpreendimento__c = '11084433000199';
        insert emp;

        TemplateDocumento__c template = new TemplateDocumento__c(Name = 'Template Test', Empreendimento__c = emp.Id, TipoTemplate__c = 'Contrato', ConteudoTemplate__c = 'Teste de conteudo', Ativo__c = true);
        insert template;

        Opportunity opp = new Opportunity(Name = 'Oportunidade de Teste', Empreendimento__c = emp.Id, StageName = 'Negociação', CloseDate = Date.today());
        insert opp;
    }

    @isTest
    static void testGetTemplates(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        List<TemplateDocumento__c> templates = TemplateController.getTemplates(opp.Id);
        Test.stopTest();

        System.assertEquals(1, templates.size());
    }
}