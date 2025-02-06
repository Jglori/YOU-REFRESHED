@isTest
public class CustomExceptionTest {

    // Método de teste para verificar se a exceção CustomException é lançada
    @isTest
    static void testCustomException() {
        // Usando um bloco try-catch para testar a exceção personalizada
        try {
            // Chama o método que lança a exceção
            testMethodThatThrowsException();
            // Se a exceção não for lançada, falha o teste
            System.assert(false, 'A exceção CustomException deveria ter sido lançada.');
        } catch (CustomException e) {
            // Verifica se a exceção CustomException foi lançada
            System.assert(e.getMessage().contains('Erro customizado'), 'Mensagem de erro não é a esperada');
            System.debug('Exceção CustomException capturada com sucesso: ' + e.getMessage());
        }
    }

    // Método fictício que lança a CustomException
    private static void testMethodThatThrowsException() {
        // Lançando a exceção CustomException
        throw new CustomException('Erro customizado');
    }
}