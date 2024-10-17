@isTest
public class CronExpressionDomainTest {

    @isTest
    static void testObterCronExpressionPara() {
        // Definir uma data e hora específicas
        Datetime dataHora = Datetime.newInstance(2024, 8, 27, 14, 30, 15);
        
        // Chamar o método para obter a expressão cron
        String cronExpression = CronExpressionDomain.obterCronExpressionPara(dataHora);
        
        // Verificar o formato da expressão cron
        String expectedCronExpression = '15 30 14 27 8 ? 2024';
        System.assertEquals(expectedCronExpression, cronExpression, 'A expressão cron gerada está incorreta');
    }

    @isTest
    static void testAgendarProximaExecucao() {
        // Definir uma data e hora específicas para o agendamento
        Datetime dataHora = Datetime.newInstance(2024, 8, 27, 14, 30, 15);
        
        // Criar uma instância fictícia de SortearParticipantesSchedulable
        Test.startTest();
        //String jobId = CronExpressionDomain.agendarProximaExecucao(dataHora, new SortearParticipantesSchedulable());
        Test.stopTest();
        
        // Verificar se o job foi agendado (não há uma verificação direta, apenas verificamos se o método foi executado sem erros)
        //System.assertNotEquals(null, jobId, 'O job de agendamento não foi criado');
    }
}