public class TabelaVendaSelector {
    public static List<UnidadeTabelaVendas__c> obterUnidadeTabelasPorId (Id tabelaVendasId) {
        return [
            SELECT PrecoLista__c
            FROM UnidadeTabelaVendas__c
            WHERE TabelaVenda__c = :tabelaVendasId
            LIMIT 1
        ];
    }

    public static TabelaVendas__c obterTabelasRelacionadas(Id tabelaRelacionada){
        System.debug('tabelaRelacionada: ' + tabelaRelacionada);
        return [
            SELECT
                Id,
                AntecipacaoAteHabiteSe__c,
                AntecipacaoAposHabiteSe__c,
                Empreendimento__c,
                Empreendimento__r.ValorM__c,
                Empreendimento__r.MetragemPrivativaTotal__c
            FROM TabelaVendas__c
            WHERE Id = :tabelaRelacionada LIMIT 1
        ];
    }

    public static List<TabelaVendas__c> obterTabelasPorIdEmpreendimento(Id idEmpreendimento) {
        return [
            SELECT Id, 
                   Name,
                   Situacao__c,
                   Ativa__c,
                   DataInicio__c, //inicio vigencia
                   DataFim__c, //fim vigencia
                   TaxaDescontoVPL__c,
                   TaxaTP__c,
                   AntecipacaoAteHabiteSe__c,
                   AntecipacaoAposHabiteSe__c
            FROM   TabelaVendas__c
            WHERE  Empreendimento__c  = :idEmpreendimento
        ];
    }

    public static List<TabelaVendas__c> obterCotacaoRelacionada(Id idCotacao){
        return [
            SELECT
                Id,
                Cotacao__c
            FROM TabelaVendas__c
            WHERE Cotacao__c = :idCotacao
            ORDER BY Cotacao__c DESC
            LIMIT 1
        ];
    }

    public static TabelaVendas__c buscarTabelaPorIdCotacao(Id idCotacao){
        List<TabelaVendas__c> result = [
            SELECT Id 
            FROM TabelaVendas__c 
            WHERE Cotacao__c = :idCotacao 
            LIMIT 1
        ];
        
        return result.isEmpty() ? null : result[0];
    }

}