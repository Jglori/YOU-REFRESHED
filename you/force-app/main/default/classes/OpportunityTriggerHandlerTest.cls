@isTest
private class OpportunityTriggerHandlerTest {

    @isTest
    static void beforeInsertTest() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Nova Oportunidade';
        opp.StageName = 'Negociação';
        Insert opp;
    }
    
    @isTest
    static void beforeUpdateTest() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Nova Oportunidade';
        opp.StageName = 'Negociação';
        Insert opp;

        opp.Name = 'Nova';
        Update opp;

    }

}