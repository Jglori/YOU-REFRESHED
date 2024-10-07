@isTest
private class LeadSubProdutosRestResourceTest {
    @isTest
    static void testGetPicklistValues() {
        // Define o contexto do REST request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/Lead/ListaSubProdutos';
        req.httpMethod = 'GET';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Chama o método REST
        LeadSubProdutosRestResource.getPicklistValues();

        // Verifica o código de status da resposta
        System.assertEquals(200, res.statusCode);

        // Verifica o corpo da resposta
        String responseBody = res.responseBody.toString();
        System.debug(responseBody);

        // Desserializa o JSON da resposta
        LeadSubProdutosRestResource.PicklistValuesDto result =
            (LeadSubProdutosRestResource.PicklistValuesDto) JSON.deserialize(responseBody, LeadSubProdutosRestResource.PicklistValuesDto.class);

        // Obtém os valores de picklist do campo SubProduto__c do objeto Lead
        List<Schema.PicklistEntry> expectedPicklistEntries = Lead.SubProduto__c.getDescribe().getPicklistValues();
        List<String> expectedValues = new List<String>();
        for (Schema.PicklistEntry entry : expectedPicklistEntries) {
            expectedValues.add(entry.getLabel());
        }

        // Verifica se os valores de picklist esperados estão na resposta
        System.assertEquals(expectedValues.size(), result.subprodutos.size());
        for (String value : expectedValues) {
            System.assert(result.subprodutos.contains(value));
        }
    }
}
