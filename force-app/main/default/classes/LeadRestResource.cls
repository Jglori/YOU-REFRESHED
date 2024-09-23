@RestResource(urlMapping='/lead/create')
global with sharing class LeadRestResource {
    
    public class LeadDto {
        public String tipoPessoa;
        public String nome;
        public String sobrenome;
        public String email;
        public String telefone;
        public String celular;
        public String razaoSocial;
        public String origemLead;
        public String canalAtendimentoLead;
        public String nomeRepresentante;
        public String celularRepresentante;
        
        public LeadDto() {}
    
        public LeadDto(Lead lead) {
            this.nome = lead.FirstName;
            this.sobrenome = lead.LastName;
            this.email = lead.Email;
            this.telefone = lead.Phone;
            this.celular = lead.MobilePhone;
            this.origemLead = lead.LeadSource;
            this.canalAtendimentoLead = lead.CanalAtendimento__c;
            this.nomeRepresentante = lead.LastName;
            this.celularRepresentante = lead.MobilePhone;
            this.razaoSocial = lead.RazaoSocial__c;
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
            List<Object> requestBodyList = (List<Object>) JSON.deserializeUntyped(req.requestBody.toString());
            
            Set<String> processedLeads = new Set<String>();
            Map<String, Id> recordTypeMap = new Map<String, Id>();
            
            // Mapeando tipos de registro
            for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Lead']) {
                recordTypeMap.put(rt.Name, rt.Id);
            }
            
            // Processando cada lead no request
            for (Object leadObj : requestBodyList) {
                Map<String, Object> leadMap = (Map<String, Object>) leadObj;
                String tipoPessoa = (String) leadMap.get('tipoPessoa');
                
                System.debug('tipoPessoa: ' + tipoPessoa);
                
                Map<String, String> requiredFields = new Map<String, String>();
                
                // Definindo campos obrigatórios
                if (tipoPessoa != null && tipoPessoa == 'Pessoa Física') {
                    requiredFields.put('LastName', 'Sobrenome');
                    requiredFields.put('LeadSource', 'Origem do Lead');
                    requiredFields.put('CanalAtendimento__c', 'Canal de Atendimento');
                    requiredFields.put('MobilePhone', 'Telefone Móvel');
                    requiredFields.put('Status', 'Status');
                } else if (tipoPessoa != null && tipoPessoa == 'Pessoa Jurídica') {
                    requiredFields.put('LastName', 'Sobrenome');
                    requiredFields.put('RazaoSocial__c', 'Empresa');
                    requiredFields.put('LeadSource', 'Origem do Lead');
                    requiredFields.put('CanalAtendimento__c', 'Canal de Atendimento');
                    requiredFields.put('Phone', 'Telefone');
                    requiredFields.put('Status', 'Status');
                } else {
                    errors.add('Falha: Tipo de Pessoa desconhecido ou ausente.');
                    continue;
                }
              
                // Validação de campos obrigatórios
                Boolean hasErrors = false;
                for (String fieldName : requiredFields.keySet()) {
                    if (!leadMap.containsKey(fieldName) || String.isBlank((String) leadMap.get(fieldName))) {
                        errors.add('O campo ' + requiredFields.get(fieldName) + ' é obrigatório.');
                        hasErrors = true;
                    }
                }
                if (hasErrors) {
                    continue;
                }

                // Prevenindo duplicação de Leads
                String leadKey = String.valueOf(leadMap);
                if (processedLeads.contains(leadKey)) {
                    errors.add('Um Lead idêntico já foi processado.');
                    continue;
                } else {
                    processedLeads.add(leadKey);
                    
                    // Verificando duplicidade de Leads existentes
                    List<Lead> potentialDuplicateLeads = [
                        SELECT Id, LastName, MobilePhone, Phone, Email, EmpreendimentoInteresse__c, LeadSource, Status 
                        FROM Lead
                        WHERE LastName = :leadMap.get('LastName').toString()
                        AND (
                            MobilePhone = :String.valueOf(leadMap.get('MobilePhone')) OR
                            Phone = :String.valueOf(leadMap.get('Phone')) OR
                            Email = :leadMap.get('email').toString()
                        )
                        LIMIT 1
                    ];
                    
                    if (!potentialDuplicateLeads.isEmpty()) {
                        Lead existingLead = potentialDuplicateLeads[0];
                        LeadHelper.createTaskForReiteration(existingLead);
                        errors.add('Lead com sobrenome ' + leadMap.get('LastName') + ': Um Lead existente foi encontrado. ID do Lead: ' + existingLead.Id);
                        continue;
                    }

                    Lead newLead = new Lead();
                    for (String fieldName : leadMap.keySet()) {
                        if (fieldName != 'campaignName' && fieldName != 'tipoPessoa') {
                            newLead.put(fieldName, leadMap.get(fieldName));
                        }
                    }
                    
                    System.debug('Campos do Lead: ' + newLead);
                    System.debug('recordTypeMap.containsKey(tipoPessoa): ' + recordTypeMap.containsKey(tipoPessoa));

                    if (recordTypeMap.containsKey(tipoPessoa)) {
                        newLead.RecordTypeId = recordTypeMap.get(tipoPessoa);
                    } else {
                        errors.add('Falha: Tipo de Registro desconhecido.');
                        continue;
                    }

                    // Garantindo que o Status seja preenchido
                    if (newLead.Status == null) {
                        newLead.Status = 'Novo';
                    }
                    
                    newLead.QuantidadeDeReiteracoes__c = 0;
                    
                    try {
                        insert newLead;
                        
                        // Gerenciando Campaign e CampaignMember
                        Campaign campaign;
                        String campaignName = (String)leadMap.get('campaignName');
                        if (String.isBlank(campaignName)) {
                            campaignName = (String)leadMap.get('LeadSource');
                            if (String.isBlank(campaignName)) {
                                campaignName = 'Campanha Padrão';
                            }
                        }
                        List<Campaign> existingCampaigns = [SELECT Id, Name, Type, Status, IsActive FROM Campaign WHERE Name = :campaignName LIMIT 1];
                        if (existingCampaigns.isEmpty()) {
                            campaign = new Campaign(Name = campaignName);
                            insert campaign;
                        } else {
                            campaign = existingCampaigns[0];
                        }
                        
                        // Criando CampaignMember e histórico
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
                            CampaignId__c = campaign.Id
                        );
                        insert ch;
                        
                        successMessages.add('Lead com sobrenome ' + newLead.LastName + ' e ID ' + newLead.Id + ' foi criado com sucesso e adicionado à campanha ' + campaign.Name + '.');
                    } catch (DmlException dmle) {
                        errors.add('Erro ao criar Lead: ' + dmle.getMessage());
                    }
                }
            }
            
            // Concluindo a resposta
            if (createdLeads.isEmpty()) {
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf('Erros: ' + JSON.serialize(errors));
            } else {
                RestContext.response.statusCode = 200;
                Map<String, Object> responseMap = new Map<String, Object>();
                responseMap.put('successMessages', successMessages);
                responseMap.put('errors', errors);
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            }
        } catch (Exception e) {
            System.debug('Erro: ' + e.getMessage() + ' Linha: ' + e.getLineNumber());
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf('Erro do servidor: ' + e.getMessage());
        }
    }
}