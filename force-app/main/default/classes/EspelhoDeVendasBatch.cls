public class EspelhoDeVendasBatch implements Database.Batchable<SObject>, Database.Stateful {
    private List<Empreendimento__c> empreendimentos;
    private Map<String, List<Bloco__c>> BlocosPorEmpreendimento;
    private Map<String, List<Product2>> unidadesPorBloco;

    // Construtor para 1 empreendimento, suas Blocos e unidades
    public EspelhoDeVendasBatch(
        List<Empreendimento__c> empreendimentos,
        Map<String, List<Bloco__c>> BlocosPorEmpreendimento,
        Map<String, List<Product2>> unidadesPorBloco
    ) {
        this.empreendimentos = empreendimentos;
        this.BlocosPorEmpreendimento = BlocosPorEmpreendimento;
        this.unidadesPorBloco = unidadesPorBloco;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        // Placeholder para iniciar o batch (necessário)
        return Database.getQueryLocator([SELECT Id FROM Empreendimento__c LIMIT 1]);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        try {
            // Salva os empreendimentos e cria um mapa de IDs
            Map<String, Id> empreendimentoIdMap = new Map<String, Id>();
            if (!empreendimentos.isEmpty()) {
                upsert empreendimentos Empreendimento__c.CodigoSistemaExterno__c;
                for (Empreendimento__c emp : empreendimentos) {
                    empreendimentoIdMap.put(emp.CodigoSistemaExterno__c, emp.Id);
                }
                System.debug('Mapa de IDs de empreendimentos: ' + empreendimentoIdMap);
            }

            // Atualiza as Blocos com os IDs dos empreendimentos
            List<Bloco__c> BlocosParaSalvar = new List<Bloco__c>();
            Map<String, Id> BlocoIdMap = new Map<String, Id>();
            for (String empreendimentoCodigo : BlocosPorEmpreendimento.keySet()) {
                if (empreendimentoIdMap.containsKey(empreendimentoCodigo)) {
                    Id empreendimentoId = empreendimentoIdMap.get(empreendimentoCodigo);
                    for (Bloco__c Bloco : BlocosPorEmpreendimento.get(empreendimentoCodigo)) {
                        Bloco.Empreendimento__c = empreendimentoId; // Relaciona a Bloco ao empreendimento
                        BlocosParaSalvar.add(Bloco);
                    }
                }
            }

            // Salva as Blocos e cria um mapa de IDs
            if (!BlocosParaSalvar.isEmpty()) {
                upsert BlocosParaSalvar Bloco__c.CodigoSistemaExterno__c;
                for (Bloco__c Bloco : BlocosParaSalvar) {
                    BlocoIdMap.put(Bloco.CodigoSistemaExterno__c, Bloco.Id);
                }
                System.debug('Mapa de IDs de Blocos: ' + BlocoIdMap);
            }

            // Atualiza as unidades com os IDs das Blocos
            List<Product2> unidadesParaSalvar = new List<Product2>();
            for (String BlocoCodigo : unidadesPorBloco.keySet()) {
                if (BlocoIdMap.containsKey(BlocoCodigo)) {
                    Id BlocoId = BlocoIdMap.get(BlocoCodigo);
                    for (Product2 unidade : unidadesPorBloco.get(BlocoCodigo)) {
                        unidade.Bloco__c = BlocoId; // Relaciona a unidade à Bloco
                        unidadesParaSalvar.add(unidade);
                    }
                }
            }

            // Salva as unidades em lotes de até 200 registros
            if (!unidadesParaSalvar.isEmpty()) {
                Integer batchSize = 200; // Define o tamanho do lote
                for (Integer i = 0; i < unidadesParaSalvar.size(); i += batchSize) {
                    Integer batchEnd = Math.min(i + batchSize, unidadesParaSalvar.size());
                    List<Product2> subList = new List<Product2>();
                    for (Integer j = i; j < batchEnd; j++) {
                        subList.add(unidadesParaSalvar[j]);
                    }
                    upsert subList Product2.CodigoSistemaExterno__c;
                    System.debug('Unidades salvas: ' + subList);
                }
            }

        } catch (DmlException e) {
            System.debug('Erro ao processar batch: ' + e.getMessage());
            throw e;
        }
    }

    public void finish(Database.BatchableContext context) {
        System.debug('Batch finalizado para empreendimento.');
    }
}