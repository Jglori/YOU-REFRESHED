@RestResource(urlMapping='/Lead/ListaSubProdutos')
global with sharing class LeadSubProdutosRestResource {
    public class PicklistValuesDto {
        public List<String> subprodutos;

        public PicklistValuesDto() {
            subprodutos = new List<String>();
        }
    }

    @HttpGet
    global static void getPicklistValues() {
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        
        try {
            PicklistValuesDto picklistValuesDto = new PicklistValuesDto();
            Schema.DescribeFieldResult fieldResult = Lead.SubProduto__c.getDescribe();
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

            for (Schema.PicklistEntry entry : picklistEntries) {
                picklistValuesDto.subprodutos.add(entry.getLabel());
            }

            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serialize(picklistValuesDto));
        } catch (Exception e) {
            response.statusCode = 500;
            response.responseBody = Blob.valueOf('Erro ao processar a solicitação: ' + e.getMessage());
        }
    }
}