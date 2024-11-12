public class UserDTO {
    public String id;
    public String situacao;
    public List<String> canaisAtendimento;

    public UserDTO(User usuario) {
        this.id = usuario.Id;
        this.situacao = usuario.Situacao__c;
        this.canaisAtendimento = String.isBlank(usuario.CanaisAtendimento__c) ? new List<String>() : usuario.CanaisAtendimento__c.split(';');
    }
}