public class CustomMetadataTypeDomain {
    public static Map<String, ConfiguracaoCanalAtendimento__mdt> obterConfiguracoesPorCanalAntendimento() {
        Map<String, ConfiguracaoCanalAtendimento__mdt> configuracoesPorCanal = new Map<String, ConfiguracaoCanalAtendimento__mdt>();
        for(ConfiguracaoCanalAtendimento__mdt configuracao : ConfiguracaoCanalAtendimento__mdt.getAll().values()) {
            configuracoesPorCanal.put(configuracao.CanalAtendimento__c, configuracao);
        }

        return configuracoesPorCanal;
    }
}