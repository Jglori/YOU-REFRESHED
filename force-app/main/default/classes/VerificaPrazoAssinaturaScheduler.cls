public class VerificaPrazoAssinaturaScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        VerificaPrazoAssinaturaBatch batch = new VerificaPrazoAssinaturaBatch();
        Database.executeBatch(batch, 100);
    }
}