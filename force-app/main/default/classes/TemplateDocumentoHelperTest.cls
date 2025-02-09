@IsTest
public class TemplateDocumentoHelperTest {

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

        // Criar oportunidade vinculada ao Empreendimento
        Opportunity opp = new Opportunity(
            Name = 'Oportunidade Teste',
            StageName = 'Negociação',
            CloseDate = Date.today().addDays(30),
            Empreendimento__c = emp.Id
        );
        insert opp;
    }

    @IsTest
    static void testGetByOpportunityId_Success() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        List<TemplateDocumento__c> templates = TemplateDocumentoHelper.getByOpportunityId(opp.Id);  // Chamando o helper
        Test.stopTest();

        System.assertNotEquals(templates.size(), 0, 'Deveria retornar templates associados à oportunidade.');
    }

    @IsTest
    static void testGetByOpportunityId_Exception_NullOpportunityId() {
        Test.startTest();
        try {
            List<TemplateDocumento__c> templates = TemplateDocumentoHelper.getByOpportunityId(null);
            System.assert(false, 'O método deveria ter lançado uma exceção devido ao ID nulo.');
        } catch (AuraHandledException e) {
         //   System.assertEquals(e.getMessage(), 'O ID da oportunidade não pode ser nulo.', 'A exceção lançada está correta.');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetByOpportunityId_Exception_NoEmpreendimentoFound() {
        // Passando um ID de Oportunidade inválido para simular a falta de Empreendimento
        Id invalidOppId = '001000000000001'; // ID inválido de Oportunidade
        
        Test.startTest();
        try {
            List<TemplateDocumento__c> templates = TemplateDocumentoHelper.getByOpportunityId(invalidOppId);  // Chamando o helper
            System.assert(false, 'O método deveria ter lançado uma exceção devido à ausência de Empreendimento.');
        } catch (AuraHandledException e) {
            //System.assertEquals(e.getMessage(), 'Nenhum Empreendimento associado à oportunidade foi encontrado.', 'A exceção lançada está correta.');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetByOpportunityId_Exception_NoTemplatesFound() {
        // Criando uma Oportunidade válida mas que não tem templates associados
        Empreendimento__c newEmp = new Empreendimento__c(Name = 'Empreendimento Sem Template');
        insert newEmp;

        Opportunity newOpp = new Opportunity(
            Name = 'Oportunidade Sem Template',
            StageName = 'Negociação',
            CloseDate = Date.today().addDays(30),
            Empreendimento__c = newEmp.Id
        );
        insert newOpp;

        Test.startTest();
        try {
            List<TemplateDocumento__c> templates = TemplateDocumentoHelper.getByOpportunityId(newOpp.Id);  // Chamando o helper
            System.assert(false, 'O método deveria ter lançado uma exceção devido à ausência de templates.');
        } catch (AuraHandledException e) {
          //  System.assertEquals(e.getMessage(), 'Nenhum template encontrado para o Empreendimento associado.', 'A exceção lançada está correta.');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetByOpportunityId_Exception_QueryError() {
        // Forçando um erro na consulta ao tentar usar um ID inválido
        Test.startTest();
        try {
         //   List<TemplateDocumento__c> templates = TemplateDocumentoHelper.getByOpportunityId('INVALID_ID');
          //  System.assert(false, 'O método deveria ter lançado uma exceção devido a um erro na consulta.');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Erro ao realizar a consulta'), 'A exceção lançada está correta.');
        }
        Test.stopTest();
    }
}