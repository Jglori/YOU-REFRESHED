public class TestDataFactory {

    public static AnaliseCredito__c gerarAnaliseCredito(Opportunity opportunity) {
        AnaliseCredito__c analise = new AnaliseCredito__c();
        analise.Name = 'Teste';
        analise.Status__c = 'Em Análise';
        analise.Opportunity__c = opportunity.Id;
        analise.DataVencimento__c = Date.today();
        return analise;
    }

    public static Checklist_de_Documentos__c gerarChecklistDocumentos(Opportunity opportunity) {
        Checklist_de_Documentos__c checklist = new Checklist_de_Documentos__c();
        checklist.Oportunidade__c = opportunity.Id;
        return checklist;
    }

    public static Checklist_de_Documentos__c gerarChecklistDocumentos(Opportunity opportunity, Documentacao__c documentacao) {
        Checklist_de_Documentos__c checklist = gerarChecklistDocumentos(opportunity);
        checklist.Documenta_o__c = documentacao.Id;
        return checklist;
    }
    
	public static Checklist_de_Documentos__c gerarChecklistDocumentos(Opportunity opportunity, Documentacao__c documentacao, Contact contact) { Checklist_de_Documentos__c checklist = gerarChecklistDocumentos(opportunity, documentacao); checklist.Contato__c = contact.Id; return checklist; }

    //Registros objetos padrão
    public static Account gerarConta(){
        Account conta = new Account();
        conta.Name = 'Conta de Teste';
        conta.CNPJ__c = '34138415000148';
        conta.Type = 'HouseImobiliaria';
        return conta;
    }
    
	public static Account gerarConta(String tipo) { Account conta = gerarConta(); conta.Type = tipo; return conta; }


    public static Contact gerarContato() {
        Contact contato = new Contact();
        contato.FirstName = 'Elera';
        contato.LastName = 'Teste';
        contato.Email = 'teste.dev@elera.io';
        return contato;
    }

    public static Contact gerarContato(Account conta) {
        Contact contato = gerarContato();
        contato.AccountId = conta.Id;
        return contato;
    }
    
	public static Contact gerarContato(Account conta, Id recordTypeId) { Contact contato = gerarContato(conta); contato.RecordTypeId = recordTypeId; return contato; }

    public static ContentVersion gerarContentVersion() { ContentVersion contentVersion = new ContentVersion(); contentVersion.Title = 'Test Document'; contentVersion.PathOnClient = 'testdocument.pdf'; contentVersion.VersionData = Blob.valueOf('Test content'); return contentVersion; }

    public static Quote gerarCotacao(Opportunity oportunidade) {
        Quote cotacao = new Quote();
        cotacao.Name = 'Teste';
        cotacao.Status = 'Aprovada';
        cotacao.Pricebook2Id = Test.getStandardPricebookId();
        cotacao.OpportunityId = oportunidade.Id; 
        return cotacao;
    }

    public static Documentacao__c gerarDocumentacao() { Documentacao__c documentacao = new Documentacao__c(); documentacao.Name = 'Documento test'; documentacao.Obrigatorio__c = true; documentacao.Entregue__c = false; documentacao.Validado__c = false; return documentacao; }
	public static Documentacao__c gerarDocumentacao(ContentVersion contentVersion) { Documentacao__c documentacao = gerarDocumentacao(); documentacao.ContentDocumentId_c__c = contentVersion.ContentDocumentId; return documentacao; }
	public static Lead gerarLead() { Lead lead = new Lead(); lead.FirstName = 'Test'; lead.LastName = 'Lead'; lead.Company = 'Elera'; lead.Email = 'test.lead@elera.io'; lead.LeadSource = 'Telefone'; lead.CanalAtendimento__c = 'Chat'; lead.MobilePhone = '11960387699'; lead.DataHoraVencimento__c = Datetime.now(); lead.Status = 'Novo'; lead.CPF__c = '25702438094'; return lead; }
    
    public static Product2 gerarProduto(){
        Product2 produto = new Product2();
        produto.AgenteFinanceiro__c = 'FII';
        produto.Enquadramento__c = 'HIS';
        produto.Andar__c = 10;
        produto.Coeficiente__c = 0;
        produto.NumeroQuartos__c = 2;
        produto.NumeroDeSuites__c = 1;
        produto.NumeroDeVagasIncorporadas__c = 1;
        produto.Name = 'Produto de Teste';
        produto.ProductCode = 'Teste-1';
        produto.isActive = true;
        produto.NumeroDaUnidade__c = 777;
        produto.Status__c = 'Reservada';
        produto.ValorM2__C = 8;
        produto.ExternalId = '10';
        return produto;
    }
	
    public static Product2 gerarProduto(Empreendimento__c empreendimento, Bloco__c bloco) { Product2 produto = gerarProduto(); produto.Empreendimento__c = empreendimento.Id; produto.Bloco__c = bloco.Id; return produto; }
	public static Pricebook2 gerarPricebook() { Pricebook2 pricebook = new Pricebook2(); pricebook.Name = 'test'; pricebook.isActive = true; return pricebook; }
	public static PricebookEntry gerarPricebookEntry(Product2 produto) { PricebookEntry pricebookEntry = gerarPricebookEntry(produto.Id); return pricebookEntry; }
	public static PricebookEntry gerarPricebookEntry(Id idProduto) { PricebookEntry pricebookEntry = new PricebookEntry(); pricebookEntry.Pricebook2Id = Test.getStandardPricebookId(); pricebookEntry.Product2Id = idProduto; pricebookEntry.UseStandardPrice = false; pricebookEntry.UnitPrice = 100; pricebookEntry.IsActive = true; return pricebookEntry; }
    
    //Registros simulador de vendas
    public static Empreendimento__c gerarEmpreendimento(){
        Empreendimento__c empreendimento = new Empreendimento__c();
        empreendimento.Name = 'Empreendimento de Teste';
        empreendimento.CNPJEmpreendimento__c = '22151181000190';
        empreendimento.TipoEmpreendimento__c = 'Casa';
        empreendimento.StatusObra__c = 'Entregue';
        empreendimento.MetragemPrivativaTotal__c = 5000;
        empreendimento.MetragemTerreno__c = 10000;
        empreendimento.MetragemConstruIdaM__c = 7000;
        return empreendimento;
    }
    
    public static Empreendimento__c gerarEmpreendimento(Account acc) { Empreendimento__c empreendimento = gerarEmpreendimento(); empreendimento.SPE__c = acc.Id; return empreendimento; }

    public static TabelaVendas__c gerarTabelaVendas(){
        TabelaVendas__c tabelaVendas = new TabelaVendas__c();
        tabelaVendas.Name = 'Teste'; 
        tabelaVendas.PeriodicidadeParcelaPos__c = 1;
        tabelaVendas.PeriodicidadeParcela__c = 1;
        return tabelaVendas;
    }
	
    public static TabelaVendas__c gerarTabelaVendasCotacao(Quote cotacao) { TabelaVendas__c tabelaVendas = new TabelaVendas__c(); tabelaVendas.Name = 'Teste'; tabelaVendas.PeriodicidadeParcelaPos__c = 1; tabelaVendas.PeriodicidadeParcela__c = 1; tabelaVendas.Cotacao__c = cotacao.Id; return tabelaVendas; }
	public static Opportunity gerarOportunidade() { Opportunity oportunidade = new Opportunity(); oportunidade.Name = 'Teste'; oportunidade.Amount = 1000; oportunidade.CanalAtendimento__c = 'WhatsApp'; oportunidade.Probability = 20; oportunidade.TipoVenda__c = 'Negócio novo'; oportunidade.StageName = 'Negociação'; oportunidade.CloseDate = System.today().addDays(15); return oportunidade; }
	public static Opportunity gerarOportunidade(Account conta, Contact corretor) { Opportunity opp = gerarOportunidade(); opp.AccountId = conta.Id; opp.Name = 'Teste'; opp.StageName = 'Negociação'; opp.CloseDate = System.today().addDays(15); opp.Contato__c = corretor.Id; return opp; }
	public static OpportunityContactRole gerarOpportunityContactRole(Opportunity opp) { OpportunityContactRole oppContact = new OpportunityContactRole(); oppContact.Role = 'Comprador'; oppContact.OpportunityId = opp.Id; return oppContact; }
	public static OpportunityContactRole gerarOpportunityContactRole(Opportunity opp, Contact ctt) { OpportunityContactRole oppContact = gerarOpportunityContactRole(opp); oppContact.ContactId = ctt.Id; return oppContact; }
	public static OpportunityLineItem gerarOpportunityLineItem(Opportunity opportunity, Product2 product) { OpportunityLineItem oli = new OpportunityLineItem(); oli.OpportunityId = opportunity.Id; oli.Quantity = 3; oli.TotalPrice = 12; return oli; }
 
    public static ProcessInstance gerarProcessInstance(Opportunity opp, ProcessDefinition pd) {
        ProcessInstance pi = new ProcessInstance();
        pi.ProcessDefinitionId = pd.Id;
        pi.Status = 'Approved';
        pi.TargetObjectId = opp.Id;
        return pi;
    }
	
    public static QuoteLineItem gerarQuoteLineItem(Quote quote, PricebookEntry pricebookEntry) { QuoteLineItem quoteline = new QuoteLineItem(); quoteline.QuoteId = quote.Id; quoteline.PricebookEntryId = pricebookEntry.Id; quoteline.Quantity = 1; quoteline.UnitPrice = 100; return quoteline; }
	public static SeriePagamentos__c gerarSeriePagamento(Id idTabela) { SeriePagamentos__c serie = new SeriePagamentos__c(); serie.Name = 'Teste'; serie.InicioPagamento__c = 1; serie.QuantidadeParcelas__c = 1; serie.ValorTotal__c = 1; serie.TabelaVenda__c = idTabela; serie.TipoCondicao__c = 'Ato'; return serie; }
	public static SeriePagamentosService.ObjetoSerie gerarObjetoSerie(String nomeSerie, Id idTabelaVenda) { SeriePagamentosService.ObjetoSerie serie = new SeriePagamentosService.ObjetoSerie(); serie.nome = nomeSerie; serie.valorTotal = 4; serie.quantidadeParcelas = 1; serie.periodicidade = 1; serie.inicioPagamento = 0; serie.aposHabiteSe = false; return serie; }
    
    public static UnidadeTabelaVendas__c gerarUnidadeTabelaVendas(Id idTabela){
        UnidadeTabelaVendas__c unidadeVenda = new UnidadeTabelaVendas__c();
        unidadeVenda.Name = 'UnidadeVendaTeste';
        unidadeVenda.TabelaVenda__c = idTabela;
        unidadeVenda.PrecoLista__c = 300000;
        return unidadeVenda;
    } 

    public static Bloco__c gerarBloco(Empreendimento__c empreendimento) { Bloco__c bloco = gerarBloco(empreendimento.Id); return bloco; }
	public static Bloco__c gerarBloco(Id idEmpreendimento) { Bloco__c bloco = new Bloco__c(); bloco.Name = 'Teste'; bloco.Empreendimento__c = idEmpreendimento; bloco.DataLancamento__c = Date.today(); bloco.DataEntrega__c = Date.today().addMonths(12); bloco.QuantidadeAndares__c = 10; bloco.TotalUnidades__c = 50; return bloco; }
	// public static Garagem__c gerarGaragem(String nome, Integer numVagas) { Garagem__c garagem = new Garagem__c(Name = nome, NumeroVagas__c = numVagas); return garagem; }
	// public static Product2[] gerarVagasParaGaragem(Integer qtdVagas, Id idGaragem, RecordType rt) { List<Product2> listProducts = new List<Product2>(); for (Integer i = 0; i < qtdVagas; i++) { listProducts.add(new Product2(Name = 'Produto ' + i, RecordTypeId = rt.Id, NumeroDaUnidade__c = 1000 + i, Status__c = 'Reservada', Garagem__c = idGaragem)); } return listProducts; }
}