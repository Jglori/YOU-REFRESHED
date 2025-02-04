public class CamposLeadMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Cria uma resposta simulada com dados JSON
        String jsonResponse = '{"camposOpcionais": {"Pessoa Jurídica": ["informacoesAdicionaisLead", "idEmpreendimentoInteresse", "SubProduto", "campaignName", "dataIteracaoMtn", "celularAdicional", "emailAdicional", "celularAdicional1", "celularAdicional2", "celularComercialAdicional"], "Pessoa Física": ["informacoesAdicionaisLead", "idEmpreendimentoInteresse", "SubProduto", "telefone", "campaignName", "dataIteracaoMtn", "celularAdicional", "emailAdicional", "celularAdicional1", "celularAdicional2", "celularComercialAdicional"]}, "camposObrigatorios": {"Pessoa Jurídica": ["razaoSocial", "nomeRepresentante", "email", "origem", "canal", "telefone", "celularRepresentante"], "Pessoa Física": ["nome", "email", "origem", "canal", "celular"]}}';
        
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(jsonResponse);
        res.setStatusCode(200);
        
        return res;
    }
}