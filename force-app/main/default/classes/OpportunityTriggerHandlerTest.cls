@isTest
private class OpportunityTriggerHandlerTest {

    @isTest
    static void beforeInsertTest() {
        // Criando a oportunidade com todos os campos obrigatórios
        Opportunity opp = new Opportunity();
        opp.Name = 'Nova Oportunidade';
        opp.StageName = 'Negociação';
        opp.CloseDate = Date.today();  // Adicionando o campo CloseDate, que é obrigatório
        insert opp;  // Usando 'insert' ao invés de 'Insert'
    }
    
    @isTest
    static void beforeUpdateTest() {
        // Criando a oportunidade com todos os campos obrigatórios
        Opportunity opp = new Opportunity();
        opp.Name = 'Nova Oportunidade';
        opp.StageName = 'Negociação';
        opp.CloseDate = Date.today();  // Adicionando o campo CloseDate, que é obrigatório
        insert opp;

        // Atualizando o campo Name da oportunidade
        opp.Name = 'Nova';
        update opp;  // Usando 'update' ao invés de 'Update'
    }
}