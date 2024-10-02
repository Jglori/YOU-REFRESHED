public with sharing class EspelhoVendasService {

    
    public static List<Empreendimento__c> getEmpreendimentosDisponiveis() {
        return [
            SELECT Id, Name
            FROM Empreendimento__c
            WHERE DisponivelEspelho__c = TRUE
        ];
    }

     
	public static List<Product2> retornarUnidadesDisponiveis(Id idEmpreendimento) {
        String query = 'SELECT Id, Name, ProductCode, PrecoLista__c, Status__c, Andar__c, CorDisponivel__c, Bloco__r.name, RecordType.name, CorReservado__c, CorVendida__c, ValorM2__c, NumeroDeSuites__c, NumeroQuartos__c, Empreendimento__r.name, Empreendimento__r.DiasDeVencimentoDaParcela__c, NumeroDaUnidade__c ' +
                       'FROM Product2 ' +
                       'WHERE Status__c != \'\' AND Empreendimento__r.DisponivelEspelho__c = true AND Empreendimento__c = :idEmpreendimento';
    return Database.query(query);
    }

    
    
    public static List<String> buscarNomesEmpreendimentos() {
        List<Product2> products = [SELECT Empreendimento__r.Name FROM Product2 WHERE Empreendimento__r.Name != NULL];
        Set<String> empreendimentoNames = new Set<String>();

        for (Product2 product : products) {
            if (product.Empreendimento__r != null && product.Empreendimento__r.Name != null) {
                empreendimentoNames.add(product.Empreendimento__r.Name);
            }
        }

        return new List<String>(empreendimentoNames);
    }
    
    public static List<Bloco__c> buscarBlocosPorEmpreendimento(Id idEmpreendimento) {
        return [SELECT id, name FROM Bloco__c WHERE Empreendimento__c =: idEmpreendimento];
        // List<Product2> products = [SELECT Bloco__r.Name FROM Product2 WHERE Bloco__r.Name != NULL];
        // Set<String> blocoNames = new Set<String>();
        // for (Product2 product : products) {
        //     if (product.Bloco__r != null && product.Bloco__r.Name != null) {
        //         blocoNames.add(product.Bloco__r.Name);
        //     }
        // }
        // return new List<String>(blocoNames);
    }

    
    public static List<Configura_o_de__mdt> getConfiguracaoEspelho() {
        List<Configura_o_de__mdt> configuracoes = [SELECT Id, Status__c, Cor__c FROM Configura_o_de__mdt];
        return configuracoes != null ? configuracoes : new List<Configura_o_de__mdt>();
    }


    
    public static List<String> buscarStatusUnidades() {
        List<Product2> products = [SELECT Status__c FROM Product2 WHERE Status__c != NULL];
        Set<String> statusSet = new Set<String>();
        for (Product2 product : products) {
            if (product.Status__c != null) {
                statusSet.add(product.Status__c);
            }
        }
        return new List<String>(statusSet);
    }

    
    public static List<RecordType> buscarTiposUnidades() {
        return [select name, id from RecordType where SobjectType = 'Product2'];
    }
    
    public static List<Product2> getUnidades(String empreendimentoId, String bloco, String andar, String status, String finalUnidade) {
        List<Product2> unidades = new List<Product2>();

       String query = 'SELECT Id, Name, ProductCode, Description, Family, PrecoLista__c, Status__c, Andar__c, CorDisponivel__c, CorReservado__c, CorVendida__c, ValorM2__c FROM Product2';
        List<String> conditions = new List<String>(); 
        Map<String, Object> params = new Map<String, Object>();

        if (!String.isEmpty(empreendimentoId)) {
            conditions.add('Empreendimento__c = :empreendimentoId');
            params.put('empreendimentoId', empreendimentoId);
        }
        
        if (!String.isEmpty(bloco)) {
            conditions.add('Bloco__c = :bloco');
            params.put('bloco', bloco);
        }

        if (!String.isEmpty(andar)) {
            conditions.add('Andar__c = :andar');
            params.put('andar', andar);
        }

        if (!String.isEmpty(status)) {
            conditions.add('Status__c = :status');
            params.put('status', status);
        }

        if (!String.isEmpty(finalUnidade)) {
            conditions.add('Final_da_Unidade__c = :finalUnidade');
            params.put('finalUnidade', finalUnidade);
        }

        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
        
        query += ' ORDER BY Andar__c, Name';

        unidades = Database.query(query);
        
        return unidades;
    }
}