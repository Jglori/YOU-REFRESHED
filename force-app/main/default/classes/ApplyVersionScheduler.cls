global class ApplyVersionScheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        // Lógica de agendamento
        Datetime limitDate = Datetime.now().addMinutes(5); // Exemplo de limite de data
        ApplyVersion batch = new ApplyVersion(limitDate);
        Database.executeBatch(batch);
    }
}