public with sharing class GerarContratoController {
    public String conteudo { get; set; }

    public GerarContratoController() {
        String oppId = ApexPages.currentPage().getParameters().get('oppId');
        String templateId = ApexPages.currentPage().getParameters().get('templateId');

        Opportunity opp = OpportunityDA.getById(oppId);
        TemplateDocumento__c template = TemplateDocumentoDA.getById(templateId);

        String docxml = ContratoService.contratoText(opp, template);

        conteudo = docxml;
    }
}