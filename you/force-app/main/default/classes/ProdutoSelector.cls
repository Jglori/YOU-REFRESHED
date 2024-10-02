public class ProdutoSelector {
    public static Product2 getProdutosById(Id id){
        return [
            SELECT
                Empreendimento__r.Name,
                Empreendimento__r.DiasDeVencimentoDaParcela__c,
                Name, Andar__c,
                MetragemTotal__c,
                NumeroDaUnidade__c,
                NumeroQuartos__c,
                Bloco__r.Name,
                PrecoLista__c,
                Family
            from Product2 where id =: id];
    }

    public static Map<Id, Product2> CoeficienteProdutoPorId(List<Id> produtoIds) {
        Map<Id, Product2> produtoMap = new Map<Id, Product2>([
            SELECT
                Id,
                Coeficiente__c 
            FROM Product2 
            WHERE Id IN :produtoIds
        ]);
        return produtoMap;
    }

    public static Map<Id, Product2> obterUnidadesRelacionadas(set<Id> empreendimento){
        Map<Id, Product2> unidadesMap = new Map<Id, Product2>([
            SELECT
                Id,
                Name,
                PrecoLista__c,
                Coeficiente__c,
                MetragemTotal__c,
                Empreendimento__c
            FROM Product2 
            WHERE Empreendimento__c IN :empreendimento
        ]);
        return unidadesMap;
    }

    public static Product2 buscarUnidadePorSetId(Set<Id> id){
        return[
            SELECT Id, Name, Status__c FROM Product2 WHERE Id = :id
        ];
    }

}