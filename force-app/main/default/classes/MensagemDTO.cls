public class MensagemDTO {
    public Id id;
    public String certificado;
    public String chaveExterna;
    public String chaveExternaCliente;
    public String chaveExternaMidia;
    public Decimal codigoStatus;
    public String conteudo;
    public String corpoRequisicao;
    public Datetime dataHora;
    public String de;
    public String nomeArquivo;
    public String status;
    public String tipo;
    public String tipoMidia;
    public String urlMidia;

    public MensagemDTO(Mensagem__c mensagem) {
        this.id = mensagem.Id;
        this.certificado = mensagem.Certificado__c;
        this.chaveExterna = mensagem.ChaveExterna__c;
        this.chaveExternaCliente = mensagem.ChaveExternaCliente__c;
        this.chaveExternaMidia = mensagem.ChaveExternaMidia__c;
        this.codigoStatus = mensagem.CodigoStatus__c;
        this.conteudo = mensagem.Conteudo__c;
        this.corpoRequisicao = mensagem.CorpoRequisicao__c;
        this.dataHora = mensagem.DataHora__c;
        this.de = mensagem.De__c;
        this.nomeArquivo = mensagem.NomeArquivo__c;
        this.status = mensagem.Status__c;
        this.tipo = mensagem.Tipo__c;
        this.tipoMidia = mensagem.TipoMidia__c;
        this.urlMidia = mensagem.URLMidia__c;
    }
}