public class CronExpressionDomain {
    public static String agendarProximaExecucao(Datetime dia, SortearParticipantesSchedulable instancia) {
        return System.schedule(SortearParticipantesSchedulable.class.getName() + ' ' + dia, obterCronExpressionPara(dia), instancia);
    }

    public static String obterCronExpressionPara(Datetime dia) {
        return dia.second() + ' ' + dia.minute() + ' ' + dia.hour() + ' ' + dia.day() + ' ' + dia.month() + ' ? ' + dia.year();
    }
}