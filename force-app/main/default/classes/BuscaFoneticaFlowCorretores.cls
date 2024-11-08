public with sharing class BuscaFoneticaFlowCorretores {

    public BuscaFoneticaFlowCorretores() {}

    // Método Invocável
    @InvocableMethod(label='Buscar Corretores por Apelido Foneticamente' description='Busca foneticamente corretores pelo apelido')
    public static List<RespostaFlow> buscarNomesFoneticamente(List<ParametroBusca> parametros) {
        if (parametros.isEmpty() || String.isBlank(parametros[0].palavra)) {
            throw new IllegalArgumentException('A palavra de busca não pode ser vazia.');
        }

        String palavra = parametros[0].palavra;

        // Buscar corretores com apelidos não nulos
        List<Contact> corretores = [SELECT Apelido__c FROM Contact WHERE RecordType.Name = 'Corretor' AND Apelido__c != null];

        // Usando o serviço Metaphone para buscar foneticamente
        MetaphoneService service = new MetaphoneService();

        List<String> apelidos = new List<String>();
        for (Contact corretor : corretores) {
            apelidos.add(corretor.Apelido__c);
        }

        // Chama o método de busca fonética
        List<String> resultado = service.buscaFoneticamente(palavra, apelidos);

        // Verifica se algum resultado foi encontrado
        Boolean encontrou = !resultado.isEmpty();

        // Retorna uma lista de RespostaFlow com o resultado
        List<RespostaFlow> resposta = new List<RespostaFlow>();
        resposta.add(new RespostaFlow(encontrou));

        return resposta;
    }

    // Classe auxiliar para a entrada
    public class ParametroBusca {
        @InvocableVariable(label='Palavra de Busca')
        public String palavra;
    }

    // Classe de Resposta personalizada
    public class RespostaFlow {
        @InvocableVariable(label='Resultado de busca')
        public Boolean encontrou;

        // Construtor
        public RespostaFlow(Boolean encontrou) {
            this.encontrou = encontrou;
        }
    }
}