@isTest
private class ChecklistHelperTest {
    
    @isTest
    static void testUpdateOpportunityChecklistStatus() {
       
    Contact contact1 = new Contact(FirstName = 'João', LastName = 'Silva', CPF__c = '01794410007'); 
Contact contact2 = new Contact(FirstName = 'Maria', LastName = 'Oliveira', CPF__c = '70681096080'); 

        insert new List<Contact>{contact1, contact2};
        
        
        Documentacao__c docMandatory1 = new Documentacao__c(Name = 'Documento Obrigatório 1', Obrigatorio__c = true, Entregue__c = false);
        Documentacao__c docMandatory2 = new Documentacao__c(Name = 'Documento Obrigatório 2', Obrigatorio__c = true, Entregue__c = false);
        Documentacao__c docOptional1 = new Documentacao__c(Name = 'Documento Opcional 1', Obrigatorio__c = false, Entregue__c = false);
        Documentacao__c docOptional2 = new Documentacao__c(Name = 'Documento Opcional 2', Obrigatorio__c = false, Entregue__c = false);
        insert new List<Documentacao__c>{docMandatory1, docMandatory2, docOptional1, docOptional2};
        
       
        Checklist_de_Documentos__c checklist1 = new Checklist_de_Documentos__c(
            Oportunidade__c = null, 
            Documenta_o__c = docMandatory1.Id, 
            Contato__c = contact1.Id
        );
        Checklist_de_Documentos__c checklist2 = new Checklist_de_Documentos__c(
            Oportunidade__c = null, 
            Documenta_o__c = docMandatory2.Id, 
            Contato__c = contact1.Id
        );
        Checklist_de_Documentos__c checklist3 = new Checklist_de_Documentos__c(
            Oportunidade__c = null, 
            Documenta_o__c = docOptional1.Id, 
            Contato__c = contact2.Id
        );
        Checklist_de_Documentos__c checklist4 = new Checklist_de_Documentos__c(
            Oportunidade__c = null, 
            Documenta_o__c = docOptional2.Id, 
            Contato__c = contact2.Id
        );
        insert new List<Checklist_de_Documentos__c>{checklist1, checklist2, checklist3, checklist4};
        
       
        Opportunity opp = new Opportunity(Name = 'Oportunidade Teste', CloseDate = Date.today(), StageName = 'Prospecting');
        insert opp;
        
       
        checklist1.Oportunidade__c = opp.Id;
        checklist2.Oportunidade__c = opp.Id;
        checklist3.Oportunidade__c = opp.Id;
        checklist4.Oportunidade__c = opp.Id;
        update new List<Checklist_de_Documentos__c>{checklist1, checklist2, checklist3, checklist4};
        
        
        docMandatory1.Entregue__c = true; 
        update docMandatory1;

        
        ChecklistHelper.updateOpportunityChecklistStatus(new List<Checklist_de_Documentos__c>{checklist1, checklist2, checklist3, checklist4});
        
        
        Opportunity updatedOpp = [SELECT Id, FarolChecklistDocumento__c FROM Opportunity WHERE Id = :opp.Id];
        
        
        docMandatory2.Entregue__c = true; 
        update docMandatory2;

       
        ChecklistHelper.updateOpportunityChecklistStatus(new List<Checklist_de_Documentos__c>{checklist1, checklist2, checklist3, checklist4});
        
       
        updatedOpp = [SELECT Id, FarolChecklistDocumento__c FROM Opportunity WHERE Id = :opp.Id];
    }
}