public class SortearParticipantesService {
    /**
     * Método responsável pela obtenção dos sorteios criados porém ainda não executados
     * para embaralhamento dos participantes das roletas relacionadas.
     */
    public static void sortear() {
        List<Sorteio__c> sorteiosAtivos = SorteioSelector.obterSorteiosAtivos();

        System.debug('Sorteios ativos: ' + sorteiosAtivos);
        if (sorteiosAtivos.isEmpty()) { return; }

        sortear(sorteiosAtivos);
    }

    /**
     * Método responsável pela obtenção dos participantes das roletas de leads associadas
     * aos sorteios para embaralhamento. Ao final, os sorteios executados são finalizados.
     */
    public static void sortear(List<Sorteio__c> sorteios) {
        System.debug('Sorteios LINHA 21: ' + sorteios);
        List<ParticipanteRoleta__c> participantes = ParticipanteRoletaDomain.obterParticipantesPorSorteios(sorteios);

        System.debug('Participantes LINHA 24: ' + participantes);
        if (participantes.isEmpty()) { return; }

        Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoleta = ParticipanteRoletaDomain.obterParticipantesPorIdRoleta(participantes);

        System.debug('Participantes por id roleta LINHA 29: ' + participantesPorIdRoleta);
        embaralharParticipantes(participantesPorIdRoleta);
        finalizarSorteios(sorteios);
    }

    private static void finalizarSorteios(List<Sorteio__c> sorteios) {
        for (Sorteio__c sorteio : sorteios) {
            sorteio.Status__c = 'Finalizado';
        }

        update sorteios;
    }

    public static void embaralharParticipantes(Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoleta) {
        List<ParticipanteRoleta__c> participantesParaEmbaralhar = new List<ParticipanteRoleta__c>();
        for (Id idRoleta : participantesPorIdRoleta.keySet()) {
            List<ParticipanteRoleta__c> participantesEmbaralhados = obterParticipantesEmbaralhados(participantesPorIdRoleta.get(idRoleta));

            DistribuirLeadsService.reordenarParticipantesRoletasLeads(participantesEmbaralhados);

            participantesParaEmbaralhar.addAll(participantesEmbaralhados);
        }

        update participantesParaEmbaralhar;
    }

    /**
     * Método responsável pelo embaralhamento dos participantes da roleta de forma
     * aleatória utilizando o algoritmo de Fisher-Yates.
     */
    private static List<ParticipanteRoleta__c> obterParticipantesEmbaralhados(List<ParticipanteRoleta__c> participantes) {
        List<ParticipanteRoleta__c> participantesAux = new List<ParticipanteRoleta__c>(participantes);
        Integer n = participantesAux.size();

        for (Integer i = 0; i < n; i++) {
            Integer j = Integer.valueOf(Math.floor(Math.random() * (n - i)) + i);
            // Troca os elementos nas posições i e j
            ParticipanteRoleta__c temp = participantesAux[i];
            participantesAux[i] = participantesAux[j];
            participantesAux[j] = temp;
        }

        return participantesAux;
    }
}