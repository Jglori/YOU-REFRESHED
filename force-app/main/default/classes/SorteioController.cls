public class SorteioController {
    @InvocableMethod(label='Executar Sorteio' description='Executa o sorteio de participantes')
    public static void executarSorteioFlow(List<String> dummyParam) {
        // Chamando o serviço de sorteio
        SortearParticipantesService.sortear();
    }
}