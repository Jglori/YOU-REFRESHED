@IsTest
public class TemplateControllerTest {

    @TestSetup
    static void setupData() {
        Account acc = new Account(Name = 'Conta Teste', CNPJ__c = '11084433000199');
        insert acc;

        Empreendimento__c emp = new Empreendimento__c();
        emp.Name = 'Empreendimento de Teste';
        emp.CNPJEmpreendimento__c = '11084433000199';
        insert emp;

        Opportunity opp = new Opportunity(
            Name = 'Oportunidade Teste',
            StageName = 'Negociação',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            Empreendimento__c = emp.Id
        );
        insert opp;

        TemplateDocumento__c activeTemplate = new TemplateDocumento__c(
            Name = 'Template Ativo',
            TipoTemplate__c = 'Contrato',
            ConteudoTemplate__c = 'Conteúdo Ativo',
            Empreendimento__c = emp.Id,
            Ativo__c = true
        );

        TemplateDocumento__c inactiveTemplate = new TemplateDocumento__c(
            Name = 'Template Inativo',
            TipoTemplate__c = 'Outro Documento',
            ConteudoTemplate__c = 'Conteúdo Inativo',
            Empreendimento__c = emp.Id,
            Ativo__c = false
        );

        insert new List<TemplateDocumento__c>{ activeTemplate, inactiveTemplate };
    }

    @IsTest
    static void testGetTemplates() {
        String oppId = [SELECT Id FROM Opportunity WHERE Name = 'Oportunidade Teste' LIMIT 1].Id;

        Test.startTest();
        
        List<TemplateDocumento__c> templates = TemplateController.getTemplates(oppId);
        
        Test.stopTest();
        
        System.assertEquals(1, templates.size(), 'Deveria retornar apenas o template ativo.');
        System.assertEquals('Template Ativo', templates[0].Name, 'Deveria retornar o template ativo com nome "Template Ativo".');
        System.assertEquals('Conteúdo Ativo', templates[0].ConteudoTemplate__c, 'O conteúdo do template deve ser "Conteúdo Ativo".');
    }
}