@isTest
public class AccountContactRelationHelperTest {
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
    static void testValidateOpportunityPercentages() {
        Contact contact1 = [SELECT Id FROM Contact LIMIT 1];
        Contact contact2 = [SELECT Id FROM Contact LIMIT 1 OFFSET 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        OpportunityContactRole ocr1 = new OpportunityContactRole(ContactId = contact1.Id, OpportunityId = opp.Id, PorcentagemParticipacao__c = 60);
        OpportunityContactRole ocr2 = new OpportunityContactRole(ContactId = contact2.Id, OpportunityId = opp.Id, PorcentagemParticipacao__c = 50);
        insert new List<OpportunityContactRole>{ocr1, ocr2};
        
        Set<Id> oppIds = new Set<Id>{ocr1.OpportunityId};
        Test.startTest();
        try {
            AccountContactRelationHelper.validateOpportunityPercentages(oppIds);
            System.assert(false, 'Esperado uma exceção dos 100% de porcentagem');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('A soma das porcentagens dos contatos ultrapassa 100%'));
        }
        Test.stopTest();
    }
    
    @isTest
    static void testValidateOpportunityPercentagesExactly100() {
        Contact contact1 = [SELECT Id FROM Contact LIMIT 1];
        Contact contact2 = [SELECT Id FROM Contact LIMIT 1 OFFSET 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        OpportunityContactRole ocr1 = new OpportunityContactRole(ContactId = contact1.Id, OpportunityId = opp.Id, PorcentagemParticipacao__c = 40);
        OpportunityContactRole ocr2 = new OpportunityContactRole(ContactId = contact2.Id, OpportunityId = opp.Id, PorcentagemParticipacao__c = 60);
        insert new List<OpportunityContactRole>{ocr1, ocr2};
        
        Set<Id> oppIds = new Set<Id>{ocr1.OpportunityId};
        Test.startTest();
        AccountContactRelationHelper.validateOpportunityPercentages(oppIds);
        Test.stopTest();
    }
    
    @isTest
    static void testValidateOpportunityPercentagesAfterReduction() {
        Contact contact1 = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        OpportunityContactRole ocr = new OpportunityContactRole(ContactId = contact1.Id, OpportunityId = opp.Id, PorcentagemParticipacao__c = 120);
        insert ocr;
        
        ocr.PorcentagemParticipacao__c = 80;
        update ocr;
        
        Set<Id> oppIds = new Set<Id>{ocr.OpportunityId};
        Test.startTest();
        AccountContactRelationHelper.validateOpportunityPercentages(oppIds);
        Test.stopTest();
    }
    
    @isTest
    static void testValidateOpportunityPercentagesAfterDeletion() {
        Contact contact1 = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        OpportunityContactRole ocr = new OpportunityContactRole(ContactId = contact1.Id, OpportunityId = opp.Id, PorcentagemParticipacao__c = 80);
        insert ocr;
        
        delete ocr;
        
        Set<Id> oppIds = new Set<Id>{opp.Id};
        Test.startTest();
        AccountContactRelationHelper.validateOpportunityPercentages(oppIds);
        Test.stopTest();
    }
}