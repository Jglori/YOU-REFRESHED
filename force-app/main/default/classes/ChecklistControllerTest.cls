@isTest
public class ChecklistControllerTest {

    @isTest
    static void testGetDistinctContactRoles() {
        // Criar dados de teste
        // Primeiro, cria contatos
        Contact contact1 = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com');
        Contact contact2 = new Contact(FirstName = 'Jane', LastName = 'Doe', Email = 'jane.doe@example.com');
        insert new List<Contact>{ contact1, contact2 };

        // Criar oportunidades e papéis de contato associados
        Opportunity opp1 = new Opportunity(Name = 'Oportunidade 1', StageName = 'Prospecting', CloseDate = Date.today().addDays(30));
        Opportunity opp2 = new Opportunity(Name = 'Oportunidade 2', StageName = 'Prospecting', CloseDate = Date.today().addDays(30));
        insert new List<Opportunity>{ opp1, opp2 };
        
        // Adicionar papéis de contato à oportunidade
        OpportunityContactRole ocr1 = new OpportunityContactRole(OpportunityId = opp1.Id, ContactId = contact1.Id, Role = 'Decision Maker');
        OpportunityContactRole ocr2 = new OpportunityContactRole(OpportunityId = opp1.Id, ContactId = contact2.Id, Role = 'Influencer');
        OpportunityContactRole ocr3 = new OpportunityContactRole(OpportunityId = opp2.Id, ContactId = contact1.Id, Role = 'Decision Maker');
        insert new List<OpportunityContactRole>{ ocr1, ocr2, ocr3 };
        
        Test.startTest();
        
        // Chamar o método estático que queremos testar
        List<String> roles = ChecklistController.getDistinctContactRoles();
        
        Test.stopTest();
        
        // Verificar os resultados
        System.assertNotEquals(null, roles, 'A lista de papéis não deve ser nula.');
        System.assertEquals(2, roles.size(), 'Deve haver 2 papéis distintos.');
        System.assert(roles.contains('Decision Maker'), 'A lista deve conter o papel "Decision Maker".');
        System.assert(roles.contains('Influencer'), 'A lista deve conter o papel "Influencer".');
    }
}