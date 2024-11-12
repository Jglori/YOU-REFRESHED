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
        List<String> duplicateLeadInfo = new List<String>();
        List<Lead> leadsToInsert = new List<Lead>();
        List<Lead> createdLeadsInfo = new List<Lead>();
        List<Lead> leadsReiterados = new List<Lead>();
        List<Lead> leadsWhatsapp = new List<Lead>();
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
    
            // Variáveis globais para armazenar informações do Lead
            String emailLead;
            String celularLead;
            String telefoneLead;
            String nomeLead;
            String dataIteracaoMtn;
            String idEmpreendimentoInteresse;
    
            for (Map<String, Object> params : leadsParams) {
                String tipoPessoa = (String) params.get('tipoPessoa');
                String recordTypeToUse = (tipoPessoa == 'Física') ? 'Pessoa Física' : 'Pessoa Jurídica';
    
                if (!recordTypeMap.containsKey(recordTypeToUse)) {
                    errors.add('Falha: O RecordType ' + recordTypeToUse + ' não foi encontrado.');
                    continue;
                }
    
                // Verificações de campos obrigatórios
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
    
                // Armazenando os valores antes do loop para consulta
                emailLead = (String) params.get('email');
                celularLead = (String) params.get('celular');
                telefoneLead = (String) params.get('telefone');
                nomeLead = (String) params.get('nome');
                dataIteracaoMtn = String.valueOf(params.get('dataIteracaoMtn'));
                idEmpreendimentoInteresse = (String) params.get('idEmpreendimentoInteresse');
    
                // Verificar duplicidade antes de adicionar à lista de inserção
                List<Lead> potentialDuplicateLeads = [
                    SELECT Id, LastName, Name, Email, MobilePhone, Phone, EmailAdicional__c, 
                           CelularAdicional__c, CelularAdicional1__c, CelularAdicional2__c, 
                           CelularComercialAdicional__c, OwnerId, CanalAtendimento__c, 
                           QuantidadeDeReiteracoes__c, EmpreendimentoInteresse__c, LeadSource, 
                           Status, ltima_Reitera_o__c
                    FROM Lead
                    WHERE (Email = :emailLead OR EmailAdicional__c = :emailLead)
                    AND (
                        (MobilePhone = :celularLead OR Phone = :telefoneLead)
                        OR (CelularAdicional__c = :celularLead)
                        OR (CelularAdicional1__c = :celularLead)
                        OR (CelularAdicional2__c = :celularLead)
                        OR (CelularComercialAdicional__c = :celularLead)
                    )
                ];
    
                if (!potentialDuplicateLeads.isEmpty()) {
                    RestContext.response.statusCode = 409;
                    String message = ' Lead encontrado. Email: ' + emailLead + ', Celular: ' + celularLead + ', Telefone: ' + telefoneLead + ' Tarefa(s) de Reiteração criada(s).';
                    for (Lead lead : potentialDuplicateLeads) {

                        leadsReiterados.add(lead);
                        message += ' ID: ' + lead.Id + ', Nome: ' + lead.LastName + ';';
                    }
                    
                    errors.add(message);
                    continue;
                }
    
                Lead newLead = new Lead();
                newLead.RecordTypeId = recordTypeMap.get(recordTypeToUse);
                newLead.Email = emailLead;
                newLead.LeadSource = (String) params.get('origem');
                newLead.CanalAtendimento__c = (String) params.get('canal');
                newLead.Status = 'Novo';
                newLead.Informacoes_Adicionais__c = (String) params.get('informacoesAdicionaisLead');
                newLead.EmpreendimentoInteresse__c = (Id) params.get('idEmpreendimentoInteresse');
                newLead.CelularAdicional__c = (String) params.get('celularAdicional');
                newLead.CelularAdicional2__c = (String) params.get('celularAdicional2');
                newLead.CelularAdicional1__c = (String) params.get('celularAdicional1');
                newLead.CelularComercialAdicional__c = (String) params.get('celularComercialAdicional');
                newLead.EmailAdicional__c = (String) params.get('emailAdicional');
                newLead.SubProduto__c = (String) params.get('SubProduto');

               
                
    
                Datetime horario = Datetime.now();
                Datetime horarioBrasilia = horario.addHours(-3);
    
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
    
                if (dataIteracaoMtn != null) {
                    try {
                        // Remover 'Z' e substituir o 'T' por um espaço
                        String formattedDate = dataIteracaoMtn.replace('Z', '').replace('T', ' ');
                        Datetime datetimeValue = Datetime.valueOf(formattedDate);
                        newLead.Data_Iteracao_MTN__c = datetimeValue;
                    } catch (Exception e) {
                        errors.add('Formato de data inválido: ' + dataIteracaoMtn);
                    }
                }
    
                leadsToInsert.add(newLead);
            }

          
            List<Task> tasksToInsert = new List<Task>();
            List<Lead> leadsToUpdate = new List<Lead>();
            
            for (Lead leadReiterado : leadsReiterados) {
                Task tarefaReiteracao = new Task(
                    WhoId = leadReiterado.Id, 
                    Subject = 'Reiteração',
                    Status = 'Open',
                    Nome_do_Lead__c = leadReiterado.LastName != null ? leadReiterado.LastName : 'Não informado',
                    Origem_do_Lead__c = leadReiterado.LeadSource != null ? leadReiterado.LeadSource : 'Não informado',
                    Canal_de_Atendimento__c = leadReiterado.CanalAtendimento__c != null ? leadReiterado.CanalAtendimento__c : 'Não informado',
                    Email__c = leadReiterado.Email != null ? leadReiterado.Email : 'Não informado',
                    Celular__c = leadReiterado.MobilePhone != null ? leadReiterado.MobilePhone : 'Não informado',
                    ActivityDate = Date.today().addDays(1),
                    Telefone__c = leadReiterado.Phone != null ? leadReiterado.Phone : 'Não informado',
                    OwnerId = leadReiterado.OwnerId
                );
                tasksToInsert.add(tarefaReiteracao);
            
                leadReiterado.QuantidadeDeReiteracoes__c = leadReiterado.QuantidadeDeReiteracoes__c != null ? leadReiterado.QuantidadeDeReiteracoes__c + 1 : 1;
                leadReiterado.ltima_Reitera_o__c = Datetime.now();
                leadReiterado.EmpreendimentoInteresse__c = idEmpreendimentoInteresse;
                leadReiterado.MobilePhone = celularLead;
                leadReiterado.Email = emailLead;
                
                
            
                leadsToUpdate.add(leadReiterado);
            
                if (leadsToUpdate.size() == 50) {
                    System.enqueueJob(new LeadQueueableReiterado(leadsToUpdate));
                    leadsToUpdate = new List<Lead>();
                }
            }
            
            if (!tasksToInsert.isEmpty()) {
                insert tasksToInsert;
            }
            
            if (!leadsToUpdate.isEmpty()) {
                System.enqueueJob(new LeadQueueableReiterado(leadsToUpdate));
            }
            
           

            
            
    
            if (!leadsToInsert.isEmpty()) {
                List<Lead> currentBatch = new List<Lead>();
                for (Lead lead : leadsToInsert) {
                    currentBatch.add(lead);
                    if (currentBatch.size() == 50) {
                        System.enqueueJob(new LeadQueueable(currentBatch));
                        createdLeadsInfo.addAll(currentBatch);
                        currentBatch = new List<Lead>();
                    }
                }
    
                if (!currentBatch.isEmpty()) {
                    System.enqueueJob(new LeadQueueable(currentBatch));
                    createdLeadsInfo.addAll(currentBatch);
                }
            }
    
            if (!errors.isEmpty()) {
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf('Leads Encontados: ' + String.join(errors, ', '));
            } else {
                String responseMessage = 'Lead(s) criado(s) com sucesso! ';
                if (!duplicateLeadInfo.isEmpty()) {
                    responseMessage += 'Tarefa(s) de Reiteração criada(s): ' + String.join(duplicateLeadInfo, ', ');
                }
                RestContext.response.statusCode = 201;
                RestContext.response.responseBody = Blob.valueOf(responseMessage);
            }
        } catch (Exception e) {
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf('Ocorreu um erro inesperado: ' + e.getMessage());
        }
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