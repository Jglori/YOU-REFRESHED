public class SortearParticipantesSchedulable implements Schedulable {
    /**
     * Método responsável pela execução dos sorteios ativos para embaralhamento
     * aleatório das posições dos participantes das roletas relacionadas.
     */
    public void execute(SchedulableContext SC) {
        SortearParticipantesService.sortear();

        // O processo é executado a cada minuto.
        CronExpressionDomain.agendarProximaExecucao(System.now().addMinutes(1), new SortearParticipantesSchedulable());
    }
}