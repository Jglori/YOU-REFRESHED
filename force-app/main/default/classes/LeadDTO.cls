public class LeadDTO {
    public String id;
    public String chaveExternaWhatsApp;
    public String nome;
    public String primeiroNome;
    public String sobrenome;
    public String email;
    public String celular;
    public String status;
    public String proprietario;
    public Datetime inicioDialogo;
    public Datetime fimDialogo;
    public Datetime ultimaMensagem;
    public Datetime CreatedDate;
    public String nomeCorretor;
    public String telefone;

    public Decimal carga;
    public Decimal cargaRestante;
    public Boolean naoPodeAceitar;

    public LeadDTO(Lead lead) {
        Map<String, Object> camposLeadPorNomeAPI = lead.getPopulatedFieldsAsMap();

        this.id = lead.Id;
        this.chaveExternaWhatsApp = camposLeadPorNomeAPI.containsKey('ChaveExternaWhatsApp__c') ? lead.ChaveExternaWhatsApp__c : null;
        this.nome = camposLeadPorNomeAPI.containsKey('Name') ? lead.Name : null;
        this.primeiroNome = camposLeadPorNomeAPI.containsKey('FirstName') ? lead.FirstName : null;
        this.sobrenome = camposLeadPorNomeAPI.containsKey('LastName') ? lead.LastName : null;
        this.celular = camposLeadPorNomeAPI.containsKey('MobilePhone') ? lead.MobilePhone : null;
        this.email = camposLeadPorNomeAPI.containsKey('Email') ? lead.Email : null;
        this.status = camposLeadPorNomeAPI.containsKey('Status') ? lead.Status : null;
        this.proprietario = camposLeadPorNomeAPI.containsKey('Owner.Name') ? lead.Owner.Name : null;
        this.inicioDialogo = camposLeadPorNomeAPI.containsKey('InicioDialogo__c') ? lead.InicioDialogo__c : null;
        this.fimDialogo = camposLeadPorNomeAPI.containsKey('FimDialogo__c') ? lead.FimDialogo__c : null;
        this.ultimaMensagem = camposLeadPorNomeAPI.containsKey('UltimaMensagem__c') ? lead.UltimaMensagem__c : null;
        this.CreatedDate = camposLeadPorNomeAPI.containsKey('CreatedDate') ? lead.CreatedDate : null;
        //this.nomeCorretor = (lead.CorretorContato__r != null) ? lead.CorretorContato__r.Name : null;
        this.telefone = camposLeadPorNomeAPI.containsKey('Phone') ? lead.Phone : null;
    }

    public LeadDTO(Lead lead, ConfiguracaoCanalAtendimento__mdt configuracaoCanalAtendimento) {
        this(lead);

        this.carga = configuracaoCanalAtendimento?.Carga__c;
        this.cargaRestante = lead.Corretor__r?.CargaRestante__c;
        this.naoPodeAceitar = !(configuracaoCanalAtendimento?.Bypass__c ?? false) && (this.carga > this.cargaRestante);
    }
}