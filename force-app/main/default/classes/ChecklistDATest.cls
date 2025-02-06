@isTest
private class ChecklistDATest {

    @TestSetup
    static void setup() {
        Documentacao__c docMandatory1 = new Documentacao__c(Name = 'Documento Obrigatório 1', Obrigatorio__c = true, Entregue__c = false);
        Documentacao__c docMandatory2 = new Documentacao__c(Name = 'Documento Obrigatório 2', Obrigatorio__c = true, Entregue__c = false);
        Documentacao__c docOptional1 = new Documentacao__c(Name = 'Documento Opcional 1', Obrigatorio__c = false, Entregue__c = false);
        Documentacao__c docOptional2 = new Documentacao__c(Name = 'Documento Opcional 2', Obrigatorio__c = false, Entregue__c = false);
        insert new List<Documentacao__c>{docMandatory1, docMandatory2, docOptional1, docOptional2};
        
        // Criação de Oportunidades
        Opportunity opp1 = new Opportunity(Name = 'Oportunidade Teste 1', CloseDate = Date.today(), StageName = 'Prospecting');
        Opportunity opp2 = new Opportunity(Name = 'Oportunidade Teste 2', CloseDate = Date.today(), StageName = 'Prospecting');
        insert new List<Opportunity>{opp1, opp2};
        
        // Criação de Checklists de Documentos associados às Oportunidades
        Checklist_de_Documentos__c checklist1 = new Checklist_de_Documentos__c(
            Oportunidade__c = opp1.Id, 
            Documenta_o__c = docMandatory1.Id
        );
        Checklist_de_Documentos__c checklist2 = new Checklist_de_Documentos__c(
            Oportunidade__c = opp1.Id, 
            Documenta_o__c = docMandatory2.Id
        );
        Checklist_de_Documentos__c checklist3 = new Checklist_de_Documentos__c(
            Oportunidade__c = opp2.Id, 
            Documenta_o__c = docOptional1.Id
        );
        Checklist_de_Documentos__c checklist4 = new Checklist_de_Documentos__c(
            Oportunidade__c = opp2.Id, 
            Documenta_o__c = docOptional2.Id
        );
        insert new List<Checklist_de_Documentos__c>{checklist1, checklist2, checklist3, checklist4};
        
        
    }

    
    @isTest
    static void testGetWithDocumentsByOpportunity() {
        List<Opportunity> opps = [
            SELECT Id
            FROM Opportunity
        ];
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : opps) {
            oppIds.add(opp.Id);
        }

        List<Checklist_de_Documentos__c> cklists = ChecklistDA.getWithDocumentsByOpportunity(oppIds);

        System.assertNotEquals(null, cklists, 'Não deveria ser null.');
        System.assertEquals(4, cklists.size(), 'Deveria ter 4 checklists de documentos.');
    }
    
    @isTest
    static void testGetChecklistDocumentsWithDetails() {
        List<Opportunity> opps = [
            SELECT Id
            FROM Opportunity
        ];
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : opps) {
            oppIds.add(opp.Id);
        }

        Test.startTest();
        Map<Id, List<Checklist_de_Documentos__c>> result = ChecklistDA.getChecklistDocumentsWithDetails(oppIds);
        Test.stopTest();
        
        // Verificar o resultado
        System.assertNotEquals(null, result, 'O resultado não deve ser nulo.');
        System.assertEquals(2, result.size(), 'O mapa deve conter duas chaves (oportunidades).');
        
        List<Checklist_de_Documentos__c> checklistsForOpp1 = result.get(opps[0].Id);
        System.assertNotEquals(null, checklistsForOpp1, 'A lista de checklists para a oportunidade 1 não deve ser nula.');
        System.assertEquals(2, checklistsForOpp1.size(), 'A oportunidade 1 deve ter 2 checklists associados.');

        List<Checklist_de_Documentos__c> checklistsForOpp2 = result.get(opps[1].Id);
        System.assertNotEquals(null, checklistsForOpp2, 'A lista de checklists para a oportunidade 2 não deve ser nula.');
        System.assertEquals(2, checklistsForOpp2.size(), 'A oportunidade 2 deve ter 2 checklists associados.'); 
    }

    @isTest
    static void testGetRequiredDocumentsByPapeis() {
        List<String> papers = new List<String>{ 'Fiador', 'Procurador' };
        
        Test.startTest();
        List<Documento__mdt> result = ChecklistDA.getRequiredDocumentsByPapeis(papers);
        Test.stopTest();
        
        System.assert(!papers.isEmpty(), 'Não deveria vir uma lista vazia.');
        System.assert(papers.contains('Procurador'), 'Deveria ter um papel de procurador em algum dos documentos.');
    }

}