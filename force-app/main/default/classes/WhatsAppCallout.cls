public virtual class WhatsAppCallout extends RestCallout {
    private static final String WHATSAPP_ENDPOINT = 'callout:WhatsApp';
    private static final String WHATSAPP_USERNAME = '{!$Credential.Username}';
    private static final String WHATSAPP_PASSWORD = '{!$Credential.Password}';

    private WhatsAppCallout(Map<String, Object> callout) {
        super(callout);
    }

    /**
     * Método responsável pela obtenção de URL para mídia enviada pela WhatsApp
     * a partir do Id da mídia.
     */
    public static HttpResponse obterURLMidia(String idMidia) {
        return (new WhatsAppCallout(
            new Map<String, Object>{
                'endpoint' => 'https://graph.facebook.com/v17.0/' + idMidia,
                'method' => 'GET',
                'header' => new Map<String, String>{
                    'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer ' + IntegracaoWhatsapp__mdt.getInstance('POCWhatsapp').Token_de_Acesso__c
                }
            }
        )).send();
    }

    /**
     * Método responsável pela obtenção de mídia enviada pela WhatsApp a partir 
     * da URL gerada para a mídia.
     */
    public static HttpResponse obterMidia(String urlMidia) {
        return (new WhatsAppCallout(
            new Map<String, Object>{
                'endpoint' => urlMidia,
                'method' => 'GET',
                'header' => new Map<String, String>{
                    'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer ' + IntegracaoWhatsapp__mdt.getInstance('POCWhatsapp').Token_de_Acesso__c
                }
            }
        )).send();
    }

    /**
     * Método responsável pelo envio de mensagem por WhatsApp. Informações como
     * remetente e destinatário são definidas no corpo da mensagem.
     */
    public static HttpResponse enviarMensagem(String body) {
        System.debug('body do post para enviar mensagem: ' + body);
        return (new WhatsAppCallout(
            new Map<String, Object>{
                'endpoint' => 'https://graph.facebook.com/v17.0/' + IntegracaoWhatsapp__mdt.getInstance('POCWhatsapp').IdDoNumeroDoWhatsappBusiness__c + '/messages',
                'method' => 'POST',
                'body' => body,
                'header' => new Map<String, String>{
                    'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer ' + IntegracaoWhatsapp__mdt.getInstance('POCWhatsapp').Token_de_Acesso__c
                }
            }
        )).send();
    }

    public static HttpResponse enviarMidia(String body) {
        String endpoint = 'https://graph.facebook.com/v17.0/' + IntegracaoWhatsapp__mdt.getInstance('POCWhatsapp').IdDoNumeroDoWhatsappBusiness__c + '/messages';
        String authorizationToken = IntegracaoWhatsapp__mdt.getInstance('POCWhatsapp').Token_de_Acesso__c;
    
        return (new WhatsAppCallout(
            new Map<String, Object>{
                'endpoint' => endpoint,
                'method' => 'POST',
                'body' => body,
                'header' => new Map<String, String>{
                    'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer ' + authorizationToken
                }
            }
        )).send();
    }

    public static HttpResponse enviarTemplatePadrao(String body) {
        String endpoint = 'https://graph.facebook.com/v17.0/' + IntegracaoWhatsapp__mdt.getInstance('POCWhatsapp').IdDoNumeroDoWhatsappBusiness__c + '/messages';
        String authorizationToken = IntegracaoWhatsapp__mdt.getInstance('POCWhatsapp').Token_de_Acesso__c;

        return (new WhatsAppCallout(
            new Map<String, Object>{
                'endpoint' => endpoint,
                'method' => 'POST',
                'body' => body,
                'header' => new Map<String, String>{
                    'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer ' + authorizationToken
                }
            }
        )).send();
    }
}