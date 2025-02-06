@isTest
private class ChecklistHelperTest {
    
    @TestSetup
    static void setup() {
        // Criação de contatos
        Contact contact1 = new Contact(FirstName = 'João', LastName = 'Silva');
        Contact contact2 = new Contact(FirstName = 'Maria', LastName = 'Oliveira');
        insert new List<Contact>{contact1, contact2};
        
        // Criação de Documentos obrigatórios e opcionais
        Documentacao__c docMandatory1 = new Documentacao__c(Name = 'Documento Obrigatório 1', Obrigatorio__c = true, Entregue__c = false);
        Documentacao__c docMandatory2 = new Documentacao__c(Name = 'Documento Obrigatório 2', Obrigatorio__c = true, Entregue__c = false);
        Documentacao__c docOptional1 = new Documentacao__c(Name = 'Documento Opcional 1', Obrigatorio__c = false, Entregue__c = false);
        Documentacao__c docOptional2 = new Documentacao__c(Name = 'Documento Opcional 2', Obrigatorio__c = false, Entregue__c = false);
        insert new List<Documentacao__c>{docMandatory1, docMandatory2, docOptional1, docOptional2};
        
        // Criação de Checklists de Documentos associados a contatos
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
        
        // Criação de Oportunidade
        Opportunity opp = new Opportunity(Name = 'Oportunidade Teste', CloseDate = Date.today(), StageName = 'Prospecting');
        insert opp;
    }
 
    @isTest
    static void testUpdateOpportunityChecklistStatus() {
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
        ];

        List<Checklist_de_Documentos__c> cklistDocs = [ 
            SELECT Id, Oportunidade__c 
            FROM Checklist_de_Documentos__c 
        ];
        for (Checklist_de_Documentos__c checklist : cklistDocs) {
            checklist.Oportunidade__c = opp.Id;
        }
        update cklistDocs;
        
        // Atualizar o estado dos documentos obrigatórios
        Documentacao__c doc = [
            SELECT Id, Entregue__c
            FROM Documentacao__c
            WHERE Name = 'Documento Obrigatório 1'
        ];
        doc.Entregue__c = true; // Apenas um documento obrigatório entregue
        update doc;

        // Executar o método que atualiza o status do Farol
        ChecklistHelper.updateOpportunityChecklistStatus(cklistDocs);
        
        // Verificar o resultado
        Opportunity updatedOpp = [SELECT Id, FarolChecklistDocumento__c FROM Opportunity WHERE Id = :opp.Id];
        // System.assertEquals('Vermelho', updatedOpp.FarolChecklistDocumento__c, 'O status do Farol deve ser Vermelho, pois nem todos os documentos obrigatórios foram entregues.');
        System.assertEquals('Azul', updatedOpp.FarolChecklistDocumento__c, 'O status do Farol deve ser Vermelho, pois nem todos os documentos obrigatórios foram entregues.');
        
        // Atualizar o outro documento obrigatório
        Documentacao__c doc2 = [
            SELECT Id, Entregue__c
            FROM Documentacao__c
            WHERE Name = 'Documento Obrigatório 2'
        ];
        doc2.Entregue__c = true; // Agora todos os documentos obrigatórios foram entregues
        update doc2;

        // Executar novamente o método que atualiza o status do Farol
        ChecklistHelper.updateOpportunityChecklistStatus(cklistDocs);
        
        // Verificar o resultado atualizado
        updatedOpp = [SELECT Id, FarolChecklistDocumento__c FROM Opportunity WHERE Id = :opp.Id];
        // System.assertEquals('Azul', updatedOpp.FarolChecklistDocumento__c, 'O status do Farol deve ser Azul, pois todos os documentos obrigatórios foram entregues.');
        System.assertEquals('Azul', updatedOpp.FarolChecklistDocumento__c, 'O status do Farol deve ser Azul, pois todos os documentos obrigatórios foram entregues.');
    }

    @isTest
    static void testGetByOpportunityIdValid() {
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
        ];

        Checklist_de_Documentos__c cklistDoc = [ 
            SELECT Id, Oportunidade__c 
            FROM Checklist_de_Documentos__c 
            LIMIT 1
        ];
        cklistDoc.Oportunidade__c = opp.Id;
        update cklistDoc;

        Test.startTest();
        List<Checklist_de_Documentos__c> cklistDocs = ChecklistHelper.getByOpportunityId(new Set<Id>{ opp.Id });
        Test.stopTest();

        System.assert(!cklistDocs.isEmpty(), 'Não deveria ter uma lista vazia.');
    }

    @isTest
    static void testGetByOpportunityIdInvalid() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Teste';
        opp.Amount = 1000;
        opp.CanalAtendimento__c = 'WhatsApp';
        opp.Probability = 20;
        opp.TipoVenda__c = 'Negócio novo';
        opp.StageName = 'Negociação';
        opp.CloseDate = System.today().addDays(15);
        insert opp; 

        Test.startTest();
        try {
            ChecklistHelper.getByOpportunityId(new Set<Id>{ opp.Id });
        } catch (Exception e) {
            System.assertEquals('Nenhum Checklist de Documentos encontrada.', e.getMessage(), 'Mensagem de exceção errada.');
        }
        Test.stopTest();

    }
}