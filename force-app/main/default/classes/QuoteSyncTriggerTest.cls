@IsTest
public class QuoteSyncTriggerTest {

    @TestSetup
    static void setupTestData() {
        // Cria uma conta de teste
        Account account = new Account(Name = 'Test Account');
        account.CNPJ__c = '34138415000148';
        insert account;

        // Cria uma oportunidade associada à conta
        Opportunity opportunity = new Opportunity(
            Name = 'Teste Oportunidade',
            AccountId = account.Id,
            CloseDate = System.today().addDays(30),
            StageName = 'Negociação'
        );
        insert opportunity;
    }

    @IsTest
    static void testQuoteSyncTrigger_SameOpportunitySyncError() {
        // Recupera a oportunidade criada no método @TestSetup
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];

        // Cria uma cotação sincronizada associada à oportunidade
        Quote syncedQuote = new Quote(
            Name = 'Synced Quote',
            OpportunityId = opportunity.Id,
            Status = 'Aprovada' // Isso deve fazer com que a trigger defina Sincronizado__c como true
        );
        insert syncedQuote;

        // Cria uma nova cotação para a mesma oportunidade com o campo Sincronizado__c marcado como true
        Quote newQuote = new Quote(
            Name = 'New Quote',
            OpportunityId = opportunity.Id,
            Status = 'Aprovada' // Isso também fará com que a trigger defina Sincronizado__c como true
        );

        Test.startTest();
        try {
            // Tenta inserir a nova cotação, que deve falhar
            insert newQuote;
            // Falha o teste se não lançar uma exceção
            System.assert(false, 'A inserção deveria ter falhado devido à cotação já sincronizada.');
        } catch (DmlException e) {
            // Verifica se a mensagem de erro contém o texto esperado
            System.assert(
                e.getMessage().contains('já está sincronizada com esta oportunidade'),
                'A mensagem de erro esperada não foi encontrada: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void testQuoteSyncTrigger_StatusUpdate() {
        // Recupera a oportunidade criada no método @TestSetup
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];

        // Cria uma cotação com status diferente de 'Aprovada'
        Quote nonSyncedQuote = new Quote(
            Name = 'Non-Synced Quote',
            OpportunityId = opportunity.Id,
            Status = 'Pending'
        );
        insert nonSyncedQuote;

        // Atualiza o status da cotação para 'Aprovada'
        nonSyncedQuote.Status = 'Aprovada';

        Test.startTest();
        update nonSyncedQuote;

        // Verifica se o campo Sincronizado__c foi atualizado corretamente
        nonSyncedQuote = [SELECT Sincronizado__c FROM Quote WHERE Id = :nonSyncedQuote.Id];
        System.assert(nonSyncedQuote.Sincronizado__c, 'O campo Sincronizado__c deve ser true quando o status é Aprovada.');

        // Atualiza o status da cotação para algo diferente de 'Aprovada'
        nonSyncedQuote.Status = 'Rejeitada';
        update nonSyncedQuote;
        Test.stopTest();

        // Verifica se o campo Sincronizado__c foi atualizado para false
        nonSyncedQuote = [SELECT Sincronizado__c FROM Quote WHERE Id = :nonSyncedQuote.Id];
        System.assert(!nonSyncedQuote.Sincronizado__c, 'O campo Sincronizado__c deve ser false quando o status não é Aprovada.');
    }
}