public with sharing class GerarContratoController {
    public String conteudo { get; set; }

    public GerarContratoController() {
        String oppId = ApexPages.currentPage().getParameters().get('oppId');

        String templateId = ApexPages.currentPage().getParameters().get('templateId');

        Opportunity opp = (Opportunity) QueryHelper.selectAllFields('Opportunity', oppId);
        TemplateDocumento__c template = TemplateSelector.getTemplateById(templateId);

        String docxml = ContratoService.contratoText(opp, template);

        conteudo = docxml;
    }
}