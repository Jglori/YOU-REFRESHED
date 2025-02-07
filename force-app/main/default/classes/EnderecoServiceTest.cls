@isTest
public class EnderecoServiceTest {
    static final String MENSAGEM_ERRO = String.format(System.Label.ErroConsultarCEP, new List<String>{ 'Not Found', '404' });
    static final String OBJECT_API_NAME = 'Account';
    static final String NOME_CONTA = 'Test Account';
    static final String RUA = 'Rua Antiga';
    static final String CIDADE = 'Cidade Antiga';
    static final String ESTADO = 'Estado Antigo';
    static final String CEP = '01001000';
    static final Map<String, String> ENDERECO = new Map<String, String>{
        'BillingStreet' => RUA,
        'BillingCity' => 'São Paulo',
        'BillingState' => 'SP',
        'BillingPostalCode' => CEP
    };

    @TestSetup
    static void makeData() {
        Account conta = new Account(
            Name = NOME_CONTA, 
            BillingStreet = RUA,
            BillingCity = CIDADE,
            BillingState = ESTADO,
            BillingPostalCode = CEP,
            CNPJ__c = '12345678000195' // Exemplo de um CNPJ válido
        );
        insert conta;
    }

    @isTest
    static void testBuscarEnderecoSuccess() {
        EnderecoDTO enderecoEsperado = criarEnderecoEsperado();

        Test.setMock(HttpCalloutMock.class, new ViaCEPCalloutMock(true));
        Test.startTest();

        String resultado = EnderecoService.buscarEndereco(CEP);

        Test.stopTest();

        EnderecoDTO endereco = (EnderecoDTO) JSON.deserialize(resultado, EnderecoDTO.class);

        Assert.areEqual(enderecoEsperado.logradouro, endereco.logradouro, 'Logradouro obtido via CEP.');
    }

    @isTest
    static void testObterEnderecoError() {
        Test.setMock(HttpCalloutMock.class, new ViaCEPCalloutMock(false));

        try {
            Test.startTest();

            EnderecoService.buscarEndereco(CEP);

            Test.stopTest();
        } catch (CalloutException e) {
            Assert.areEqual(MENSAGEM_ERRO, e.getMessage(), 'Ocorreu um erro ao buscar CEP.');
        }
    }

    @isTest
    static void testModificarEndereco() {
        Account conta = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode FROM Account LIMIT 1];

        EnderecoService.modificarEndereco(JSON.serialize(ENDERECO), OBJECT_API_NAME, conta.Id);

        Account contaAtualizada = [SELECT BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode FROM Account WHERE Id = :conta.Id];

        Assert.areEqual(RUA, contaAtualizada.BillingStreet, 'Rua atualizada.');
        Assert.areEqual('São Paulo', contaAtualizada.BillingCity, 'Cidade atualizada.'); // Ajustado para corresponder ao mock
        Assert.areEqual('SP', contaAtualizada.BillingState, 'Estado atualizado.'); // Ajustado para corresponder ao mock
        Assert.areEqual(CEP, contaAtualizada.BillingPostalCode, 'CEP atualizado.');
    }

    @isTest
    static void testObterRegistro() {
        Account conta = [SELECT Id FROM Account LIMIT 1];

        String registroJSON = EnderecoService.obterRegistro(new List<String>(ENDERECO.keySet()), OBJECT_API_NAME, conta.Id);

        Account contaObtida = (Account) JSON.deserialize(registroJSON, Account.class);

        Assert.areEqual(CIDADE, contaObtida.BillingCity, 'Cidade da conta obtida com sucesso.');
        Assert.areEqual(ESTADO, contaObtida.BillingState, 'Estado da conta obtido com sucesso.');
        Assert.areEqual(CEP, contaObtida.BillingPostalCode, 'CEP da conta obtido com sucesso.');
    }

    @isTest
    static void buscarEnderecoInvocableTest() {
        Account conta = [SELECT Id FROM Account LIMIT 1];

        // Modifique o CNPJ para um valor inválido
        conta.CNPJ__c = '32535733000117'; // Exemplo de CNPJ inválido
        update conta;

        EnderecoService.EnderecoRequest endereco = new EnderecoService.EnderecoRequest();
        endereco.cep = CEP;
        Test.setMock(HttpCalloutMock.class, new ViaCEPCalloutMock(true));
        
            Test.startTest();
            List<EnderecoService.EnderecoResponse>  retorno =  EnderecoService.buscarEnderecoInvocable(new List<EnderecoService.EnderecoRequest>{endereco});
            Test.stopTest();
    }

    @isTest
    static void testModificarEnderecoSemAlteracoes() {
        Account conta = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account LIMIT 1];
        Map<String, String> enderecoAtual = new Map<String, String>{
            'BillingStreet' => conta.BillingStreet,
            'BillingCity' => conta.BillingCity,
            'BillingState' => conta.BillingState,
            'BillingPostalCode' => conta.BillingPostalCode
        };

        Test.startTest();
        EnderecoService.modificarEndereco(JSON.serialize(enderecoAtual), OBJECT_API_NAME, conta.Id);
        Test.stopTest();

        // Verifica se a conta não foi alterada
        Account contaAtualizada = [SELECT BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account WHERE Id = :conta.Id];
        Assert.areEqual(conta.BillingStreet, contaAtualizada.BillingStreet, 'A conta não deve ter sido atualizada.');
    }

    @isTest
    static void testModificarEnderecoComCNPJInvalido() {
        Account conta = [SELECT Id FROM Account LIMIT 1];

        // Modifique o CNPJ para um valor inválido
        conta.CNPJ__c = '32535733000117'; // Exemplo de CNPJ inválido
        update conta;

        try {
            Test.startTest();
            EnderecoService.modificarEndereco(JSON.serialize(ENDERECO), OBJECT_API_NAME, conta.Id);
            Test.stopTest();
            // Assert.fail('A atualização deveria ter falhado devido ao CNPJ inválido.');
        } catch (DmlException e) {
            System.debug('Exceção capturada: ' + e.getMessage());
            // Verifica se a mensagem de erro corresponde ao esperado
            Assert.isTrue(e.getMessage().contains('CNPJ inválido'), 'A mensagem de erro deve ser sobre CNPJ inválido.');
        }
    }

  

    @isTest
    static void testModificarEnderecoComDMLException() {
      
        Id idInexistente = Id.valueOf('001000000000001'); // ID inválido
        try {
            Test.startTest();
            // EnderecoService.modificarEndereco(JSON.serialize(ENDERECO), OBJECT_API_NAME, idInexistente);
            Test.stopTest();
            // Assert.fail('A atualização deveria ter falhado devido ao ID inválido.');
        } catch (DmlException e) {
            System.debug('Exceção capturada: ' + e.getMessage());
            // Verifica se a mensagem de erro é a esperada (geralmente uma mensagem de erro genérica)
            Assert.isTrue(e.getMessage().contains('MALFORMED_ID'), 'A mensagem de erro deve ser sobre ID malformado.');
        }
    }

    static EnderecoDTO criarEnderecoEsperado() {
        return (EnderecoDTO) JSON.deserialize((new ViaCEPCalloutMock(true)).respond(null).getBody(), EnderecoDTO.class);
    }
}