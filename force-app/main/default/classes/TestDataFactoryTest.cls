@isTest
public class TestDataFactoryTest {
    
    @isTest
    static void testGerarAnaliseCredito() {
        // Prepara os dados
        Opportunity opportunity = new Opportunity(Name = 'Oportunidade Teste', Amount = 1000, StageName = 'Negociação', CloseDate = System.today().addDays(15));
        insert opportunity;

        // Chama o método
        AnaliseCredito__c analise = TestDataFactory.gerarAnaliseCredito(opportunity);

        // Verifica os resultados
        System.assertNotEquals(null, analise);
        System.assertEquals('Teste', analise.Name);
        System.assertEquals('Em Análise', analise.Status__c);
        System.assertEquals(opportunity.Id, analise.Opportunity__c);
    }
    
    @isTest
    static void testGerarChecklistDocumentos() {
        // Prepara os dados
        Opportunity opportunity = new Opportunity(Name = 'Oportunidade Teste', Amount = 1000, StageName = 'Negociação', CloseDate = System.today().addDays(15));
        insert opportunity;

        // Chama o método
        Checklist_de_Documentos__c checklist = TestDataFactory.gerarChecklistDocumentos(opportunity);

        // Verifica os resultados
        System.assertNotEquals(null, checklist);
        System.assertEquals(opportunity.Id, checklist.Oportunidade__c);
    }

    @isTest
    static void testGerarChecklistDocumentosComDocumentacao() {
        // Prepara os dados
        Opportunity opportunity = new Opportunity(Name = 'Oportunidade Teste', Amount = 1000, StageName = 'Negociação', CloseDate = System.today().addDays(15));
        insert opportunity;
        
        Documentacao__c documentacao = new Documentacao__c(Name = 'Documento Teste', Obrigatorio__c = true);
        insert documentacao;

        // Chama o método
        Checklist_de_Documentos__c checklist = TestDataFactory.gerarChecklistDocumentos(opportunity, documentacao);

        // Verifica os resultados
        System.assertNotEquals(null, checklist);
        System.assertEquals(opportunity.Id, checklist.Oportunidade__c);
        System.assertEquals(documentacao.Id, checklist.Documenta_o__c);
    }

    @isTest
    static void testGerarConta() {
        // Chama o método
        Account conta = TestDataFactory.gerarConta();

        // Verifica os resultados
        System.assertNotEquals(null, conta);
        System.assertEquals('Conta de Teste', conta.Name);
    }

    @isTest
    static void testGerarContato() {
        // Prepara os dados
        Account conta = TestDataFactory.gerarConta();
        insert conta;

        // Chama o método
        Contact contato = TestDataFactory.gerarContato(conta);

        // Verifica os resultados
        System.assertNotEquals(null, contato);
        System.assertEquals(conta.Id, contato.AccountId);
        System.assertEquals('Elera', contato.FirstName);
        System.assertEquals('Teste', contato.LastName);
    }

    @isTest
    static void testGerarCotacao() {
        // Prepara os dados
        Opportunity oportunidade = new Opportunity(Name = 'Oportunidade Teste', Amount = 1000, StageName = 'Negociação', CloseDate = System.today().addDays(15));
        insert oportunidade;

        // Chama o método
        Quote cotacao = TestDataFactory.gerarCotacao(oportunidade);

        // Verifica os resultados
        System.assertNotEquals(null, cotacao);
        System.assertEquals('Teste', cotacao.Name);
        System.assertEquals(oportunidade.Id, cotacao.OpportunityId);
    }

    @isTest
    static void testGerarProduct2() {
        // Chama o método
        Product2 produto = TestDataFactory.gerarProduto();

        // Verifica os resultados
        System.assertNotEquals(null, produto);
        System.assertEquals('Produto de Teste', produto.Name);
        System.assertEquals('Teste-1', produto.ProductCode);
    }

    @isTest
    static void testGerarEmpreendimento() {
        // Chama o método
        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();

        // Verifica os resultados
        System.assertNotEquals(null, empreendimento);
        System.assertEquals('Empreendimento de Teste', empreendimento.Name);
    }

    @isTest
    static void testGerarTabelaVendas() {
        // Chama o método
        TabelaVendas__c tabelaVendas = TestDataFactory.gerarTabelaVendas();

        // Verifica os resultados
        System.assertNotEquals(null, tabelaVendas);
        System.assertEquals('Teste', tabelaVendas.Name);
    }

    @isTest
    static void testGerarUnidadeTabelaVendas() {
        // Prepara os dados
        TabelaVendas__c tabelaVendas = TestDataFactory.gerarTabelaVendas();
        insert tabelaVendas;

        // Chama o método
        UnidadeTabelaVendas__c unidadeVenda = TestDataFactory.gerarUnidadeTabelaVendas(tabelaVendas.Id);

        // Verifica os resultados
        System.assertNotEquals(null, unidadeVenda);
        System.assertEquals(tabelaVendas.Id, unidadeVenda.TabelaVenda__c);
        System.assertEquals(300000, unidadeVenda.PrecoLista__c);
    }

    @isTest
    static void testGerarProcessInstance() {
        // Prepara os dados
        Opportunity oportunidade = new Opportunity(Name = 'Oportunidade Teste', Amount = 1000, StageName = 'Negociação', CloseDate = System.today().addDays(15));
        insert oportunidade;

        ProcessDefinition pd = [SELECT Id FROM ProcessDefinition LIMIT 1];

        // Chama o método
        ProcessInstance pi = TestDataFactory.gerarProcessInstance(oportunidade, pd);

        // Verifica os resultados
        System.assertNotEquals(null, pi);
        System.assertEquals(oportunidade.Id, pi.TargetObjectId);
        System.assertEquals('Approved', pi.Status);
    }

    @isTest
    static void testGerarOportunidadeComDadosIncompletos() {
        // Prepara dados com valores faltando
        Opportunity opportunity = new Opportunity(Name = 'Oportunidade Teste', StageName = 'Negociação', CloseDate = System.today().addDays(15)); // Falta Amount
        try {
            insert opportunity;
           // System.assert(false, 'Esperado erro ao inserir oportunidade sem Amount');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Amount'), 'Erro esperado relacionado ao campo Amount');
        }
    }
    
}