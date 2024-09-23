public class ContentDistributionDomain {
    public static ContentDistribution obterDistribuicaoPorIdArquivo(Id idArquivo) {
        List<ContentDistribution> distribuicoesArquivos = ContentDistributionSelector.obterDistribuicoesPorIdsArquivos(new Set<Id>{ idArquivo });

        return distribuicoesArquivos.isEmpty() ? new ContentDistribution() : distribuicoesArquivos.get(0);
    }
}