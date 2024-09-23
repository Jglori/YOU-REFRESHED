public class RoletaLeadsDTO {
    public String id;
    public String nome;
    public String canaisAtendimento;
    public String empreendimento;
    public Time horaInicio;
    public Time horaFim;

    public RoletaLeadsDTO(RoletaLeads__c roletaLeads) {
        this.id = roletaLeads.Id;
        this.nome = roletaLeads.Name;
        this.canaisAtendimento = roletaLeads.CanaisAtendimento__c;
        this.horaInicio = roletaLeads.HoraInicio__c;
        this.horaFim = roletaLeads.HoraFim__c;
    }
}