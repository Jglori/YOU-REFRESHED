public class EmpreendimentoSelector {
    public static List<Empreendimento__c> getEmpreendimentoRecords() {
        return [
            SELECT 
                Name
                // EnderecoDoEmpreendimento__City__s, 
                // EnderecoDoEmpreendimento__StateCode__s, 
                // Regiao__c 
            FROM Empreendimento__c 
            ORDER BY Name
        ];
    }

    public static Empreendimento__c obterNomeEmpreendimentoById(Id idEmpreendimento) {
        return [
            SELECT 
                Name
            FROM Empreendimento__c 
            WHERE Id = :idEmpreendimento
        ];
    }
}