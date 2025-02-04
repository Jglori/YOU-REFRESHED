@RestResource(urlMapping='/Lead/*')
global with sharing class LeadRestResource {

    public class CamposLeadDTO {
        public Map<String, List<String>> camposObrigatorios { get; set; }
        public Map<String, List<String>> camposOpcionais { get; set; }

        public CamposLeadDTO() {
            camposObrigatorios = new Map<String, List<String>>();
            camposOpcionais = new Map<String, List<String>>();
        }
    }
   
   @HttpPost
    global static void doPost() {
        RestContext.response.statusCode = 400; 
        RestContext.response.responseBody = Blob.valueOf('Ocorreu um erro inesperado.');
        
        List<String> errors = new List<String>();
        List<Lead_MTN__c> leadsToInsert = new List<Lead_MTN__c>();
        
        Set<String> existingEmails = new Set<String>();
        Set<String> existingPhones = new Set<String>();
        Set<String> existingMobiles = new Set<String>();
        
        try {
            RestRequest req = RestContext.request;
            List<Object> leadsParamsObject = (List<Object>) JSON.deserializeUntyped(req.requestBody.toString());
            List<Map<String, Object>> leadsParams = new List<Map<String, Object>>();
    
            for (Object leadParam : leadsParamsObject) {
                leadsParams.add((Map<String, Object>) leadParam);
            }
    
            Map<String, Id> recordTypeMap = new Map<String, Id>();
            for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Lead_MTN__c']) {
                recordTypeMap.put(rt.Name, rt.Id);
            }
    
            for (Map<String, Object> params : leadsParams) {
                String tipoPessoa = (String) params.get('tipoPessoa');
                String recordTypeToUse = (tipoPessoa == 'Física') ? 'Pessoa Física' : 'Pessoa Jurídica';
                System.debug('Tipo ' + recordTypeToUse);
    
                if (!recordTypeMap.containsKey(recordTypeToUse)) {
                    errors.add('Falha: O RecordType ' + recordTypeToUse + ' não foi encontrado.');
                    continue;
                }
    
                Lead_MTN__c newLead = new Lead_MTN__c();
                newLead.RecordTypeId = recordTypeMap.get(recordTypeToUse);
                newLead.Tipo_Pessoa__c = recordTypeToUse;
                newLead.Email__c = (String) params.get('email');
                newLead.Origem_Lead__c = (String) params.get('origem');
                newLead.Canal_de_Atendimento__c = (String) params.get('canal');
                newLead.Status__c = 'Novo';
                newLead.Informacoes_Adicionais__c = (String) params.get('informacoesAdicionaisLead');
                newLead.Empreendimento__c = (Id) params.get('idEmpreendimentoInteresse');
    
                if (params.containsKey('SubProduto')) {
                    String subProdutoValue = (String) params.get('SubProduto');
                    if (String.isNotBlank(subProdutoValue)) {
                        List<Schema.PicklistEntry> picklistValues = Lead_MTN__c.SubProduto__c.getDescribe().getPicklistValues();
                        Boolean isValid = false;
    
                        for (Schema.PicklistEntry picklistValue : picklistValues) {
                            if (picklistValue.getLabel().equals(subProdutoValue)) {
                                newLead.SubProduto__c = picklistValue.getValue();
                                isValid = true;
                                break;
                            }
                        }
    
                        if (!isValid) {
                            errors.add('SubProduto inválido: ' + subProdutoValue);
                            continue;
                        }
                    }
                }
    
                if (tipoPessoa == 'Física') {
                    String nomeCompleto = (String) params.get('nome');
                    String[] nomeParts = nomeCompleto.split(' ');
    
                    if (nomeParts.size() > 1) {
                        newLead.First_Name__c = nomeParts[0];
                        String sobrenome = '';
                        for (Integer i = 1; i < nomeParts.size(); i++) {
                            sobrenome += nomeParts[i] + ' ';
                        }
                        newLead.Last_Name__c = sobrenome.trim();
                    } else {
                        newLead.First_Name__c = nomeParts[0];
                        newLead.Last_Name__c = '';
                    }
    
                    newLead.MobilePhone__c = (String) params.get('celular');
                } else {
                    newLead.Razao_Social__c = (String) params.get('razaoSocial');
                    newLead.Telefone__c = (String) params.get('telefone');
                    newLead.Last_Name__c = (String) params.get('nomeRepresentante');
                    newLead.MobilePhone__c = (String) params.get('celularRepresentante');
                }
    
               RoletaLeads__c roletaAtiva = encontrarRoletaAtiva(); System.debug('Roleta encontrada ' + roletaAtiva); if (roletaAtiva == null) { throw new CustomException('Nenhuma roleta encontrada para os critérios especificados.'); } newLead.Roleta_de_leads__c = roletaAtiva.Id; String dataIteracaoMtn = (String) params.get('dataIteracaoMtn'); if (dataIteracaoMtn != null) { try { String formattedDate = dataIteracaoMtn.replace('Z', '').replace('T', ' '); newLead.Data_Iteracao_MTN__c = Datetime.valueOf(formattedDate); } catch (Exception e) { errors.add('Formato de data inválido: ' + dataIteracaoMtn); continue; } } Boolean isDuplicate = false; if (String.isNotBlank(newLead.Email__c) && existingEmails.contains(newLead.Email__c)) { isDuplicate = true; } if (String.isNotBlank(newLead.MobilePhone__c) && existingMobiles.contains(newLead.MobilePhone__c)) { isDuplicate = true; } if (String.isNotBlank(newLead.Telefone__c) && existingPhones.contains(newLead.Telefone__c)) { isDuplicate = true; } if (isDuplicate) { errors.add('Lead duplicado encontrado: ' + newLead.Email__c); continue; } if (String.isNotBlank(newLead.Email__c)) { existingEmails.add(newLead.Email__c); } if (String.isNotBlank(newLead.MobilePhone__c)) { existingMobiles.add(newLead.MobilePhone__c); } if (String.isNotBlank(newLead.Telefone__c)) { existingPhones.add(newLead.Telefone__c); } leadsToInsert.add(newLead);

            }
    
            if (!leadsToInsert.isEmpty()) {
                insert leadsToInsert;
                RestContext.response.statusCode = 200;
                RestContext.response.responseBody = Blob.valueOf('Leads inseridos com sucesso.');
            } else {
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf('Nenhum lead foi inserido. Verifique os erros: ' + JSON.serialize(errors));
            }
        } catch (Exception ex) {
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf('Erro: ' + ex.getMessage());
        }
    }
    
    @TestVisible
 private static void registrarErroRoleta(List<Lead_MTN__c> leads) {
        List<LogNTM__c> logs = new List<LogNTM__c>();
        for (Lead_MTN__c lead : leads) {
            logs.add(new LogNTM__c(
                Name = 'Erro ao processar leads',
                Messagem__c = 'Nenhuma roleta encontrada. Email: ' + lead.Email__c + ', Celular: ' + lead.MobilePhone__c
            ));
        }
        if (!logs.isEmpty()) {
            insert logs;
        }
    }
    
    private static RoletaLeads__c encontrarRoletaAtiva() {
        List<RoletaLeads__c> roletas = [SELECT Id, HoraInicio__c, Ativa__c FROM RoletaLeads__c WHERE CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone'];
         System.debug('Roleta ' + roletas);
        for (RoletaLeads__c roleta : roletas) {
            if (roleta.Ativa__c) {
                return roleta;
            }
        }
        return roletas.isEmpty() ? null : roletas[0];
    }
    
  
    

    @HttpGet
    global static void getCamposLead() {
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');

        try {
            CamposLeadDTO camposDto = new CamposLeadDTO();

            // Campos obrigatórios e opcionais para Pessoa Física
            camposDto.camposObrigatorios.put('Pessoa Física', new List<String>{
                'nome', 
                'email', 
                'origem', 
                'canal', 
                'celular'
            });
            camposDto.camposOpcionais.put('Pessoa Física', new List<String>{
                'informacoesAdicionaisLead', 
                'idEmpreendimentoInteresse', 
                'SubProduto', 
                'telefone', 
                'campaignName', 
                'dataIteracaoMtn',
                'celularAdicional',
                'emailAdicional', 
                'celularAdicional1', 
                'celularAdicional2', 
                'celularComercialAdicional' 
            });

            // Campos obrigatórios e opcionais para Pessoa Jurídica
            camposDto.camposObrigatorios.put('Pessoa Jurídica', new List<String>{
                'razaoSocial', 
                'nomeRepresentante', 
                'email', 
                'origem', 
                'canal', 
                'telefone', 
                'celularRepresentante'
            });
            camposDto.camposOpcionais.put('Pessoa Jurídica', new List<String>{
                'informacoesAdicionaisLead', 
                'idEmpreendimentoInteresse', 
                'SubProduto', 
                'campaignName', 
                'dataIteracaoMtn',
                'celularAdicional',
                'emailAdicional', 
                'celularAdicional1', 
                'celularAdicional2', 
                'celularComercialAdicional' 
            });

            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serialize(camposDto));

        } catch (Exception e) {
            response.statusCode = 500;
            response.responseBody = Blob.valueOf('Erro ao processar a solicitação: ' + e.getMessage());
        }
    }
}