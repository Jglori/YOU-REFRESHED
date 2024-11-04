public with sharing class TemplateDocumentoTriggerHandler extends TriggerHandler {
    public override void beforeInsert(){
        List<TemplateDocumento__c> templatesDocumentos = [
            SELECT Id, Name, TipoTemplate__c, Ativo__c, Empreendimento__c FROM TemplateDocumento__c Where Ativo__c = true
        ];
        Map<String, TemplateDocumento__c> templatesDocumentosMap = new Map<String, TemplateDocumento__c>();

        for(TemplateDocumento__c templateDocumento : templatesDocumentos){
            templatesDocumentosMap.put(templateDocumento.Empreendimento__c, templateDocumento);
        }

        List<TemplateDocumento__c> templatesDocumentosAtualizados = new List<TemplateDocumento__c>();

        for(TemplateDocumento__c templateDocumento : (List<TemplateDocumento__c>) Trigger.new){
            if(templatesDocumentosMap.containsKey(templateDocumento.Empreendimento__c)){
                if (templatesDocumentosMap.get(templateDocumento.Empreendimento__c).TipoTemplate__c == 'Contrato'
                && templateDocumento.TipoTemplate__c == 'Contrato'){
                    templateDocumento__c template = templatesDocumentosMap.get(templateDocumento.Empreendimento__c);
                    template.TipoTemplate__c = 'Outro Documento';
                    templatesDocumentosAtualizados.add(template);
                }
            }
        }

        if(!templatesDocumentosAtualizados.isEmpty()){
            update templatesDocumentosAtualizados;
        }
    }
}