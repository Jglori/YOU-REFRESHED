@isTest
private class LeadEmpreendimentosRestResourceTest {
    @isTest
    static void testBuscarEmpreendimentos() {
        // Cria um empreendimento de teste
        Empreendimento__c empreendimento = new Empreendimento__c(Name = 'Empreendimento Teste');
        insert empreendimento;

        // Cria leads de teste associando o empreendimento
        Lead lead1 = new Lead(
            LastName = 'Teste1',
            Company = 'Teste Company1',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        Lead lead2 = new Lead(
            LastName = 'Teste2',
            Company = 'Teste Company2',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert new List<Lead> { lead1, lead2 };

        // Define o contexto do REST request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/Lead/buscarEmpreendimentos';
        req.httpMethod = 'GET';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Chama o método REST
        LeadEmpreendimentosRestResource.buscarEmpreendimentos();

        // Verifica o código de status da resposta
        System.assertEquals(200, res.statusCode);

        // Verifica o corpo da resposta
        String responseBody = res.responseBody.toString();
        System.debug(responseBody);

        // Desserializa o JSON da resposta
        LeadEmpreendimentosRestResource.EmpreendimentosDto result =
            (LeadEmpreendimentosRestResource.EmpreendimentosDto) JSON.deserialize(responseBody, LeadEmpreendimentosRestResource.EmpreendimentosDto.class);

        // Verifica se o resultado contém o empreendimento esperado
        System.assertEquals(1, result.empreendimentos.size());
        System.assertEquals(empreendimento.Id, result.empreendimentos[0].id);
        System.assertEquals(empreendimento.Name, result.empreendimentos[0].nome);
    }
}
