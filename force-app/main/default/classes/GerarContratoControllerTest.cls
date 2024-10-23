@isTest
public class GerarContratoControllerTest {
    @isTest
    static void testGerarContratoController() {
        // Inserting a test opportunity
        
        Empreendimento__c emp = new Empreendimento__c();
        emp.Name = 'Empreendimento de Teste';
        emp.CNPJEmpreendimento__c = '11084433000199';
        insert emp;
        
        Opportunity testOpportunity = new Opportunity(
            Name='Test Opportunity',
            StageName='Negociação',
            CloseDate=System.today().addMonths(1),
            Empreendimento__c = emp.id
        );
        insert testOpportunity;

        // Inserting a test template
        TemplateDocumento__c template = new TemplateDocumento__c();
        template.Name = 'Test Template';
        template.ConteudoTemplate__c = 'Test Body Oportunidade: Opportunity.Name Empreendimento: Empreendimento__r.Name';
        template.Ativo__c = true;
        template.Empreendimento__c = emp.Id;
        insert template;
        // Committing the inserted template to the database
        

        // Creating a page reference
        PageReference pageRef = Page.ContratoPDF;
        Test.setCurrentPage(pageRef);

        // Setting the parameters
        pageRef.getParameters().put('oppId', testOpportunity.Id);
        pageRef.getParameters().put('templateId', template.Id);
Test.startTest();
GerarContratoController controller = new GerarContratoController();
Test.stopTest();

        // Asserting the content
        System.assertEquals('Test Body', controller.conteudo);
    }
}