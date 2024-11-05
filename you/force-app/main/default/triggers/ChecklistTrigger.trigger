trigger ChecklistTrigger on Checklist_de_Documentos__c (after insert, after update) {
    new ChecklistTriggerHandler().run();
}