public class EnviarMensagemQueueable implements Queueable, Database.AllowsCallouts {
    private Id idLead;
    private String mensagemTexto;

    public EnviarMensagemQueueable(Id idLead, String mensagemTexto) {
        this.idLead = idLead;
        this.mensagemTexto = mensagemTexto;
    }

    /**
     * Metodo que executa a chamada ao serviço de envio de mensagens via WhatsApp.
     * 
     * @param context Contexto da fila de execução.
     */
    public void execute(QueueableContext context) {
        WhatsAppService.enviarMensagem(idLead, mensagemTexto);
    }
}
