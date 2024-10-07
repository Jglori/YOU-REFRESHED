@RestResource(urlMapping='/Lead/*')
global with sharing class LeadRestResource {

    public class EmpreendimentosDto {
        List<Empreendimentos> empreendimentos;

        public EmpreendimentosDto() {
            empreendimentos = new List<Empreendimentos>();
        }
    }

    public class Empreendimentos {
        public Id id;
        public String nome;

        public Empreendimentos() {
        }
    }

    public class PicklistValuesDto {
        public List<String> subprodutos;

        public PicklistValuesDto() {
            subprodutos = new List<String>();
        }
    }
    
    @HttpPost
    global static void doPost() {
        RestContext.response.statusCode = 400; 
        RestContext.response.responseBody = Blob.valueOf('Ocorreu um erro inesperado.');
        List<String> errors = new List<String>();
        List<String> duplicateLeadInfo = new List<String>();
    
        try {
            RestRequest req = RestContext.request;
            List<Object> leadsParamsObject = (List<Object>) JSON.deserializeUntyped(req.requestBody.toString());
            List<Map<String, Object>> leadsParams = new List<Map<String, Object>>();

            for (Object leadParam : leadsParamsObject) {
                leadsParams.add((Map<String, Object>) leadParam);
            }

            Map<String, Id> recordTypeMap = new Map<String, Id>();
            for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Lead']) {
                recordTypeMap.put(rt.Name, rt.Id);
            }

            for (Map<String, Object> params : leadsParams) {
                String tipoPessoa = (String) params.get('tipoPessoa');
                String recordTypeToUse = (tipoPessoa == 'Física') ? 'Pessoa Física' : 'Pessoa Jurídica';

                if (!recordTypeMap.containsKey(recordTypeToUse)) {
                    errors.add('Falha: O RecordType ' + recordTypeToUse + ' não foi encontrado.');
                    continue;
                }

                if (tipoPessoa == 'Física') {
                    if (String.isBlank((String) params.get('nome')) || 
                        String.isBlank((String) params.get('email')) || 
                        String.isBlank((String) params.get('origem')) || 
                        String.isBlank((String) params.get('canal')) || 
                        String.isBlank((String) params.get('celular'))) {
                        errors.add('Lead (Física): Campos obrigatórios estão faltando.');
                        continue;
                    }
                } else if (tipoPessoa == 'Jurídica') {
                    if (String.isBlank((String) params.get('razaoSocial')) || 
                        String.isBlank((String) params.get('nomeRepresentante')) || 
                        String.isBlank((String) params.get('email')) || 
                        String.isBlank((String) params.get('origem')) || 
                        String.isBlank((String) params.get('canal'))) {
                        errors.add('Lead (Jurídica): Campos obrigatórios estão faltando.');
                        continue;
                    }
                }

                String nomeLead = (String) params.get('nome');
                String emailLead = (String) params.get('email');
                String celularLead = (String) params.get('celular');
                String telefoneLead = (String) params.get('phone');
                Id empreendimentoInteresseId = (Id) params.get('idEmpreendimentoInteresse');
                String subProduto = (String) params.get('SubProduto'); 

                List<Lead> potentialDuplicateLeads = [
                    SELECT Id, LastName, MobilePhone, Email, QuantidadeDeReiteracoes__c, Phone, EmpreendimentoInteresse__c, CanalAtendimento__c,
                           EmpreendimentoInteresse__r.Name, LeadSource, Status, ltima_Reitera_o__c
                    FROM Lead
                    WHERE Email = :emailLead
                    AND (MobilePhone = :celularLead OR Phone = :telefoneLead)
                    LIMIT 1
                ];

                if (!potentialDuplicateLeads.isEmpty()) {
                    Lead existingLead = potentialDuplicateLeads[0];
                    duplicateLeadInfo.add('Lead duplicado encontrado: ID ' + existingLead.Id + ', Nome: ' + existingLead.LastName + ', Email: ' + existingLead.Email);
                    LeadHelper.handleLeadReiteration(existingLead, params);
                    continue;
                }

                Lead newLead = new Lead();
                newLead.RecordTypeId = recordTypeMap.get(recordTypeToUse);
                newLead.Email = emailLead;
                newLead.LeadSource = (String) params.get('origem');
                newLead.CanalAtendimento__c = (String) params.get('canal');
                newLead.Status = 'Novo';

                if (empreendimentoInteresseId != null) {
                    newLead.EmpreendimentoInteresse__c = empreendimentoInteresseId;
                }

                if (tipoPessoa == 'Física') {
                    String[] nomes = nomeLead.split(' ');
                    newLead.FirstName = nomes[0];
                    newLead.LastName = nomes.size() > 1 ? nomes[1] : '';
                    newLead.MobilePhone = celularLead; 
                } else {
                    newLead.Company = (String) params.get('razaoSocial');
                    newLead.Phone = telefoneLead; 
                    newLead.LastName = (String) params.get('nomeRepresentante');
                    newLead.MobilePhone = (String) params.get('celularRepresentante'); 
                }

                Campaign campaign;
                String campaignName;

                if (params.containsKey('campaignName')) {
                    campaignName = (String) params.get('campaignName');
                    List<Campaign> existingCampaigns = [SELECT Id, Name FROM Campaign WHERE Name = :campaignName LIMIT 1];
                    if (existingCampaigns.isEmpty()) {
                        RestContext.response.statusCode = 400;
                        RestContext.response.responseBody = Blob.valueOf('Falha: Não existe uma campanha com o nome ' + campaignName);
                        return;
                    } else {
                        campaign = existingCampaigns[0];
                    }
                } else {
                    campaignName = (String) params.get('origem');
                    if (String.isBlank(campaignName)) {
                        campaignName = 'Campanha Padrão';
                    }
                    List<Campaign> existingCampaigns = [SELECT Id, Name FROM Campaign WHERE Name = :campaignName LIMIT 1];
                    if (existingCampaigns.isEmpty()) {
                        campaign = new Campaign(Name = campaignName);
                        insert campaign; 
                    } else {
                        campaign = existingCampaigns[0];
                    }
                }

                newLead.SubProduto__c = subProduto;

                try {
                    insert newLead; 
                } catch (DmlException dmlEx) {
                    errors.add('Falha ao criar Lead: ' + dmlEx.getMessage());
                    continue; 
                }

                CampaignMember campaignMember = new CampaignMember(
                    CampaignId = campaign.Id,
                    LeadId = newLead.Id, 
                    Status = 'Enviado'
                );

                try {
                    insert campaignMember;
                } catch (DmlException dmlEx) {
                    errors.add('Falha ao adicionar Lead à Campanha: ' + dmlEx.getMessage());
                }

                CampaignHistory__c ch = new CampaignHistory__c(
                    LeadId__c = newLead.Id,
                    CampaignId__c = campaign.Id,
                    Change_Date__c = System.now()
                );

                try {
                    insert ch; 
                } catch (DmlException dmlEx) {
                    errors.add('Falha ao criar histórico da campanha: ' + dmlEx.getMessage());
                }
                
                if (!String.isBlank(subProduto)) {
                    List<Campaign> subProductCampaigns = [
                        SELECT Id, Name FROM Campaign WHERE Name = :subProduto LIMIT 1
                    ];
                    if (subProductCampaigns.isEmpty()) {
                        Campaign subProductCampaign = new Campaign(Name = subProduto);
                        insert subProductCampaign; 

                        CampaignMember subProductCampaignMember = new CampaignMember(
                            CampaignId = subProductCampaign.Id,
                            LeadId = newLead.Id,
                            Status = 'Enviado'
                        );
                        insert subProductCampaignMember;
                    } else {
                        CampaignMember subProductCampaignMember = new CampaignMember(
                            CampaignId = subProductCampaigns[0].Id,
                            LeadId = newLead.Id,
                            Status = 'Enviado'
                        );
                        insert subProductCampaignMember;
                    }
                }
            }

            if (errors.isEmpty() && duplicateLeadInfo.isEmpty()) {
                RestContext.response.statusCode = 201; 
                RestContext.response.responseBody = Blob.valueOf('Leads criados com sucesso.');
            } else {
                RestContext.response.statusCode = 400;
                String responseMessage = 'Alguns Leads não puderam ser criados:\n' + String.join(errors, '\n');
                if (!duplicateLeadInfo.isEmpty()) {
                    responseMessage += '\n' + String.join(duplicateLeadInfo, '\n');
                }
                RestContext.response.responseBody = Blob.valueOf(responseMessage);
            }

        } catch (Exception e) {
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf('Erro inesperado: ' + e.getMessage());
        }
    }
}