public without sharing class MensagemSelector {
    public static List<Mensagem__c> obterMensagensPorIds(Set<Id> idsMensagens) {
        return [
            SELECT 
                Certificado__c,
                ChaveExterna__c,
                ChaveExternaMidia__c,
                ChaveExternaCliente__c,
                CodigoStatus__c,
                Conteudo__c,
                CorpoRequisicao__c,
                DataHora__c,
                De__c,
                NomeArquivo__c,
                Status__c,
                Tipo__c,
                TipoMidia__c,
                URLMidia__c
            FROM Mensagem__c
            WHERE Id IN :idsMensagens
        ];
    }

    public static List<Mensagem__c> obterMensagensPorChavesExternasClientes(Set<String> chavesExternasClientes) {
        return [
            SELECT 
                Certificado__c,
                ChaveExterna__c,
                ChaveExternaMidia__c,
                ChaveExternaCliente__c,
                CodigoStatus__c,
                Conteudo__c,
                CorpoRequisicao__c,
                DataHora__c,
                De__c,
                NomeArquivo__c,
                Status__c,
                Tipo__c,
                TipoMidia__c,
                URLMidia__c
            FROM Mensagem__c
            WHERE ChaveExternaCliente__c IN :chavesExternasClientes
        ];
    }
}