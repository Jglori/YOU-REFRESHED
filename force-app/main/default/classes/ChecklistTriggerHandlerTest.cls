@isTest
public class ChecklistTriggerHandlerTest {
    
    @testSetup
    static void setupTestData() {
        Account acc = new Account(Name = 'Test Account', CNPJ__c = '73337584000169');
        insert acc;


        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Negociação',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;

        Documentacao__c doc1 = new Documentacao__c(Name = 'Documento 1', Obrigatorio__c = true, Entregue__c = false);
        Documentacao__c doc2 = new Documentacao__c(Name = 'Documento 2', Obrigatorio__c = true, Entregue__c = true);
        Documentacao__c doc3 = new  Documentacao__c(Name = 'Documento 3', Obrigatorio__c = false, Entregue__c = true);
        insert new List< Documentacao__c>{doc1, doc2, doc3};

        insert new Checklist_de_Documentos__c[]{
            new Checklist_de_Documentos__c(Oportunidade__c = opp.Id, Documenta_o__c = doc1.Id),
            new Checklist_de_Documentos__c(Oportunidade__c = opp.Id, Documenta_o__c = doc2.Id),
            new Checklist_de_Documentos__c(Oportunidade__c = opp.Id, Documenta_o__c = doc3.Id)
        };
    }

    @isTest
    static void testAfterInsertTrigger() {
        Opportunity opp = [SELECT Id, FarolChecklistDocumento__c FROM Opportunity LIMIT 1];

        Checklist_de_Documentos__c newChecklist = new Checklist_de_Documentos__c(
            Oportunidade__c = opp.Id,
            Documenta_o__c = [SELECT Id FROM  Documentacao__c WHERE Name = 'Documento 1' LIMIT 1].Id
        );
        insert newChecklist;

        opp = [SELECT Id, FarolChecklistDocumento__c FROM Opportunity WHERE Id = :opp.Id];
       
    }

    @isTest
    static void testAfterUpdateTrigger() {
        Opportunity opp = [SELECT Id, FarolChecklistDocumento__c FROM Opportunity LIMIT 1];

        Checklist_de_Documentos__c checklist = [SELECT Id, Documenta_o__c FROM Checklist_de_Documentos__c LIMIT 1];
        Documentacao__c doc = [SELECT Id, Obrigatorio__c, Entregue__c FROM  Documentacao__c WHERE Id = :checklist.Documenta_o__c LIMIT 1];
        doc.Entregue__c = true;
        update doc;

        update checklist;

        opp = [SELECT Id, FarolChecklistDocumento__c FROM Opportunity WHERE Id = :opp.Id];
      
    }
}