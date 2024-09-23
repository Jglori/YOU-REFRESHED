public class SortearParticipantesService {
    /**
     * Método responsável pela obtenção dos sorteios criados porém ainda não executados
     * para embaralhamento dos participantes das roletas relacionadas.
     */
    public static void sortear() {
        List<Sorteio__c> sorteiosAtivos = SorteioSelector.obterSorteiosAtivos();

        if(sorteiosAtivos.isEmpty()) { return; }

        sortear(sorteiosAtivos);
    }

    /**
     * Método responsável pela obtenção dos participantes das roletas de leads associadas
     * aos sorteios para embaralhamento. Ao final, os sorteios executados são finalizados.
     */
    public static void sortear(List<Sorteio__c> sorteios) {
        List<ParticipanteRoleta__c> participantes = ParticipanteRoletaDomain.obterParticipantesPorSorteios(sorteios);

        if(participantes.isEmpty()) { return; }

        Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoleta = ParticipanteRoletaDomain.obterParticipantesPorIdRoleta(participantes);

        embaralharParticipantes(participantesPorIdRoleta);
        finalizarSorteios(sorteios);
    }

    private static void finalizarSorteios(List<Sorteio__c> sorteios) {
        for(Sorteio__c sorteio : sorteios) {
            sorteio.Status__c = 'Finalizado';
        }

        update sorteios;
    }

    private static void embaralharParticipantes(Map<Id, List<ParticipanteRoleta__c>> participantesPorIdRoleta) {
        List<ParticipanteRoleta__c> participantesParaEmbaralhar = new List<ParticipanteRoleta__c>();
        for(Id idRoleta : participantesPorIdRoleta.keySet()) {
            List<ParticipanteRoleta__c> participantesEmbaralhados = obterParticipantesEmbaralhados(participantesPorIdRoleta.get(idRoleta));

            DistribuirLeadsService.reordenarParticipantesRoletasLeads(participantesEmbaralhados);

            participantesParaEmbaralhar.addAll(participantesEmbaralhados);
        }

        update participantesParaEmbaralhar;
    }

    /**
     * Método responsável pelo embaralhamento dos participantes da roleta de forma
     * aleatória.
     */
    private static List<ParticipanteRoleta__c> obterParticipantesEmbaralhados(List<ParticipanteRoleta__c> participantes) {
        List<ParticipanteRoleta__c> participantesAux = new List<ParticipanteRoleta__c>(participantes);
        List<ParticipanteRoleta__c> participantesEmbaralhados = new List<ParticipanteRoleta__c>();

        for(Integer i = 0; i < participantes.size(); i++) {
            ParticipanteRoleta__c participanteEscolhido = participantesAux.remove(obterProximaPosicao(participantesAux));

            participantesEmbaralhados.add(participanteEscolhido);
        }

        return participantesEmbaralhados;
    }

    private static Integer obterProximaPosicao(List<ParticipanteRoleta__c> participantes) {
        return Integer.valueOf(Math.random() * (participantes.size() - 1));
    }
}