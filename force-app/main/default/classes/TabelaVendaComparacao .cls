
public class TabelaVendaComparacao {
    @AuraEnabled(cacheable=true)

    public static Opportunity obterTabelaPorId(Id oppId) {
        // Obter o Empreendimento relacionado à Oportunidade
        Opportunity opp = [SELECT Id, Empreendimento__c FROM Opportunity WHERE Id = :oppId LIMIT 1];

        // Verificar se a Oportunidade retornou um Empreendimento
        if (opp.Empreendimento__c != null) {
            // Obter o Desconto Nominal da Tabela de Vendas relacionada ao Empreendimento
            TabelaVendas__c tabelaVenda = [SELECT Id, DescontoNominalMoeda__c
                                           FROM TabelaVendas__c 
                                           WHERE Empreendimento__c = :opp.Empreendimento__c 
                                           LIMIT 1];

            // Obter o Valor por metro quadrado (ValorM2__c) de um produto relacionado ao Empreendimento
            Product2 produto = [SELECT Id, ValorM2__c
                                FROM Product2 
                                WHERE Empreendimento__c = :opp.Empreendimento__c 
                                LIMIT 1];

            // Atribuir esses valores a propriedades na Opportunity ou retorná-los de outra forma

            opp.put('DescontoNominalMoeda__c', tabelaVenda.DescontoNominalMoeda__c);
            opp.put('ValorM2__c', produto.ValorM2__c);
        }

        return opp;
    }
}
