public class ListaEspelhoDeVendasParser {
    public static Map<String, Object> parse(String xml) {
        // Estruturas principais
        List<Empreendimento__c> empreendimentos = new List<Empreendimento__c>();
        Map<String, List<Bloco__c>> BlocosPorEmpreendimento = new Map<String, List<Bloco__c>>();
        Map<String, List<Product2>> unidadesPorBloco = new Map<String, List<Product2>>();

        System.debug('Iniciando o parser para o XML recebido.');

        try {
            // Carrega o XML
            Dom.Document doc = new Dom.Document();
            doc.load(xml);
            System.debug('XML carregado com sucesso.');

            // Obtém o nó raiz
            Dom.XmlNode root = doc.getRootElement();
            System.debug('Nó raiz identificado: ' + root.getName());

            // Navega para o Body
            for (Dom.XmlNode childNode : root.getChildElements()) {
                if (childNode.getName() == 'Body' && childNode.getNamespace() == 'http://schemas.xmlsoap.org/soap/envelope/') {
                    System.debug('Navegando no nó Body.');
                    for (Dom.XmlNode bodyChild : childNode.getChildElements()) {
                        if (bodyChild.getName() == 'ListaEspelhoDeVendasResponse' && bodyChild.getNamespace() == 'http://www.civilweb.com.br/') {
                            System.debug('Nó ListaEspelhoDeVendasResponse encontrado.');
                            for (Dom.XmlNode responseChild : bodyChild.getChildElements()) {
                                if (responseChild.getName() == 'ListaEspelhoDeVendasResult') {
                                    System.debug('Nó ListaEspelhoDeVendasResult encontrado.');
                                
                                    // Itera sobre os empreendimentos
                                    for (Dom.XmlNode empreendimentoNode : responseChild.getChildElements()) {
                                        if (empreendimentoNode.getName() == 'EMPREENDIMENTO') {
                                            System.debug('Processando EMPREENDIMENTO.');
                                
                                            // Cria um novo empreendimento
                                            Empreendimento__c empreendimento = new Empreendimento__c();
                                            empreendimento.CodigoSistemaExterno__c = empreendimentoNode.getChildElement('CODIGO', 'http://www.civilweb.com.br/').getText();
                                            empreendimento.Name = empreendimentoNode.getChildElement('NOME', 'http://www.civilweb.com.br/').getText();
                                            empreendimento.NomeCodigoSistemaExterno__c = empreendimentoNode.getChildElement('NOME_CODIGO', 'http://www.civilweb.com.br/').getText();
                                            empreendimentos.add(empreendimento);
                                            System.debug('Empreendimento adicionado: ' + empreendimento);
                                
                                            // Lista de Blocos para este empreendimento
                                            List<Bloco__c> Blocos = new List<Bloco__c>();
                                
                                            // Itera sobre os blocos (Blocos) no empreendimento
                                            for (Dom.XmlNode blocoNode : empreendimentoNode.getChildElements()) {
                                                if (blocoNode.getName() == 'BLOCOS') {
                                                    System.debug('Processando BLOCO.');
                                
                                                    // Cria uma nova Bloco
                                                    Bloco__c Bloco = new Bloco__c();
                                                    Bloco.CodigoSistemaExterno__c = blocoNode.getChildElement('CODIGO', 'http://www.civilweb.com.br/').getText();
                                                    Bloco.Name = blocoNode.getChildElement('NOME', 'http://www.civilweb.com.br/').getText();
                                                    Bloco.NomeCodigoSistemaExterno__c = blocoNode.getChildElement('NOME_CODIGO', 'http://www.civilweb.com.br/').getText();
                                                    Blocos.add(Bloco);
                                                    System.debug('Bloco adicionada: ' + Bloco);
                                
                                                    // Lista de unidades para esta Bloco
                                                    List<Product2> unidades = new List<Product2>();
                                
                                                    // Itera sobre as unidades no bloco
                                                    for (Dom.XmlNode unidadeNode : blocoNode.getChildElements()) {
                                                        if (unidadeNode.getName() == 'UNIDADES') {
                                                            System.debug('Processando UNIDADE.');
                                
                                                            // Cria um novo produto (unidade)
                                                            Product2 produto = new Product2();
                                                            produto.CodigoSistemaExterno__c = unidadeNode.getChildElement('CODIGO', 'http://www.civilweb.com.br/').getText();
                                                            produto.Name = unidadeNode.getChildElement('NOME_CODIGO', 'http://www.civilweb.com.br/').getText();
                                                            produto.ProductCode = unidadeNode.getChildElement('NOME_CODIGO', 'http://www.civilweb.com.br/').getText();
                                                            produto.StatusSistemaExterno__c = unidadeNode.getChildElement('STATUS', 'http://www.civilweb.com.br/').getText();
                                                            produto.Tipologia__c = unidadeNode.getChildElement('TIPOLOGIA', 'http://www.civilweb.com.br/').getText();
                                                            produto.AreaPrivativaSistemaExterno__c = unidadeNode.getChildElement('AREA_PRIVATIVA', 'http://www.civilweb.com.br/').getText();
                                                            unidades.add(produto);
                                                            System.debug('Unidade adicionada: ' + produto);
                                                        }
                                                    }
                                
                                                    // Adiciona as unidades ao mapa de unidades por Bloco
                                                    unidadesPorBloco.put(Bloco.CodigoSistemaExterno__c, unidades);
                                                }
                                            }
                                
                                            // Adiciona as Blocos ao mapa de Blocos por empreendimento
                                            BlocosPorEmpreendimento.put(empreendimento.CodigoSistemaExterno__c, Blocos);
                                        }
                                    }
                                }

                            }
                        }
                    }
                }
            }

            System.debug('Processamento concluído. Estruturas criadas.');
            System.debug('Empreendimentos: ' + empreendimentos);
            System.debug('Blocos por Empreendimento: ' + BlocosPorEmpreendimento);
            System.debug('Unidades por Bloco: ' + unidadesPorBloco);

        } catch (Exception e) {
            System.debug('Erro ao processar o XML: ' + e.getMessage());
            throw e;
        }

        // Retorna as estruturas no resultado
        Map<String, Object> result = new Map<String, Object>();
        result.put('Empreendimentos', empreendimentos);
        result.put('BlocosPorEmpreendimento', BlocosPorEmpreendimento);
        result.put('UnidadesPorBloco', unidadesPorBloco);
        return result;
    }
}