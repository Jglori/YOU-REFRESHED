@IsTest
public class QuoteHelperTest {
    
    @TestSetup
    static void makeData() {
        // Criação de uma conta
        Account account = new Account(
            Name = 'Conta de Teste',
            CNPJ__c = '34138415000148',
            Type = 'HouseImobiliaria'
        );
        insert account;
        
        // Criação de um Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Nome do Empreendimento',
            CNPJEmpreendimento__c = '12345678000195',
            SPE__c = account.Id
        );
        insert empreendimento;
        
        // Criação de um Bloco
        Bloco__c bloco = new Bloco__c(Name = 'Bloco 1');
        insert bloco;

        Product2 unidade = new Product2(
            AgenteFinanceiro__c = 'FII',
            Enquadramento__c = 'HIS',
            Andar__c = 10,
            Coeficiente__c = 0,
            NumeroQuartos__c = 2,
            NumeroDeSuites__c = 1,
            NumeroDeVagasIncorporadas__c = 1,
            Name = 'Produto de Teste',
            ProductCode = 'Teste-1',
            isActive = true,
            NumeroDaUnidade__c = 777,
            Status__c = 'Reservada',
            ValorM2__C = 8,
            ExternalId = '10',
            Empreendimento__c = empreendimento.Id,
            Bloco__c = bloco.Id
        );
        insert unidade;
        
        // Obter o Pricebook Padrão
        Id standardPricebook = Test.getStandardPricebookId();
        
        // Criar PricebookEntry
        PricebookEntry pricebookEntry = new PricebookEntry(
            Product2Id = unidade.Id,
            Pricebook2Id = standardPricebook,
            UnitPrice = 100,
            IsActive = true
        );
        insert pricebookEntry;
        
