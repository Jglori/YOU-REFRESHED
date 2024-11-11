@IsTest
public class TemplateSelectorTest {

    @TestSetup
    static void setupData() {
        Account acc = new Account(Name = 'Conta Teste', CNPJ__c = '11084433000199');
        insert acc;

        Empreendimento__c emp = new Empreendimento__c();
        emp.Name = 'Empreendimento de Teste';
        emp.CNPJEmpreendimento__c = '11084433000199';
        insert emp;

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
    static void testGetTemplatesByEmpId() {
        String empId = [SELECT Id FROM Empreendimento__c LIMIT 1].Id;

        Test.startTest();
        
        List<TemplateDocumento__c> templates = TemplateSelector.getTemplatesByEmpId(empId);
        
        Test.stopTest();
        
        System.assertEquals(1, templates.size(), 'Deveria retornar apenas o template ativo.');
        System.assertEquals('Template Ativo', templates[0].Name, 'Deveria retornar o template ativo com nome "Template Ativo".');
    }

    @IsTest
    static void testGetTemplateById() {
        String templateId = [SELECT Id FROM TemplateDocumento__c WHERE Name = 'Template Ativo' LIMIT 1].Id;

        Test.startTest();
        
        TemplateDocumento__c template = TemplateSelector.getTemplateById(templateId);
        
        Test.stopTest();
        
        System.assertNotEquals(null, template, 'Deveria retornar o template ativo.');
        System.assertEquals('Template Ativo', template.Name, 'Deveria retornar o template com nome "Template Ativo".');
        System.assertEquals('Conteúdo Ativo', template.ConteudoTemplate__c, 'O conteúdo do template deve ser "Conteúdo Ativo".');
    }
}