@isTest
private class BuscaFoneticaFlowCorretoresTest {

    // Método para configurar os dados de teste
    private static void setupTestData() {
        // Obtendo o Record Type para "Corretor"
        Id corretorRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Corretor' LIMIT 1].Id;
        
        // Criando registros de contatos com apelidos
        List<Contact> corretores = new List<Contact>();
        
        corretores.add(new Contact(FirstName='João', LastName='Silva', RecordTypeId=corretorRecordTypeId, Apelido__c='Jao'));
        corretores.add(new Contact(FirstName='Ricardo', LastName='Lima', RecordTypeId=corretorRecordTypeId, Apelido__c='Rick'));
        corretores.add(new Contact(FirstName='Felipe', LastName='Mendes', RecordTypeId=corretorRecordTypeId, Apelido__c='Philipe'));
        corretores.add(new Contact(FirstName='Lucas', LastName='Sousa', RecordTypeId=corretorRecordTypeId, Apelido__c='Lu'));

        insert corretores;
    }

    // Teste para verificar se o método de busca fonética retorna corretamente os resultados
    @isTest
    static void testBuscarNomesFoneticamente() {
        setupTestData();

        // Definindo os parâmetros de entrada
        BuscaFoneticaFlowCorretores.ParametroBusca parametro = new BuscaFoneticaFlowCorretores.ParametroBusca();
        parametro.palavra = 'Jao'; // A palavra que será buscada foneticamente
        
        // Criando a lista de parâmetros
        List<BuscaFoneticaFlowCorretores.ParametroBusca> parametros = new List<BuscaFoneticaFlowCorretores.ParametroBusca>{ parametro };

        Test.startTest();
        
        // Chamando o método invocável
        List<BuscaFoneticaFlowCorretores.RespostaFlow> resposta = BuscaFoneticaFlowCorretores.buscarNomesFoneticamente(parametros);
        
        Test.stopTest();
        
        // Validando a resposta
        System.assertEquals(1, resposta.size(), 'Deve retornar um resultado');
        System.assert(resposta[0].encontrou, 'Deve encontrar uma correspondência fonética');
    }

    // Teste para verificar se o método lança exceção quando a palavra de busca está em branco
    @isTest
    static void testBuscarNomesFoneticamentePalavraEmBranco() {
        setupTestData();

        // Definindo os parâmetros de entrada com palavra em branco
        BuscaFoneticaFlowCorretores.ParametroBusca parametro = new BuscaFoneticaFlowCorretores.ParametroBusca();
        parametro.palavra = ''; // Palavra em branco
        List<BuscaFoneticaFlowCorretores.ParametroBusca> parametros = new List<BuscaFoneticaFlowCorretores.ParametroBusca>{ parametro };

        Test.startTest();
        
        // Esperando uma IllegalArgumentException
        try {
            BuscaFoneticaFlowCorretores.buscarNomesFoneticamente(parametros);
            System.assert(false, 'Deveria ter lançado IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            System.assertEquals('A palavra de busca não pode ser vazia.', e.getMessage());
        }
        
        Test.stopTest();
    }

    // Teste para verificar se o método retorna correto resultado quando não encontrar correspondência
    @isTest
    static void testBuscarNomesFoneticamenteSemResultado() {
        setupTestData();

        // Definindo os parâmetros de entrada com uma palavra que não vai ser encontrada
        BuscaFoneticaFlowCorretores.ParametroBusca parametro = new BuscaFoneticaFlowCorretores.ParametroBusca();
        parametro.palavra = 'Xuxa'; // Palavra que não corresponde a nenhum apelido foneticamente
        
        // Criando a lista de parâmetros
        List<BuscaFoneticaFlowCorretores.ParametroBusca> parametros = new List<BuscaFoneticaFlowCorretores.ParametroBusca>{ parametro };

        Test.startTest();
        
        // Chamando o método invocável
        List<BuscaFoneticaFlowCorretores.RespostaFlow> resposta = BuscaFoneticaFlowCorretores.buscarNomesFoneticamente(parametros);
        
        Test.stopTest();
        
        // Validando a resposta
        System.assertEquals(1, resposta.size(), 'Deve retornar um resultado');
        System.assert(!resposta[0].encontrou, 'Não deve encontrar uma correspondência fonética');
    }
}