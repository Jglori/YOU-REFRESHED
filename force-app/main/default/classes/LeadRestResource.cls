@RestResource(urlMapping='/Lead/*')
global with sharing class LeadRestResource {

    public class LeadDto {
        public String LastName;
        public String Company;
        public String Email;
        public String MobilePhone;
        public String LeadSource;
        public String Status;


        public LeadDto(Lead lead) {
            this.LastName = lead.LastName;
            this.Company = lead.Company;
            this.Email = lead.Email;
            this.MobilePhone = lead.MobilePhone;
            this.LeadSource = lead.LeadSource;
            this.Status = lead.Status;
        }
    }

    public class CampaignDto {
        public String Name;
        public String Type;
        public String Status;
        public Boolean IsActive;

        public CampaignDto(Campaign campaign) {
            this.Name = campaign.Name;
            this.Type = campaign.Type;
            this.Status = campaign.Status;
            this.IsActive = campaign.IsActive;
        }
    }

    public class LeadCampaignDto {
        public LeadDto lead;
        public CampaignDto campaign;

        public LeadCampaignDto(LeadDto lead, CampaignDto campaign) {
            this.lead = lead;
            this.campaign = campaign;
        }
    }

    @HttpPost
    global static void doPost() {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf('Ocorreu um erro inesperado.');
        List<LeadCampaignDto> createdLeads = new List<LeadCampaignDto>();
        List<String> errors = new List<String>();
        List<String> successMessages = new List<String>();

        try {
            RestRequest req = RestContext.request;
            List<Object> leadsParamsObject = (List<Object>) JSON.deserializeUntyped(req.requestBody.toString());
            List<Map<String, Object>> leadsParams = new List<Map<String, Object>>();
            for (Object leadParam : leadsParamsObject) {
                leadsParams.add((Map<String, Object>) leadParam);
            }
            Set<String> processedLeads = new Set<String>();


             Map<String, Id> recordTypeMap = new Map<String, Id>();
             for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Lead']) {
                 recordTypeMap.put(rt.Name, rt.Id);
             }


            for (Map<String, Object> params : leadsParams) {
                String leadKey = String.valueOf(params);
                if (processedLeads.contains(leadKey)) {
                    RestContext.response.statusCode = 400;
                    RestContext.response.responseBody = Blob.valueOf('Falha: Um Lead idêntico já foi processado.');
                    continue;
                }
                processedLeads.add(leadKey);

                String recordTypeName = (String) params.get('RecordTypeName');
                if (String.isBlank(recordTypeName)) {
                    errors.add('Falha: O campo RecordTypeName é obrigatório.');
                    continue;
                }

                Map<String, String> requiredFields;
                if (recordTypeName.contains('Pessoa Física')) {
                    requiredFields = new Map<String, String>{
                        'LastName' => 'Sobrenome',
                        'Company' => 'Empresa',
                        'LeadSource' => 'Fonte do Lead',
                        'CanalAtendimento__c' => 'Canal de Atendimento',
                        'EmpreendimentoInteresse__c' => 'Empreendimento de Interesse',
                        'MobilePhone' => 'Telefone Móvel',
                        'Status' => 'Status'
                    };
                } else if (recordTypeName.contains('Pessoa Jurídica')) {
                    requiredFields = new Map<String, String>{
                        'LastName' => 'Sobrenome',
                        'Company' => 'Empresa',
                        'LeadSource' => 'Fonte do Lead',
                        'CanalAtendimento__c' => 'Canal de Atendimento',
                        'EmpreendimentoInteresse__c' => 'Empreendimento de Interesse',
                        'Phone' => 'Telefone',
                        'Status' => 'Status'
                    };
                } 
                else{
                    errors.add('Falha: Tipo de Registro desconhecido.');
                    continue;
                }

                Boolean skipProcessing = false;
                String campaignName;
                Campaign campaign;
                for (String fieldName : requiredFields.keySet()) {
                    if (!params.containsKey(fieldName) || String.isBlank((String)params.get(fieldName))) {
                        errors.add('Lead com sobrenome ' + params.get('LastName') + ': O campo ' + requiredFields.get(fieldName) + ' é obrigatório.');
                        skipProcessing = true;
                        break;
                    }
                }
                if (skipProcessing) continue;

                List<Lead> potentialDuplicateLeads = [
                    SELECT Id, LastName, MobilePhone, Email, EmpreendimentoInteresse__c, LeadSource, ltima_Reitera_o__c, PrimeiraInteracao__c, QuantidadeDeReiteracoes__c, PrimeiroEmpreendimento__c, MidiaOriginal__c, OwnerId
                    FROM Lead 
                    WHERE LastName = :params.get('LastName').toString() 
                    AND (
                        MobilePhone = :String.valueOf(params.get('MobilePhone')) OR
                        Email = :params.get('Email').toString() OR
                        EmpreendimentoInteresse__c = :params.get('EmpreendimentoInteresse__c').toString()
                    )
                    LIMIT 1
                ];

                if (!potentialDuplicateLeads.isEmpty()) {
                    Lead existingLead = potentialDuplicateLeads[0];
                    LeadHelper.handleLeadReiteration(existingLead, params);
                    errors.add('Lead com sobrenome ' + params.get('LastName') + ': Um Lead existente foi encontrado. ID do Lead: ' + existingLead.Id);
                    RestContext.response.statusCode = 200;
                    RestContext.response.responseBody = Blob.valueOf('Lead com sobrenome ' + params.get('LastName') + ': Um Lead existente foi encontrado. ID do Lead: ' + existingLead.Id);
                    return;
                }
                
                

                Lead newLead = new Lead();
                for (String fieldName : params.keySet()) {
                    if (fieldName != 'campaignName') {
                        newLead.put(fieldName, params.get(fieldName));
                    }
                }
                newLead.QuantidadeDeReiteracoes__c = 0;

                insert newLead;

                if (params.containsKey('campaignName')) {
                    campaignName = (String)params.get('campaignName');
                    List<Campaign> existingCampaigns = [SELECT Id, Name, Type, Status, IsActive FROM Campaign WHERE Name = :campaignName LIMIT 1];
                    if (existingCampaigns.isEmpty()) {
                        RestContext.response.statusCode = 400;
                        RestContext.response.responseBody = Blob.valueOf('Falha: Não existe uma campanha com o nome ' + campaignName);
                        return;
                    } else {
                        campaign = existingCampaigns[0];
                    }
                } else {
                    campaignName = (String)params.get('LeadSource');
                    if (String.isBlank(campaignName)) {
                        campaignName = 'Campanha Padrão';
                    }
                    List<Campaign> existingCampaigns = [SELECT Id, Name, Type, Status, IsActive FROM Campaign WHERE Name = :campaignName LIMIT 1];
                    if (existingCampaigns.isEmpty()) {
                        campaign = new Campaign(Name = campaignName);
                        insert campaign;
                    } else {
                        campaign = existingCampaigns[0];
                    }
                }

                CampaignDto campaignDto = new CampaignDto(campaign);
                LeadDto leadDto = new LeadDto(newLead);
                LeadCampaignDto leadCampaignDto = new LeadCampaignDto(leadDto, campaignDto);
                createdLeads.add(leadCampaignDto);

                CampaignMember campaignMember = new CampaignMember(
                    CampaignId = campaign.Id,
                    LeadId = newLead.Id,
                    Status = 'Enviado'
                );

                insert campaignMember;



                CampaignHistory__c ch = new CampaignHistory__c(
                    LeadId__c = newLead.Id,
                    CampaignId__c = campaign.Id,
                    Change_Date__c = System.now()
                );
                insert ch;
            }

            if (errors.isEmpty()) {
                RestContext.response.statusCode = 201;
                RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(createdLeads));
            } else {
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf(String.join(errors, '\n'));
            }

        } catch (Exception e) {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('Falha: ' + e.getMessage());
        }
    }
}