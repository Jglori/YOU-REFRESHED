public class EnviarMensagemQueueable implements Queueable, Database.AllowsCallouts {
    private Id idLead;
    private String mensagemTexto;

    public EnviarMensagemQueueable(Id idLead, String mensagemTexto) {
        this.idLead = idLead;
        this.mensagemTexto = mensagemTexto;}public void execute(QueueableContext context) {WhatsAppService.enviarMensagem(idLead, mensagemTexto);
    }
}