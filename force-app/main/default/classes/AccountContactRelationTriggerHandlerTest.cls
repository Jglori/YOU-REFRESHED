@isTest
private class AccountContactRelationTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        Account acc = new Account(Name = 'Conta teste');
        insert acc;

        Contact contact1 = new Contact(FirstName = 'Flavia', LastName = 'Souza', AccountId = acc.Id);
        Contact contact2 = new Contact(FirstName = 'Igor', LastName = 'Souza', AccountId = acc.Id);
        insert new List<Contact>{contact1, contact2};

        Opportunity opp = new Opportunity(Name = 'Opp teste', StageName = 'Prospecting', CloseDate = Date.today());
        insert opp;
    }

    @isTest
    static void testProcessBeforeInsert() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<OpportunityContactRole> newRecords = new List<OpportunityContactRole>{
            new OpportunityContactRole(ContactId = contact.Id, OpportunityId = opp.Id, PorcentagemParticipacao__c = 50)
        };
        Test.startTest();
        AccountContactRelationHelper.processBeforeInsert(newRecords);
        Test.stopTest();
        System.assertEquals(1, newRecords.size());
    }

    @isTest
    static void testProcessBeforeUpdate() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        OpportunityContactRole ocr = new OpportunityContactRole(ContactId = contact.Id, OpportunityId = opp.Id, PorcentagemParticipacao__c = 30);
        insert ocr;
        ocr.PorcentagemParticipacao__c = 70;
        
        Test.startTest();
        AccountContactRelationHelper.processBeforeUpdate(new List<OpportunityContactRole>{ocr}, new Map<Id, OpportunityContactRole>{ocr.Id => ocr});
        Test.stopTest();
        System.assertEquals(70, ocr.PorcentagemParticipacao__c);
    }

    @isTest
    static void testProcessBeforeInsertNullPointer() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        List<OpportunityContactRole> newRecords = new List<OpportunityContactRole>{
            new OpportunityContactRole(ContactId = contact.Id, OpportunityId = opp.Id, PorcentagemParticipacao__c = null)
        };

        try {
            Test.startTest();
            AccountContactRelationHelper.processBeforeInsert(newRecords);
            Test.stopTest();
            System.assert(false, 'Uma exceção deveria ter sido lançada.');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('exceptionText'), 'A exceção lançada não era a esperada.');
        }
    }
}