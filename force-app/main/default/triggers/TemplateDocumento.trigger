trigger TemplateDocumento on TemplateDocumento__c (before insert) {
 new TemplateDocumentoTriggerHandler().run();
}