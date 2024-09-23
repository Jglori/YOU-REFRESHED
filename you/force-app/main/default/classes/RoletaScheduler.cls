global class RoletaScheduler implements Schedulable {
    public Id roletaId;

    public RoletaScheduler(Id roletaId) {
        this.roletaId = roletaId;
    }

    global void execute(SchedulableContext SC) {
        RoletaLeadsDA.limparParticipantesRoleta(this.roletaId);
    }
}