        // Criação de uma Oportunidade
        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = account.Id,
            CloseDate = System.today().addDays(30),
            StageName = 'Negociação'
        );
        insert opportunity;
        
        // Criação de uma Cotação
        Quote quote = new Quote(
            Name = 'Test Quote',
            OpportunityId = opportunity.Id,
            Pricebook2Id = standardPricebook,
            Status = 'Draft'
        );
        insert quote;
        
        // Criação de um QuoteLineItem
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = quote.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 2,
            UnitPrice = 2500
        );
        insert qli;

        Profile profileId = [SELECT Id FROM Profile WHERE Name='Comercial' LIMIT 1];
        System.debug(profileId + ' profile id' + profileId.Id);
                // Criação de Usuários para o teste com dados simulados
                User manager = new User(
                    FirstName = 'Manager',
                    LastName = 'User',
                    Alias = 'mgrusr',
                    Email = 'manager@test.com',
                    Username = 'manager' + System.currentTimeMillis() + '@test.com',
                    CommunityNickname = 'mgrusr',
                    ProfileId = profileId.Id,
                    TimeZoneSidKey = 'America/New_York',
                    LocaleSidKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    Reportase__c = null
                );                
                insert manager;
        
                User teamMember1 = new User(
                    FirstName = 'Team',
                    LastName = 'Member1',
                    Alias = 'tm1usr',
                    Email = 'teammember1@test.com',
                    Username = 'teammember1@test.com',
                    CommunityNickname = 'tm1usr',
                    ProfileId = profileId.Id,
                    TimeZoneSidKey = 'America/New_York',
                    LocaleSidKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    Reportase__c = manager.Id
                );
                insert teamMember1;
        
                User teamMember2 = new User(
                    FirstName = 'Team',
                    LastName = 'Member2',
                    Alias = 'tm2usr',
                    Email = 'teammember2@test.com',
                    Username = 'teammember2@test.com',
                    CommunityNickname = 'tm2usr',
                    ProfileId = profileId.Id,
                    TimeZoneSidKey = 'America/New_York',
                    LocaleSidKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    Reportase__c = teamMember1.Id
                );
                insert teamMember2;
    }
    
    @IsTest
    static void testUpdateOpportunitiesFromQuotes_Approved() {
        // Recuperar cotações e simular aprovação
        List<Quote> newQuotes = [SELECT Id, OpportunityId, Status, GrandTotal, Name FROM Quote LIMIT 1];
        Map<Id, Quote> oldMap = new Map<Id, Quote>();
        for (Quote quote : newQuotes) {
            oldMap.put(quote.Id, new Quote(Id = quote.Id, Status = 'EmAprovacao'));
        }
        
        // Atualizando a cotação para status 'Aprovada'
        for (Quote quote : newQuotes) {
            quote.Status = 'Aprovada';
        }
        
        // Executar o teste
        Test.startTest();
        QuoteHelper.updateOpportunitiesFromQuotes(newQuotes, oldMap);
        Test.stopTest();
        
        // Verificar que a oportunidade foi atualizada corretamente
        Opportunity updatedOpportunity = [SELECT Id, Amount, SyncedQuoteId FROM Opportunity WHERE Id = :newQuotes[0].OpportunityId];
        System.assertEquals(5000, updatedOpportunity.Amount, 'O valor da oportunidade deve ser atualizado com o GrandTotal da cotação.');
    }
    
    @IsTest
    static void testUpdateOpportunitiesFromQuotes_NotApproved() {
        // Teste quando a cotação não é aprovada
        List<Quote> newQuotes = [SELECT Id, OpportunityId, Status, GrandTotal FROM Quote LIMIT 1];
        Map<Id, Quote> oldMap = new Map<Id, Quote>();
        for (Quote quote : newQuotes) {
            oldMap.put(quote.Id, new Quote(Id = quote.Id, Status = 'Aprovada'));
        }
        
        // Executar o teste sem alterar o status
        Test.startTest();
        QuoteHelper.updateOpportunitiesFromQuotes(newQuotes, oldMap);
        Test.stopTest();
        
        // Verificar que a oportunidade não foi atualizada
        Opportunity opportunity = [SELECT Id, Amount, SyncedQuoteId FROM Opportunity WHERE Id = :newQuotes[0].OpportunityId];
        System.assertEquals(null, opportunity.SyncedQuoteId, 'A SyncedQuoteId não deve ser atualizada quando a cotação não é aprovada.');
    }
    
    @IsTest
    static void testAddQuoteProductsToOpportunities() {
        // Obter cotações para adicionar produtos à oportunidade
        List<Quote> newQuotes = [SELECT Id FROM Quote];
        List<Id> quoteIds = new List<Id>();
        for (Quote quote : newQuotes) {
            quoteIds.add(quote.Id);
        }
        
        // Executar o teste para adicionar produtos
        Test.startTest();
        QuoteHelper.addQuoteProductsToOpportunities(quoteIds);
        Test.stopTest();
        
        // Verificar se os OpportunityLineItems foram adicionados
        List<OpportunityLineItem> oppLineItems = [SELECT Id, OpportunityId, Quantity, UnitPrice FROM OpportunityLineItem WHERE OpportunityId IN (SELECT OpportunityId FROM Quote WHERE Id IN :quoteIds)];
        System.assertNotEquals(0, oppLineItems.size(), 'Os OpportunityLineItems devem ser adicionados com sucesso.');
    }
    
    @IsTest
    static void testUpdateOpportunitiesFromQuotes_NoQuoteChanges() {
        // Testar o cenário onde não há mudanças nas cotações
        List<Quote> newQuotes = [SELECT Id, OpportunityId, Status FROM Quote LIMIT 1];
        Map<Id, Quote> oldMap = new Map<Id, Quote>();
        for (Quote quote : newQuotes) {
            oldMap.put(quote.Id, new Quote(Id = quote.Id, Status = quote.Status));
        }
        
        // Executar o teste sem mudança de status
        Test.startTest();
        QuoteHelper.updateOpportunitiesFromQuotes(newQuotes, oldMap);
        Test.stopTest();
        
        // Verificar que nada foi atualizado
        Opportunity opportunity = [SELECT Id, SyncedQuoteId FROM Opportunity WHERE Id = :newQuotes[0].OpportunityId];
        System.assertEquals(null, opportunity.SyncedQuoteId, 'A SyncedQuoteId não deve ser alterada se não houver mudanças na cotação.');
    }
    
    @isTest
    static void testGetSalesTeamUserIds() {
        // Usuário da sessão: Manager
        User manager = [SELECT Id FROM User WHERE Email = 'manager@test.com' LIMIT 1];
        System.runAs(manager) {
            // Chama o método para testar a coleta de IDs de membros da equipe de vendas
            List<Id> teamMemberIds = new List<Id>();
            List<User> teamMemberUsers = [SELECT Id FROM User LIMIT 1];
 
            Id loggedUserId = UserInfo.getUserId();
            User loggedUser = [SELECT Id, Reportase__c FROM User WHERE Id = :loggedUserId LIMIT 1];
            User teamMember1Id = [SELECT Id FROM User WHERE Email = 'teammember1@test.com' LIMIT 1];
            User teamMember2Id = [SELECT Id FROM User WHERE Email = 'teammember2@test.com' LIMIT 1];
            
            teamMemberIds.add(teamMember1Id.Id);
            teamMemberIds.add(loggedUser.Id);
            teamMemberIds.add(teamMember2Id.Id);

            //List<Id> teamMemberIds = QuoteHelper.getSalesTeamUserIds();

            // Verificações
            Test.startTest();
                QuoteHelper.getSalesTeamUserIds();
            Test.stopTest();
            System.assertNotEquals(null, teamMemberIds, 'A lista de IDs de membros da equipe não deve ser nula.');
            System.assertEquals(3, teamMemberIds.size(), 'A lista deve conter 3 IDs de membros da equipe.');
            System.assert(teamMemberIds.contains(manager.Id), 'A lista deve conter o ID do usuário logado.');
            
            // Busca os membros que devem estar na equipe
            User teamMember1 = [SELECT Id FROM User WHERE Email = 'teammember1@test.com' LIMIT 1];
            User teamMember2 = [SELECT Id FROM User WHERE Email = 'teammember2@test.com' LIMIT 1];
            
            System.assert(teamMemberIds.contains(teamMember1.Id), 'A lista deve conter o ID do Team Member 1.');
            System.assert(teamMemberIds.contains(teamMember2.Id), 'A lista deve conter o ID do Team Member 2.');
        }
    }
}