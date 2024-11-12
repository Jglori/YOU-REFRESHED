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

    public static Empreendimento__c getEmpreendimentoById(String id) {
        return [SELECT CNPJEmpreendimento__c, DataEntregaChaves__c, DataHabitase__c, StatusObra__c, CEP__c, Logradouro__c,
                   Bairro__c, Numero__c, Complemento__c, Cidade__c, UF__c, Fundacao__c, Estrutura__c, Alvenaria__c,
                   Acabamento__c, AreaExterna__c, EvolucaoObra__c, Instalacoes__c, TipoEmpreendimento__c,
                   DiasDeVencimentoDaParcela__c, ValorM__c, MetragemPrivativaTotal__c, MetragemTerreno__c,
                   MetragemConstruIdaM__c, OpcoesLazerDisponiveis__c, FracaoIdealTotal__c, Name
            FROM Empreendimento__c WHERE Id = :id
        ];
    }
}