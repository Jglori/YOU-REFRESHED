public class TestDataFactory {

    //Registros objetos padrão
    public static Account gerarConta(){
        Account conta = new Account();
        conta.Name = 'Conta de Teste';
        return conta;
    }

    // Instância conta com um tipo específico
    public static Account gerarConta(String tipo){
        Account conta = new Account();
        conta.Name = 'Conta de Teste';
        conta.Type = tipo;
        return conta;
    }

    public static Account gerarContaPessoal() {
        Account contaPessoal = new Account();
        contaPessoal.FirstName = 'John';
        contaPessoal.LastName = 'Doe';
        contaPessoal.PersonEmail = 'johndoe@example.com';
        contaPessoal.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        return contaPessoal;
    }

    public static Contact gerarContato(Account conta) {
        Contact contato = new Contact();
        contato.AccountId = conta.Id;
        contato.LastName = 'Teste';
        contato.CPF__c  = '67481558000';
        return contato;
    }

    public static Contact gerarContato(Account conta, Id recordTypeId) {
        Contact contato = new Contact();
        contato.AccountId = conta.Id;
        contato.LastName = 'Teste';
        contato.RecordTypeId = recordTypeId;
        return contato;
    }

    public static Quote gerarCotacao(Opportunity oportunidade) {
        Quote cotacao = new Quote();
        cotacao.Name = 'Teste';
        cotacao.OpportunityId = oportunidade.Id; 
        return cotacao;
    }

    public static Lead gerarLead() {
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Lead';
        lead.Company = 'Elera';
        lead.Email = 'test.lead@elera.io';
        lead.LeadSource = 'Telefone';
        lead.CanalAtendimento__c = 'Chat';
        lead.MobilePhone = '11960387699';
        lead.Status = 'Novo';
        lead.CPF__c = '25702438094';
        
        return lead;
    }

    public static Lead gerarLead(Empreendimento__c empreendimento) {
        Lead lead = gerarLead();
        lead.EmpreendimentoInteresse__c = empreendimento.Id;
        
        return lead;
    }

    public static Product2 gerarProduto(){
        Product2 produto = new Product2();
        produto.Name = 'Produto de Teste';
        produto.ProductCode = 'Teste-1';
        produto.isActive = true;
        // produto.NumeroDaUnidade__c = 777;
        return produto;
    }

    public static Task gerarTask(Lead lead) {
        Task task = new Task();
        task.Subject = 'Chamada';
        task.Status = 'Completed';
        task.WhoId = lead.Id;
        return task;
    }

    public static PricebookEntry  gerarPricebookEntry(Id idProduto){
        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = idProduto;
        pricebookEntry.UseStandardPrice = false;
        pricebookEntry.UnitPrice = 100;
        pricebookEntry.IsActive = true;
        return pricebookEntry;
    }

    //Registros simulador de vendas
    public static Empreendimento__c gerarEmpreendimento(){
        Empreendimento__c empreendimento = new Empreendimento__c();
        empreendimento.Name = 'Empreendimento de Teste';
        empreendimento.CNPJEmpreendimento__c = '22151181000190';
        return empreendimento;
    }

    // public static TabelaVendas__c gerarTabelaVendas(){
    //     TabelaVendas__c tabelaVendas = new TabelaVendas__c();
    //     tabelaVendas.Name = 'Teste'; 
    //     tabelaVendas.PeriodicidadeParcelaPos__c = 1;
    //     tabelaVendas.PeriodicidadeParcela__c = 1;
    //     return tabelaVendas;
    // }

    // public static TabelaVendas__c gerarTabelaVendas(Quote cotacao){
    //     TabelaVendas__c tabelaVendas = new TabelaVendas__c();
    //     tabelaVendas.Name = 'Teste'; 
    //     tabelaVendas.PeriodicidadeParcelaPos__c = 1;
    //     tabelaVendas.PeriodicidadeParcela__c = 1;
    //     tabelaVendas.Cotacao__c = cotacao.Id;
    //     return tabelaVendas;
    // }


    public static Opportunity gerarOportunidade(Account conta, Contact corretor) {
        Opportunity oportunidade = new Opportunity();
        oportunidade.Name = 'Teste';
        oportunidade.AccountId = conta.Id;
        oportunidade.Corretor__c = corretor.Id;
        oportunidade.StageName = 'Negociação';
        return oportunidade;
    }

    // public static SeriePagamentos__c gerarSeriePagamento(Id idTabela){
    //     SeriePagamentos__c serie = new SeriePagamentos__c();
    //     serie.Name = 'Teste';
    //     serie.InicioPagamento__c = 1;
    //     serie.QuantidadeParcelas__c = 1;
    //     serie.ValorTotal__c= 1;
    //     serie.TabelaVenda__c = idTabela;
    //     serie.TipoCondicao__c = 'Ato';
    //     return serie;
    // }

    // public static SeriePagamentosService.ObjetoSerie gerarObjetoSerie(String nomeSerie, Id idTabelaVenda){
    //     SeriePagamentosService.ObjetoSerie serie = new SeriePagamentosService.ObjetoSerie();
    //     serie.nome = nomeSerie;
    //     serie.valorTotal = 4; 
    //     serie.quantidadeParcelas = 1;
    //     serie.periodicidade = 1;
    //     serie.inicioPagamento = 0;
    //     serie.aposHabiteSe = false;
    //     return serie;
    // }

    // public static UnidadeTabelaVendas__c gerarUnidadeTabelaVendas(Id idTabela){
    //     UnidadeTabelaVendas__c unidadeVenda = new UnidadeTabelaVendas__c();
    //     unidadeVenda.Name = 'UnidadeVendaTeste';
    //     unidadeVenda.TabelaVenda__c = idTabela;
    //     unidadeVenda.PrecoLista__c = 300000;
    //     return unidadeVenda;
    // } 
}