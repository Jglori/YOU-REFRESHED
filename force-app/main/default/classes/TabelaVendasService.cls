public with sharing class TabelaVendasService {    
    public static Id criarTabelaDaSimulacao(List<SeriePagamentos__c> seriesProposta, Id idCotacao, String nomeCotacao, TabelaVendas__c tabelaSelecionada, Id unidadeSelecionadaId, Decimal nominalProposta){
        
        system.debug('unidadeSelecionadaId: '+unidadeSelecionadaId);

        Integer periocidadeParcelaPos = Integer.valueOf(tabelaSelecionada.PeriodicidadeParcelaPos__c);
        Integer periodicidadeParcela = Integer.valueOf(tabelaSelecionada.PeriodicidadeParcela__c);
         if(periocidadeParcelaPos != 1 && periocidadeParcelaPos != 6 && periocidadeParcelaPos != 12) {
            periocidadeParcelaPos = 1;
        }
        
        if(periodicidadeParcela != 1 && periodicidadeParcela != 6 && periodicidadeParcela != 12) {
            periodicidadeParcela = 1;
        }

        tabelaVendas__c tabelaVendaCotacao = tabelaVendaSelector.buscarTabelaPorIdCotacao(idCotacao);
        
            if(tabelaVendaCotacao != null){
                List<SeriePagamentos__c> seriesTabelaCotacao = SeriePagamentoSelector.obterSeriePorIdTabelaVendas(tabelaVendaCotacao.Id);
                UnidadeTabelaVendas__c unidadeTabelaVendaTabela = UnidadeTabelaSelector.obterUnidadeTabelaVendaPorIdTabelaVendas(tabelaVendaCotacao.Id);
                
                if(seriesTabelaCotacao != null){
                    DELETE seriesTabelaCotacao;
                }
                if(unidadeTabelaVendaTabela != null){
                    DELETE unidadeTabelaVendaTabela;                
                }
                
                DELETE tabelaVendaCotacao;
            }
        RecordType recordType = [SELECT id, name FROM RecordType WHERE SObjectType = 'TabelaVendas__c' AND Name = 'Tabela de Proposta' LIMIT 1];

        TabelaVendas__c novaTabelaCotacao = new TabelaVendas__c();
        novaTabelaCotacao.Name = 'Simulação ' + nomeCotacao;
        novaTabelaCotacao.Cotacao__c = idCotacao;
        novaTabelaCotacao.RecordTypeId = recordType.Id;
        novaTabelaCotacao.PeriodicidadeParcelaPos__c = periocidadeParcelaPos;
        novaTabelaCotacao.PeriodicidadeParcela__c = periodicidadeParcela;
        
        INSERT novaTabelaCotacao;

        for (SeriePagamentos__c serie : seriesProposta) {
            serie.TabelaVenda__c = novaTabelaCotacao.Id;
            serie.ValorTotal__c = serie.ValorTotal__c / 100;
        }
        System.debug(seriesProposta);

        INSERT seriesProposta;

        UnidadeTabelaVendas__c novaUnidadeTabelaVenda = new UnidadeTabelaVendas__c();
        system.debug(unidadeSelecionadaId);
        
        system.debug(novaTabelaCotacao);

        novaUnidadeTabelaVenda.Name = 'Unidade tabela vendas - ' + nomeCotacao;
        novaUnidadeTabelaVenda.Unidade__c = unidadeSelecionadaId;
        novaUnidadeTabelaVenda.PrecoLista__c = nominalProposta;
        novaUnidadeTabelaVenda.TabelaVenda__c = novaTabelaCotacao.id;

        INSERT novaUnidadeTabelaVenda;

     return novaTabelaCotacao.Id;
    }

    public static void inserirUnidadesTabelas(List<TabelaVendas__c> tabelas) {
        Set<Id> empreendimentoIds = new Set<Id>();
        Set<Id> tabelaVendasIds = new Set<Id>();

        for (TabelaVendas__c tab : tabelas) {
            if (tab.Empreendimento__c != null) {
                empreendimentoIds.add(tab.Empreendimento__c);
            }
            tabelaVendasIds.add(tab.Id);
        }

        Map<Id, Product2> unidades = ProdutoSelector.obterUnidadesRelacionadas(empreendimentoIds);
        Map<Id, UnidadeTabelaVendas__c> unidadesExistentes = UnidadeTabelaSelector.obterUnidadesTabelaExistentes(tabelaVendasIds);

        List<UnidadeTabelaVendas__c> unidadesParaAtualizar = new List<UnidadeTabelaVendas__c>();
        List<UnidadeTabelaVendas__c> unidadesParaInserir = new List<UnidadeTabelaVendas__c>();
        List<UnidadeTabelaVendas__c> unidadesParaExcluir = new List<UnidadeTabelaVendas__c>();

        Set<Id> idsExistentesParaManter = new Set<Id>();

        for (TabelaVendas__c tab : tabelas) {
            for (Product2 unidade : unidades.values()) {
                Boolean found = false;

                for (UnidadeTabelaVendas__c existente : unidadesExistentes.values()) {
                    if (existente.Unidade__c == unidade.Id && existente.TabelaVenda__c == tab.Id) {
                        existente.Name = unidade.Name;
                        existente.PrecoLista__c = unidade.PrecoLista__c;
                        existente.CoeficienteTabela__c = unidade.Coeficiente__c;
                        existente.MetragemUnidade__c = unidade.MetragemTotal__c;
                        unidadesParaAtualizar.add(existente);
                        idsExistentesParaManter.add(existente.Id);
                        found = true;
                        break;
                    }
                }

                if (!found) {
                    UnidadeTabelaVendas__c novaUnidadeTabela = new UnidadeTabelaVendas__c();
                    novaUnidadeTabela.Name = unidade.Name;
                    novaUnidadeTabela.PrecoLista__c = unidade.PrecoLista__c;
                    novaUnidadeTabela.CoeficienteTabela__c = unidade.Coeficiente__c;
                    novaUnidadeTabela.MetragemUnidade__c = unidade.MetragemTotal__c;
                    novaUnidadeTabela.Unidade__c = unidade.Id;
                    novaUnidadeTabela.TabelaVenda__c = tab.Id;
                    unidadesParaInserir.add(novaUnidadeTabela);
                }
            }
        }

        for (UnidadeTabelaVendas__c existente : unidadesExistentes.values()) {
            if (!idsExistentesParaManter.contains(existente.Id)) {
                unidadesParaExcluir.add(existente);
            }
        }

        if (!unidadesParaAtualizar.isEmpty()) {
            update unidadesParaAtualizar;
        }
        if (!unidadesParaInserir.isEmpty()) {
            insert unidadesParaInserir;
        }
        if (!unidadesParaExcluir.isEmpty()) {
            delete unidadesParaExcluir;
        }
    }
}