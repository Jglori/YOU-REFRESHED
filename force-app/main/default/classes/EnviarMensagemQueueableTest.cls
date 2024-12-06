@isTest
public class EnviarMensagemQueueableTest {
    @isTest
    static void testEnviarMensagemQueueableConstructor() {
        // Criar um Lead real
        Lead testLead = new Lead(
            LastName = 'Teste Silva',
            Company = 'Teste Company',
            Email = 'teste.silva@empresa.com',
            MobilePhone = '11987654321',
            Status = 'Novo'
        );
        insert testLead;

        // Mensagem de teste
        String mensagem = 'Olá, esta é uma mensagem de teste.';

        // Instanciar a classe Queueable
        EnviarMensagemQueueable queueableJob = new EnviarMensagemQueueable(testLead.Id, mensagem);

    }
}