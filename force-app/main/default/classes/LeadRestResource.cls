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
        List<String> errosBase400 = new List<String>();
        List<Lead> leadsToInsert = new List<Lead>();
        List<Lead> createdLeadsInfo = new List<Lead>();
        List<Lead> leadsReiterados = new List<Lead>();
        List<Lead> leadsWhatsapp = new List<Lead>();
        List<String> errosInsert = new List<String>();
        List<String> leadsDuplicadosInsercao = new List<String>();
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
            String origemLead;
            String canalLead;
            String informacoesAdicionaisLead;
            String subProduto;
    
            for (Map<String, Object> params : leadsParams) {
                String tipoPessoa = (String) params.get('tipoPessoa');
                String recordTypeToUse = (tipoPessoa == 'Física') ? 'Pessoa Física' : 'Pessoa Jurídica';
    
                if (!recordTypeMap.containsKey(recordTypeToUse)) { errors.add('Falha: O RecordType ' + recordTypeToUse + ' não foi encontrado.');errosInsert.add('RecordType não encontrado: ' + recordTypeToUse);continue;
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
                        String.isBlank((String) params.get('canal'))) { errors.add('Lead (Jurídica): Campos obrigatórios estão faltando.');continue;
                    }
                }
    
                // Armazenando os valores antes do loop para consulta
                emailLead = (String) params.get('email');
                System.debug('Email: ' + emailLead);
                celularLead = (String) params.get('celular');
                System.debug('Celular: ' + celularLead);
                telefoneLead = (String) params.get('telefone');
                System.debug('Telefone: ' + telefoneLead);
                canalLead = (String) params.get('canal');
                System.debug('Canal: ' + canalLead);
                origemLead = (String) params.get('origem');
                System.debug('Origem: ' + origemLead);
                nomeLead = (String) params.get('nome');
                System.debug('Nome: ' + nomeLead);
                dataIteracaoMtn = String.valueOf(params.get('dataIteracaoMtn'));
                System.debug('Data Iteração MTN: ' + dataIteracaoMtn);
                idEmpreendimentoInteresse = (String) params.get('idEmpreendimentoInteresse');
                System.debug('Empreendimento Interesse: ' + idEmpreendimentoInteresse);
                informacoesAdicionaisLead = (String) params.get('informacoesAdicionaisLead');

                // se for maior que 255, corta
                
                
                System.debug('Informações Adicionais: ' + informacoesAdicionaisLead);
                subProduto = (String) params.get('SubProduto');
                System.debug('SubProduto: ' + subProduto);
    
             List<String> conditions = new List<String>();

    // Verificando se o email está presente
    if (String.isNotBlank(emailLead)) {
        conditions.add('(Email = :emailLead)');
        conditions.add('(EmailAdicional__c = :emailLead)');
    }

    if (String.isNotBlank(celularLead)) {
        conditions.add('(MobilePhone = :celularLead)');
        conditions.add('(CelularAdicional__c = :celularLead)');
        conditions.add('(CelularAdicional1__c = :celularLead)');
        conditions.add('(CelularAdicional2__c = :celularLead)');
        conditions.add('(CelularComercialAdicional__c = :celularLead)');
        conditions.add('(ChaveExternaWhatsApp__c = :celularLead)');
    }

    if (String.isNotBlank(telefoneLead)) { conditions.add('(Phone = :telefoneLead)');
    }

    String soqlQuery = 'SELECT Id, LastName, Name, Email, MobilePhone, Phone, EmailAdicional__c, ' +
                       'CelularAdicional__c, CelularAdicional1__c, CelularAdicional2__c, ' +
                       'CelularComercialAdicional__c, OwnerId, CanalAtendimento__c, ' +
                       'QuantidadeDeReiteracoes__c, EmpreendimentoInteresse__c, LeadSource, ' +
                       'Status, ltima_Reitera_o__c , Data_Iteracao_MTN__c , Informacoes_Adicionais__c, SubProduto__c , RoletaLeads__c , CorretorContato__c ' +
                       'FROM Lead ';

            if (!conditions.isEmpty()) {
                soqlQuery += 'WHERE ' + String.join(conditions, ' OR '); // Usa 'OR' entre as condições
            }

            List<Lead> potentialDuplicateLeads = Database.query(soqlQuery);
            
                        if (!potentialDuplicateLeads.isEmpty()) {
                            RestContext.response.statusCode = 409;
                            String message = '';
                            for (Lead lead : potentialDuplicateLeads) {
                                message = 'Lead encontrado. Email: ' + lead.Email + ', Celular: ' + lead.MobilePhone + ', Telefone: ' + lead.Phone + ' Tarefa(s) de Reiteração criada(s).';
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
                newLead.ChaveExternaWhatsApp__c  = (String) params.get('celular');

              

                if (params.containsKey('SubProduto')) {
                    String subProdutoValue = (String) params.get('SubProduto');
                    
                    if (subProdutoValue != null && subProdutoValue != '') {
                        List<Schema.PicklistEntry> picklistValues = Lead.SubProduto__c.getDescribe().getPicklistValues();
                        Boolean isValid = false;
                
                        for (Schema.PicklistEntry picklistValue : picklistValues) {
                            if (picklistValue.getLabel().equals(subProdutoValue)) {
                                newLead.SubProduto__c = picklistValue.getValue();
                                isValid = true;
                                break;
                            }
                        }
                
                        if (!isValid) {RestContext.response.statusCode = 409;errosInsert.add('SubProduto inválido: ' + subProdutoValue);errosBase400.add('SubProduto inválido: ' + subProdutoValue);newLead.SubProduto__c = '';continue;
                        }
                    } else {
                        newLead.SubProduto__c = '';
                    }
                } else {
                    newLead.SubProduto__c = '';
                }
                
                
                
              
               

                System.debug('SubProdut linha 189: ' + subProduto);
                Datetime horario = Datetime.now();
                Datetime horarioBrasilia = horario.addHours(-3);
    
                if (tipoPessoa == 'Física') {String[] nomes = nomeLead.split(' ');
                if (nomes.size() == 1) {newLead.FirstName = null;newLead.LastName = nomes[0];} 
                else if (nomes.size() > 1) {newLead.FirstName = nomes[0];
                    String sobrenome = '';for (Integer i = 1; i < nomes.size(); i++) { if (sobrenome.length() + nomes[i].length() + 1 <= 80) {
                        sobrenome += nomes[i] + ' ';} 
                        else {break;
                        }
                    }
                
                    newLead.LastName = sobrenome.trim();
                } else {
                    newLead.FirstName = null;
                    newLead.LastName = '.';
                }
                
                    
                    newLead.MobilePhone = celularLead; 
                } else {
                    newLead.Company = (String) params.get('razaoSocial');
                    newLead.Phone = telefoneLead; 
                    newLead.LastName = (String) params.get('nomeRepresentante');
                    newLead.MobilePhone = (String) params.get('celularRepresentante'); 
                }
    
                if (dataIteracaoMtn != null) { try { String formattedDate = dataIteracaoMtn.replace('Z', '').replace('T', ' ');Datetime datetimeValue = Datetime.valueOf(formattedDate);newLead.Data_Iteracao_MTN__c = datetimeValue;} catch (Exception e) { errors.add('Formato de data inválido: ' + dataIteracaoMtn);
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
                    Nome_do_Lead__c = (nomeLead.length() > 255) ? nomeLead.substring(0, 255) : nomeLead,Origem_do_Lead__c = origemLead,Canal_de_Atendimento__c = canalLead,Email__c = emailLead,EmpreendimentoInteresse__c = idEmpreendimentoInteresse, Data_Iteracao_MTN__c = leadReiterado.Data_Iteracao_MTN__c,Celular__c = celularLead,ActivityDate = Date.today().addDays(1),Telefone__c = leadReiterado.Phone != null ? leadReiterado.Phone : 'Não informado',Informacoes_Adicionais__c = (informacoesAdicionaisLead.length() >=255) ? informacoesAdicionaisLead.substring(0 , 255) : informacoesAdicionaisLead,SubProduto__c = subProduto, OwnerId = leadReiterado.OwnerId);tasksToInsert.add(tarefaReiteracao); leadReiterado.QuantidadeDeReiteracoes__c = leadReiterado.QuantidadeDeReiteracoes__c != null ? leadReiterado.QuantidadeDeReiteracoes__c + 1 : 1; leadReiterado.ltima_Reitera_o__c = Datetime.now(); leadReiterado.EmpreendimentoInteresse__c = idEmpreendimentoInteresse; leadReiterado.CanalAtendimento__c = canalLead; leadReiterado.LeadSource = origemLead; leadReiterado.Informacoes_Adicionais__c = informacoesAdicionaisLead; leadReiterado.SubProduto__c = subProduto; System.debug('Status do lead reiterateo: ' + leadReiterado.Status); if (leadReiterado.Status == 'Lead Perdido(não trabalho)' || leadReiterado.Status == 'Descartado') { RoletaLeads__c buscarProximaRoleta = [SELECT Id FROM RoletaLeads__c LIMIT 1]; System.debug('Retornando a proxima roleta: ' + buscarProximaRoleta.Id); leadReiterado.RoletaLeads__c = buscarProximaRoleta.Id; leadReiterado.Status = 'Novo'; leadReiterado.CorretorContato__c = null; leadReiterado.MotivoNaoQualificacao__c = null; } String[] nomes = nomeLead.split(' '); if (nomes.size() == 1) { leadReiterado.FirstName = null; leadReiterado.LastName = nomes[0].substring(0, Math.min(80, nomes[0].length())); } else if (nomes.size() > 1) { leadReiterado.FirstName = nomes[0].substring(0, Math.min(80, nomes[0].length())); String sobrenome = ''; for (Integer i = 1; i < nomes.size(); i++) { sobrenome += nomes[i] + ' '; } sobrenome = sobrenome.trim(); leadReiterado.LastName = sobrenome.substring(0, Math.min(80, sobrenome.length())); } else { leadReiterado.FirstName = null; leadReiterado.LastName = '.'; } if (idEmpreendimentoInteresse != null && subProduto == null) { leadReiterado.EmpreendimentoInteresse__c = idEmpreendimentoInteresse; leadReiterado.SubProduto__c = ''; } leadsToUpdate.add(leadReiterado); if (leadsToUpdate.size() == 50) { System.enqueueJob(new LeadQueueableReiterado(leadsToUpdate)); leadsToUpdate = new List<Lead>(); }

            }
            
            if (!tasksToInsert.isEmpty()) {insert tasksToInsert;
            }
            
            if (!leadsToUpdate.isEmpty()) {System.enqueueJob(new LeadQueueableReiterado(leadsToUpdate));
            }

            
            
           

            
            
    
 if (!leadsToInsert.isEmpty()) { try { List<Lead> currentBatch = new List<Lead>(); List<Empreendimento__c> empreendimentos = [SELECT Id, Name FROM Empreendimento__c]; for (Lead lead : leadsToInsert) { if (idEmpreendimentoInteresse != null && idEmpreendimentoInteresse != '') { Boolean isValid = false; for (Empreendimento__c empreendimento : empreendimentos) { if (empreendimento.Id == idEmpreendimentoInteresse) { isValid = true; break; } } if (!isValid) { errosBase400.add('Empreendimento inválido: ' + idEmpreendimentoInteresse); errosInsert.add('Empreendimento inválido: ' + idEmpreendimentoInteresse); continue; } } currentBatch.add(lead); if (currentBatch.size() == 50) { try { insertOrUpdateLeads(currentBatch); createdLeadsInfo.addAll(currentBatch); currentBatch.clear(); } catch (Exception e) { errosInsert.add('Erro ao criar leads no lote: ' + e.getMessage()); } } } if (!currentBatch.isEmpty()) { try { List<Lead> leadsDuplicados = new List<Lead>(); List<Lead> leadsParaInserir = new List<Lead>(); Set<String> emailsVistos = new Set<String>(); Set<String> celularesVistos = new Set<String>(); for (Lead batchLead : currentBatch) { Boolean isDuplicado = false; if (String.isNotBlank(batchLead.Email) && emailsVistos.contains(batchLead.Email)) { isDuplicado = true; } else if (String.isNotBlank(batchLead.MobilePhone) && celularesVistos.contains(batchLead.MobilePhone)) { isDuplicado = true; } if (isDuplicado) { leadsDuplicados.add(batchLead); } else { if (String.isNotBlank(batchLead.Email)) { emailsVistos.add(batchLead.Email); } if (String.isNotBlank(batchLead.MobilePhone)) { celularesVistos.add(batchLead.MobilePhone); } leadsParaInserir.add(batchLead); } System.debug('Processing Lead: ' + JSON.serialize(batchLead)); } if (!leadsParaInserir.isEmpty()) { insertOrUpdateLeads(leadsParaInserir); createdLeadsInfo.addAll(leadsParaInserir); } if (!leadsDuplicados.isEmpty()) { List<LogNTM__c> logsDuplicados = new List<LogNTM__c>(); String mensagem = 'Leads duplicados encontrados:\n'; for (Lead leadDuplicado : leadsDuplicados) { LogNTM__c logDuplicado = new LogNTM__c(Messagem__c = 'Lead duplicado encontrado: ' + leadDuplicado.Email + ', ' + leadDuplicado.MobilePhone + ', ' + leadDuplicado.Phone, Email__c = leadDuplicado.Email); logsDuplicados.add(logDuplicado); } if (!logsDuplicados.isEmpty()) { insert logsDuplicados; } } } catch (Exception e) { errosInsert.add('Erro ao criar os leads: ' + e.getMessage()); } } } catch (Exception e) { errors.add('Erro ao criar leads: ' + e.getMessage()); RestContext.response.statusCode = 500; RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errors)); } }
    
            
            
            if(!errosBase400.isEmpty()) {RestContext.response.statusCode = 400;RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errosBase400));
            }
            else{
                if (!errors.isEmpty()) {
                    RestContext.response.statusCode = 200;
                    RestContext.response.responseBody = Blob.valueOf( String.join(errors, ', ')); } else if(!errosInsert.isEmpty()){ RestContext.response.statusCode = 500; RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errosInsert));}else { String responseMessage = 'Lead(s) criado(s) com sucesso! ';if (!duplicateLeadInfo.isEmpty()) {responseMessage += 'Tarefa(s) de Reiteração criada(s): ' + String.join(duplicateLeadInfo, ', ');}RestContext.response.statusCode = 201;RestContext.response.responseBody = Blob.valueOf(responseMessage);
                }
        }
        } catch (Exception e) {
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf('Ocorreu um erro inesperado: ' + e.getMessage());
        }
        
    }
    
    
    @TestVisible
    private static void insertOrUpdateLeads(List<Lead> leads) {
        try {
            List<Lead> leadsToUpdate = new List<Lead>();
            List<Lead> leadsToInsert = new List<Lead>();
            Set<Id> leadIdsToUpdate = new Set<Id>();
            List<String> leadsComErro = new List<String>();

            List<LogNTM__c> logsLeadRecebidos = new List<LogNTM__c>();

            for(Lead lead : leads){
                String Lead_Recebidos = 'Dados do Lead recebidos: ' + JSON.serialize(lead);
                
                logsLeadRecebidos.add(new LogNTM__c(Lead_Recebidos__c = Lead_Recebidos));
                
                if (lead.Id != null) {
                    leadsToUpdate.add(lead);
                }
            }

            if (!logsLeadRecebidos.isEmpty()) {
                insert logsLeadRecebidos;
            }

            

    
            List<RoletaLeads__c> roletaList = [SELECT Id, HoraInicio__c, Ativa__c FROM RoletaLeads__c 
                                               WHERE CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone'];
            
        if (roletaList.isEmpty()) {
        List<LogNTM__c> logsRoleta = new List<LogNTM__c>();                           
        for (Lead lead : leads) {
        LogNTM__c logRoleta = new LogNTM__c(
        Name = 'Erro ao processar leads', 
        Messagem__c = 'Nenhuma roleta encontrada com os critérios "Fale conosco;Chat;WhatsApp;Telefone". Entre em contato com o administrador e verifique se essas roletas existem.' + 
        ' Email: ' + lead.Email + 
        ' Celular: ' + lead.MobilePhone + 
        ' Last Name: ' + lead.LastName
        );
                                                    
        logsRoleta.add(logRoleta);
        }
        
        if (!logsRoleta.isEmpty()) {
           insert logsRoleta;
        }
        throw new CustomException('Nenhuma roleta encontrada com os critérios "Fale conosco;Chat;WhatsApp;Telefone". Entre em contato com o administrador e verifique se essas roletas existem.');
        }
                                            
                                            
    
            RoletaLeads__c roletaAtiva = null;
            List<RoletaLeads__c> roletasInativas = new List<RoletaLeads__c>();
    
            for (RoletaLeads__c roleta : roletaList) {
                if (roleta.Ativa__c) {
                    roletaAtiva = roleta;
                    break;} else { roletasInativas.add(roleta);
                }
            }
    
            if (roletaAtiva == null && !roletasInativas.isEmpty()) {RoletaLeads__c roletaValida = null;Datetime horaAtual = System.now();Time horaAtualTime = horaAtual.time();for (RoletaLeads__c roleta : roletasInativas) {Time horaInicio = roleta.HoraInicio__c;if (horaAtualTime < horaInicio) {roletaValida = roleta; break;
                    }
                }
    
                if (roletaValida != null) {
                    roletaAtiva = roletaValida;
                    System.debug('Roleta ativa definida: ' + roletaAtiva.Id);
                } else {
                    List<RoletaLeads__c> roletas = [
                        SELECT Id, HoraInicio__c 
                        FROM RoletaLeads__c 
                        WHERE Ativa__c = false 
                        AND CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone' 
                        ORDER BY HoraInicio__c ASC
                    ];                
                    if (!roletas.isEmpty()) {
                        roletaAtiva = roletas[0];
                    } else {
                        System.debug('Nenhuma roleta encontrada para os critérios fornecidos.');
                        throw new CustomException('Nenhuma roleta encontrada com os critérios "Fale conosco;Chat;WhatsApp;Telefone". Entre em contato com o administrador e verifique se essas roletas existem.');
                    }
                    System.debug('Nenhuma roleta com hora futura encontrada, usando a primeira roleta inativa.');
                }
            }
    
            if (roletaAtiva == null) {for (Lead lead : leads) {leadsComErro.add(lead.Email);}return;}
    
           
    
            for (Lead lead : leads) {
                if (lead.CanalAtendimento__c == 'Telefone' || lead.CanalAtendimento__c == 'Fale conosco' || lead.CanalAtendimento__c == 'Whatsapp') { lead.RoletaLeads__c = roletaAtiva.Id;
                }
    
                if (lead.RoletaLeads__c == null) {
                    // Se a roleta não foi atribuída, ignore este lead e adicione ao erro.
                    System.debug('Lead sem roleta atribuída: ' + lead.Email);
                    leadsComErro.add(lead.Email);} else if (lead.Id != null && !leadIdsToUpdate.contains(lead.Id)) {leadsToUpdate.add(lead);leadIdsToUpdate.add(lead.Id);} else {leadsToInsert.add(lead);
                }
            }
    
            List<String> erros = new List<String>();
            for (Lead lead : leadsToInsert) {
                try {
                    
                    insert lead;}
                catch (DmlException e) {
                  leadsComErro.add(lead.Email);
                  erros.add('Erro ao inserir lead: ' + e.getMessage() + ' Email: ' + lead.Email + ' Celular: ' + lead.MobilePhone + ' Last Name: ' + lead.LastName);   
                }
            }
    
            // Processamento de atualização de leads
            for (Lead lead : leadsToUpdate) {
                try {
                    update lead; } catch (DmlException e) {leadsComErro.add(lead.Email);erros.add('Erro ao atualizar lead: ' + e.getMessage());
                }
            }
    
            // Se houverem erros, você pode tratá-los ou logá-los
            if (!erros.isEmpty()) {
                List<LogNTM__c> logs = new List<LogNTM__c>();
                for (String erro : erros) {
                    Pattern p = Pattern.compile('Email:\\s*([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})');
                    Matcher m = p.matcher(erro);
                    String emailExtraido = null;
                    if (m.find()) {
                        emailExtraido = m.group(1);
                    }
                    logs.add(new LogNTM__c(Name = 'Erro ao processar lead', Messagem__c = erro, Email__c = emailExtraido));
                }
    
                if (!logs.isEmpty()) {
                    insert logs;
                }
    
                throw new CustomException('Erros ao processar os leads: ' + String.join(erros, ', '));
            }
    
        } catch (DmlException e) {
            System.debug('Falha ao inserir ou atualizar leads: ' + e.getMessage());
           throw new CustomException('Erro ao inserir ou atualizar leads: ' + e.getMessage());
        } catch (Exception e) {
            System.debug('Erro inesperado ao processar o batch: ' + e.getMessage());
            throw new CustomException('Erro inesperado: ' + e.getMessage());
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
            response.responseBody = Blob.valueOf(JSON.serialize(camposDto));} catch (Exception e) {response.statusCode = 500;response.responseBody = Blob.valueOf('Erro ao processar a solicitação: ' + e.getMessage());
        }
    }
}