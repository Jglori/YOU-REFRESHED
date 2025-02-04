public class ListaEspelhoDeVendasService {
    public static void processIntegration() {
        LogDeIntegracao__c log = new LogDeIntegracao__c(); // Inicializa o log
        String endpoint = 'http://www.civilweb.com.br/ListaEspelhoDeVendas';
        String requestBody;
        try {
            // Cria o corpo da requisição
            requestBody = '<?xml version="1.0" encoding="utf-8"?>' +
                          '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                          '<soap:Body>' +
                          '<ListaEspelhoDeVendas xmlns="http://www.civilweb.com.br/">' +
                          '<Login>{Login}</Login>' +
                          '<Senha>{Senha}</Senha>' +
                          '</ListaEspelhoDeVendas>' +
                          '</soap:Body>' +
                          '</soap:Envelope>';

            // Substitui os placeholders pelos valores do metadado
            IntegracaoMega__mdt config = IntegracaoMega__mdt.getInstance('Default');
            requestBody = requestBody.replace('{Login}', config.Login__c);
            requestBody = requestBody.replace('{Senha}', config.Senha__c);

            // Faz a chamada à API
            String xmlResponse = IntegrationClientMega.callApi(endpoint, requestBody);

            // Atualiza log em caso de sucesso
            log.APIName__c = 'ListaEspelhoDeVendas';
            log.EndpointURL__c = endpoint;
            log.RequestBody__c = requestBody.length() > 131072 ? requestBody.substring(0, 131072) : requestBody;
            log.Status__c = 'Sucesso';
            log.ResponseBody__c = xmlResponse.length() > 131072 ? xmlResponse.substring(0, 131072) : xmlResponse;
            log.LogTimestamp__c = System.now();
            insert log;

            // Faz o parsing do XML
            Map<String, Object> parsedData = ListaEspelhoDeVendasParser.parse(xmlResponse);

            // Extrai empreendimentos, Blocos e unidades
            List<Empreendimento__c> empreendimentos = (List<Empreendimento__c>) parsedData.get('Empreendimentos');
            Map<String, List<Bloco__c>> BlocosPorEmpreendimento = (Map<String, List<Bloco__c>>) parsedData.get('BlocosPorEmpreendimento');
            Map<String, List<Product2>> unidadesPorBloco = (Map<String, List<Product2>>) parsedData.get('UnidadesPorBloco');

            // Envia cada empreendimento individualmente para o batch
            for (Empreendimento__c empreendimento : empreendimentos) {
                List<Bloco__c> Blocos = BlocosPorEmpreendimento.get(empreendimento.CodigoSistemaExterno__c);
                Map<String, List<Product2>> unidadesFiltradas = new Map<String, List<Product2>>();

                System.debug('Empreendimento ' + empreendimento.CodigoSistemaExterno__c);

                // Filtra unidades por Blocos associadas ao empreendimento atual
                if (Blocos != null) {
                    for (Bloco__c Bloco : Blocos) {
                        if (unidadesPorBloco.containsKey(Bloco.CodigoSistemaExterno__c)) {
                            unidadesFiltradas.put(Bloco.CodigoSistemaExterno__c, unidadesPorBloco.get(Bloco.CodigoSistemaExterno__c));
                            System.debug('Bloco ' + Bloco.CodigoSistemaExterno__c);
                        }
                    }
                }

                // Envia o empreendimento, suas Blocos e unidades para o batch
                EspelhoDeVendasBatch batch = new EspelhoDeVendasBatch(
                    new List<Empreendimento__c>{empreendimento},
                    new Map<String, List<Bloco__c>>{empreendimento.CodigoSistemaExterno__c => Blocos},
                    unidadesFiltradas
                );

                Database.executeBatch(batch, 1); // Processa cada empreendimento separadamente
            }
        } catch (Exception e) {
            // Registra o log em caso de erro
            log.APIName__c = 'ListaEspelhoDeVendas';
            log.EndpointURL__c = endpoint;
            log.RequestBody__c = requestBody.length() > 131072 ? requestBody.substring(0, 131072) : requestBody;
            log.Status__c = 'Erro';
            log.ExceptionMessage__c = e.getMessage();
            log.StackTrace__c = e.getStackTraceString();
            log.LogTimestamp__c = System.now();
            insert log;

            System.debug('Erro na integração: ' + e.getMessage());
            throw e; // Relança a exceção
        }
    }
}