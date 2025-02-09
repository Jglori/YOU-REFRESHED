public without sharing class ConciergeService {
    private static final Id ID_LEAD_TIPO_PF = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('PessoaFisica').getRecordTypeId();
    private static final Id ID_LEAD_TIPO_PJ = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('PessoaJuridica').getRecordTypeId();

    public static Map<String, String> obterCanaisAtendimento() {
        Map<String, String> canaisAtendimentoPorValor = new Map<String, String>();
        for(Schema.PicklistEntry opcaoCanalAtendimento : Lead.CanalAtendimento__c.getDescribe().getPicklistValues()) {
            canaisAtendimentoPorValor.put(opcaoCanalAtendimento.getValue(), opcaoCanalAtendimento.getLabel());
        }
        
        return canaisAtendimentoPorValor;
    }

    public static Map<String, String> obterOrigens() {
        Map<String, String> origensPorValor = new Map<String, String>();
        for(Schema.PicklistEntry opcaoOrigem : Lead.LeadSource.getDescribe().getPicklistValues()) {
            origensPorValor.put(opcaoOrigem.getValue(), opcaoOrigem.getLabel());
        }

        return origensPorValor;
    }

    public static String obterLeadsPorInformacoesConcierge(String celular, String email, Boolean isJuridica , String phone ) {
        List<LeadDTO> leadsDTO = new List<LeadDTO>();
        for(Lead lead : LeadSelector.obterLeadsPorInformacoesConcierge(celular, email, isJuridica , phone)) {
            leadsDTO.add(new LeadDTO(lead));
        }
    
        return JSON.serialize(leadsDTO);
    }
    

    public static String obterRoletasLeadsVigentes() {
        List<RoletaLeadsDTO> roletasLeadsDTO = new List<RoletaLeadsDTO>();
        for(RoletaLeads__c roletaLeads : RoletaLeadsSelector.obterRoletasLeadsVigentes()) {
            roletasLeadsDTO.add(new RoletaLeadsDTO(roletaLeads));
        }
        return JSON.serialize(roletasLeadsDTO);
    }

    public static void atualizarLead(List<Map<String, Object>> formulario) {
        
        if (formulario != null && !formulario.isEmpty()) {
            for (Map<String, Object> leadData : formulario) {
                String id = (String) leadData.get('id');
                String idRoletaLeads = (String) leadData.get('idRoleta');
                
                if (!String.isBlank(id)) { 
                    Lead leadToUpdate = [SELECT Id, Email , RoletaLeads__c FROM Lead WHERE Id = :id LIMIT 1];
                    if (leadToUpdate != null) {
                        leadToUpdate.RoletaLeads__c = idRoletaLeads;
                        update leadToUpdate;
                        criarTarefaReiteracaoSeNecessario(leadToUpdate);
                    }
                }
            }
        }
    }
    
    public static List<Contact> buscarCorretoresLetra(String corretor) {
        List<Contact> corretores = [SELECT Id, Name FROM Contact WHERE Name like :corretor + '%' AND Corretor__c = true LIMIT 200];
        return corretores;
    }

    public static List<Contact> buscarTodosCorretores() {
        List<Contact> corretores = [SELECT Id, Apelido__c  FROM Contact WHERE RecordType.Name = 'Corretor' AND StatusCorretor__c = 'Ativo' LIMIT 200];
        return corretores;
    }

    public static void criarLead(Map<String, String> formulario) {
        System.debug('Entrou no método criarLead com formulário: ' + formulario);
    
        // Obtendo valores do formulário
        String tipoUsuario = formulario.get('tipoPessoa');
        String nome = formulario.get('nome');
        String celular = formulario.get('celular');
        String email = formulario.get('email');
        String origem = formulario.get('origem');
        String canal = formulario.get('canal');
        String razaoSocial = formulario.get('razaoSocial');
        String phone = formulario.get('phone');
        String idRoletaLeads = formulario.get('idRoletaLeads');
        String nomeRepresentante = formulario.get('nomeRepresentante');
        String corretor = formulario.get('corretor');
        String celularRepresentante = formulario.get('celularRepresentante');
    
        // Debug: Logando os valores recebidos
        System.debug('tipoUsuario: ' + tipoUsuario);
        System.debug('nome: ' + nome);
        System.debug('celular: ' + celular);
        System.debug('email: ' + email);
        System.debug('origem: ' + origem);
        System.debug('canal: ' + canal);
        System.debug('razaoSocial: ' + razaoSocial);
        System.debug('phone: ' + phone);
        System.debug('idRoletaLeads: ' + idRoletaLeads);
        System.debug('nomeRepresentante: ' + nomeRepresentante);
        System.debug('corretor: ' + corretor);
        System.debug('celularRepresentante: ' + celularRepresentante);
    
        // Verifica se os campos obrigatórios para o tipo de pessoa estão preenchidos
        Boolean camposObrigatoriosPreenchidos = true;
    
        if (String.isBlank(nome) || String.isBlank(email) || String.isBlank(origem) || String.isBlank(canal)) {
            camposObrigatoriosPreenchidos = false;
            System.debug('Campos obrigatórios gerais estão faltando.');
        }
    
        if (tipoUsuario == 'Física') {
            if (String.isBlank(celular)) {
                camposObrigatoriosPreenchidos = false;
                System.debug('Campo obrigatório para Pessoa Física está faltando: celular');
            }
        } else if (tipoUsuario == 'Jurídica') {
            if (String.isBlank(razaoSocial)) {
                camposObrigatoriosPreenchidos = false;
                System.debug('Campo obrigatório para Pessoa Jurídica está faltando: razaoSocial');
            }
            if (String.isBlank(phone)) {
                camposObrigatoriosPreenchidos = false;
                System.debug('Campo obrigatório para Pessoa Jurídica está faltando: phone');
            }
            if (String.isBlank(nomeRepresentante)) {
                camposObrigatoriosPreenchidos = false;
                System.debug('Campo obrigatório para Pessoa Jurídica está faltando: nomeRepresentante');
            }
            if (String.isBlank(celularRepresentante)) {
                camposObrigatoriosPreenchidos = false;
                System.debug('Campo obrigatório para Pessoa Jurídica está faltando: celularRepresentante');
            }
        }
    
        if (!camposObrigatoriosPreenchidos) {
            System.debug('Alguns campos obrigatórios não estão preenchidos. Continuando a criação do Lead com dados disponíveis.');
        }
    
        // Separar nomes
        Map<String, String> nomes = separarNomes(nome);
        System.debug('Nomes separados: ' + nomes);
    
        // Criar o Lead
        Lead lead = new Lead();
        lead.Email = email;
        lead.LeadSource = origem;
        lead.CanalAtendimento__c = canal;
        lead.Status = 'Novo';
    
        if (tipoUsuario == 'Física') {
            lead.FirstName = nomes.get('firstName');
            lead.LastName = nomes.get('lastName');
            lead.RecordTypeId = ID_LEAD_TIPO_PF;
            lead.MobilePhone = celular;
            lead.RazaoSocial__c = null;
            System.debug('Tipo usuário é Física. Lead preenchido: ' + lead);
        } else {
            lead.RecordTypeId = ID_LEAD_TIPO_PJ;
            lead.Phone = phone;
            lead.MobilePhone = null;
            lead.LastName = nomeRepresentante;
            lead.RazaoSocial__c = razaoSocial;
            lead.CelularComercialAdicional__c = celularRepresentante;
            System.debug('Tipo usuário é Jurídica. Lead preenchido: ' + lead);
        }
    
        if (!String.isBlank(corretor) && !String.isBlank(idRoletaLeads)) {
            throw new AuraHandledException('Erro: Não é possível selecionar uma roleta e um corretor ao mesmo tempo.');
        }
    
        if (!String.isBlank(corretor)) {
            lead.CorretorContato__c = corretor;
            User us = new User();

            us = UserSelector.obterUsuariosPorContactIds(corretor);

            if(us <> null){
                lead.OwnerId  = us.Id;
            }
            System.debug('Corretor associado: ' + corretor);
        }
    
        if (!String.isBlank(idRoletaLeads)) {
            lead.RoletaLeads__c = idRoletaLeads;
            System.debug('Roleta Leads associada: ' + idRoletaLeads);
        }
        try {
            insert lead;
            System.debug('Lead criado com sucesso: ' + lead.Id);
        } catch (DmlException e) {
            System.debug('Erro ao criar lead: ' + e.getMessage());
        }

        
    }
    
    
    
    
    public static void notifyUsers(Set<String> recipientsIds, String targetId, String title, String body) {
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='NotificacaoPersonalizada'
             LIMIT 1];

        if (notificationType != null) {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(title);
            notification.setBody(body);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(targetId);

            try {
                notification.send(recipientsIds);
            } catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
        } else {
            System.debug('CustomNotificationType NotificacaoPersonalizada not found');
        }
    }

    // Método para criar tarefa de reiteração e notificar o proprietário
    public static void criarTarefaReiteracaoSeNecessario(Lead novoLead) {
        // Obter o lead existente com base no e-mail
        Lead leadExistente = [SELECT Id, LastName, MobilePhone, Email, LeadSource, EmpreendimentoInteresse__r.Name, QuantidadeDeReiteracoes__c, Owner.Email, OwnerId,
        CorretorContato__c
                              FROM Lead
                              WHERE Email = :novoLead.Email
                              AND Id != :novoLead.Id
                              ORDER BY CreatedDate DESC
                              LIMIT 1];

        if (leadExistente != null) {
            // Atualizar as informações do lead existente
            leadExistente.MobilePhone = novoLead.MobilePhone;
            leadExistente.LeadSource = novoLead.LeadSource;
            leadExistente.QuantidadeDeReiteracoes__c += 1;
            update leadExistente;

            String nomeEmpreendimento = leadExistente.EmpreendimentoInteresse__r != null ? leadExistente.EmpreendimentoInteresse__r.Name : '';

            // Criar a nova tarefa
            Task newTask = new Task(
                WhoId = leadExistente.CorretorContato__c,
                Subject = 'Reiteração',
                Status = 'Open',
                ActivityDate = Date.today().addDays(1),
                Description = 'Reiteração do Lead. Nome: ' + leadExistente.LastName 
                    + ', Telefone: ' + leadExistente.MobilePhone 
                    + ', Email: ' + leadExistente.Email 
                    + ', Empreendimento de Interesse: ' + nomeEmpreendimento 
                    + ', Origem do Lead: ' + leadExistente.LeadSource 
                    + ', Data e horário da interação: ' + DateTime.now().format('dd/MM/yyyy HH:mm:ss')
            );

            // Verificar se já existe uma tarefa aberta e completar a existente
            List<Task> tasksAbertas = [SELECT Id FROM Task WHERE WhoId = :leadExistente.Id AND Status = 'Open' LIMIT 1];
            if (!tasksAbertas.isEmpty()) {
                Task existingTask = tasksAbertas[0];
                existingTask.Status = 'Completed'; // Marcar a tarefa existente como completada
                update existingTask;
            }

            // Inserir a nova tarefa
            insert newTask;

            // Enviar e-mail para o proprietário da tarefa
            User taskOwner = [SELECT Email FROM User WHERE Id = :leadExistente.OwnerId LIMIT 1];
            if (taskOwner != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{taskOwner.Email});
                email.setSubject('Nova Tarefa: Reiteração de Lead');
                email.setPlainTextBody('Olá! Seu cliente entrou novamente em contato com você! Verifique as TAREFAS do seu Lead e veja a reiteração.');
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            }

            // Enviar notificação personalizada
            String notificationTitle = 'Nova Tarefa: Reiteração de Lead';
            String notificationBody = 'Olá! Seu cliente entrou novamente em contato com você! Verifique as TAREFAS do seu Lead e veja a reiteração.';
            Set<String> recipientsIds = new Set<String>{leadExistente.OwnerId};

            notifyUsers(recipientsIds, leadExistente.Id, notificationTitle, notificationBody);
        }
    } 
    
    private static Map<String, String> separarNomes(String nome) {
        return nome.contains(' ') 
            ? new Map<String, String>{
                'firstName' => nome.left(nome.indexOf(' ')),
                'lastName' => nome.right(nome.length() - nome.indexOf(' ') - 1)
            }
            : new Map<String, String>{
                'firstName' => '',
                'lastName' => nome
            };
    }


    @AuraEnabled
    public static void criarTaskReiteracao(String jsonData, Id roletaId) {
        // Deserializa o JSON em um mapa
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
    
        System.debug('Parâmetros recebidos: ' + params);
    
        // Verifica se os parâmetros estão corretos
        if (params == null || !params.containsKey('lead')) {
            throw new AuraHandledException('Dados inválidos.');
        }
    
        // Extrai os dados do lead
        Map<String, Object> leadData = (Map<String, Object>) params.get('lead');
    
        // Verifica se nomeCorretor está no leadData
        String nomeCorretor = (String) leadData.get('nomeCorretor');
        
        // Verificação e processamento dos dados do lead
        String leadId = (String) leadData.get('id');
        if (String.isEmpty(leadId)) {
            throw new AuraHandledException('ID do lead não pode estar vazio.');
        }
    
        Lead lead;
        try {
            lead = [SELECT Id, LastName, MobilePhone, Email, EmpreendimentoInteresse__c, LeadSource, QuantidadeDeReiteracoes__c, Owner.Email, OwnerId , CorretorContato__c
                    FROM Lead WHERE Id = :leadId LIMIT 1];
        } catch (QueryException e) {
            throw new AuraHandledException('Lead não encontrado com o ID fornecido.');
        }
    
        if (lead == null) {
            throw new AuraHandledException('Lead não encontrado.');
        }
    
        DateTime tomorrow = System.now().addDays(1);
    
        // Obtém o empreendimento de interesse ou define como 'Não informado'
        String empreendimentoInteresse = (String) leadData.get('empreendimentoInteresse');
        if (String.isEmpty(empreendimentoInteresse)) {
            empreendimentoInteresse = 'Não informado';
        }
    
        // Monta a descrição da tarefa de reiteração
        String descricao = 'Reiteração do Lead. Nome: ' + (lead.LastName != null ? lead.LastName : 'Não informado')
            + ', Telefone: ' + (lead.MobilePhone != null ? lead.MobilePhone : 'Não informado')
            + ', Email: ' + (lead.Email != null ? lead.Email : 'Não informado')
            + ', Empreendimento de Interesse: ' + empreendimentoInteresse
            + ', Origem do Lead: ' + (lead.LeadSource != null ? lead.LeadSource : 'Não informado')
            + ', Data e horário da interação: ' + DateTime.now().format('dd/MM/yyyy HH:mm:ss')
            + ', Corretor: ' + (nomeCorretor != null ? nomeCorretor : 'Não informado');
    
        // Cria a tarefa de reiteração
        Task tarefaReiteracao = new Task(
            WhoId = lead.CorretorContato__c,
            Subject = 'Reiteração',
            Description = descricao,
            Status = 'Open',
            ActivityDate = tomorrow.date()
        );
    
        try {
            // Incrementa a quantidade de reiterações e atualiza o lead
            lead.QuantidadeDeReiteracoes__c = (lead.QuantidadeDeReiteracoes__c != null ? lead.QuantidadeDeReiteracoes__c : 0) + 1;
            lead.ltima_Reitera_o__c = DateTime.now();
    
            // Atualiza o roletaId se necessário
            if (roletaId != null) {
                lead.RoletaLeads__c = roletaId;
            }
    
            update lead;
    
            // Insere a tarefa de reiteração
            insert tarefaReiteracao;
    
            // Envio de e-mail para o proprietário do lead
            User taskOwner = [SELECT Email FROM User WHERE Id = :lead.OwnerId LIMIT 1];
            if (taskOwner != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{taskOwner.Email});
                email.setSubject('Nova Tarefa: Reiteração de Lead');
                email.setPlainTextBody('Olá! Seu cliente entrou novamente em contato com você! Verifique as TAREFAS do seu Lead e veja a reiteração.');
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            }
    
            // Envio de notificação personalizada
            String notificationTitle = 'Nova Tarefa: Reiteração de Lead';
            String notificationBody = 'Olá! Seu cliente entrou novamente em contato com você! Verifique as TAREFAS do seu Lead e veja a reiteração.';
            Set<String> recipientsIds = new Set<String>{lead.OwnerId};
    
            notifyUsers(recipientsIds, lead.Id, notificationTitle, notificationBody);
    
        } catch (DmlException e) {
            throw new AuraHandledException('Erro ao criar a tarefa: ' + e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static void criarTaskReiteracaoeAssociarCorretor(String jsonLead, Id corretorId) {
        // Deserializa o JSON em um mapa
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(jsonLead);
    
        System.debug('Parâmetros recebidos: ' + params);
    
        // Verifica se o 'lead' está presente e é um mapa
        if (params == null || !params.containsKey('lead') || !(params.get('lead') instanceof Map<String, Object>)) {
            throw new AuraHandledException('Dados do lead inválidos.');
        }
    
        // Extrai o mapa de dados do lead
        Map<String, Object> leadData = (Map<String, Object>) params.get('lead');
    
        // Extração dos dados específicos do lead
        String leadId = leadData.containsKey('id') ? (String) leadData.get('id') : null;
        String nomeCorretor = leadData.containsKey('nomeCorretor') ? (String) leadData.get('nomeCorretor') : null;
    
        // Verificação e processamento dos dados do lead
        if (String.isEmpty(leadId)) {
            throw new AuraHandledException('ID do lead não pode estar vazio.');
        }
    
        Lead lead;
        try {
            lead = [SELECT Id, LastName, MobilePhone, Email, EmpreendimentoInteresse__c, LeadSource, QuantidadeDeReiteracoes__c, CorretorContato__c, OwnerId, ltima_Reitera_o__c  
                    FROM Lead WHERE Id = :leadId LIMIT 1];
        } catch (QueryException e) {
            throw new AuraHandledException('Lead não encontrado com o ID fornecido.');
        }
    
        if (lead == null) {
            throw new AuraHandledException('Lead não encontrado.');
        }
    
        DateTime tomorrow = System.now().addDays(1);
    
        String empreendimentoInteresse = leadData.containsKey('empreendimentoInteresse') ? (String) leadData.get('empreendimentoInteresse') : 'Não informado';
    
        String descricao = 'Reiteração do Lead. Nome: ' + (lead.LastName != null ? lead.LastName : 'Não informado')
            + ', Telefone: ' + (lead.MobilePhone != null ? lead.MobilePhone : 'Não informado')
            + ', Email: ' + (lead.Email != null ? lead.Email : 'Não informado')
            + ', Empreendimento de Interesse: ' + empreendimentoInteresse
            + ', Origem do Lead: ' + (lead.LeadSource != null ? lead.LeadSource : 'Não informado')
            + ', Data e horário da interação: ' + DateTime.now().format('dd/MM/yyyy HH:mm:ss')
            + ', Corretor: ' + (nomeCorretor != null ? nomeCorretor : 'Não informado');
    
        Task tarefaReiteracao = new Task(
            WhoId = lead.CorretorContato__c,
            Subject = 'Reiteração',
            Description = descricao,
            Status = 'Open',
            ActivityDate = tomorrow.date()
        );
    
        try {
            // Incrementa a quantidade de reiterações em 1
            lead.QuantidadeDeReiteracoes__c = (lead.QuantidadeDeReiteracoes__c != null ? lead.QuantidadeDeReiteracoes__c : 0) + 1;
            
            // Atualiza a data da última reiteração
            lead.ltima_Reitera_o__c  = DateTime.now();
            
            // Define o corretor de contato
            lead.CorretorContato__c = corretorId;
            
            // Atualiza o lead no banco de dados
            update lead;
        
            // Insere a tarefa de reiteração
            insert tarefaReiteracao;
            
            // Envio de e-mail para o proprietário do lead
            User taskOwner = [SELECT Email FROM User WHERE Id = :lead.OwnerId LIMIT 1];
           
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{taskOwner.Email});
                email.setSubject('Nova Tarefa: Reiteração de Lead');
                email.setPlainTextBody('Olá! Seu cliente entrou novamente em contato com você! Verifique as TAREFAS do seu Lead e veja a reiteração.');
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            
     
            // Envio de notificação personalizada
            String notificationTitle = 'Nova Tarefa: Reiteração de Lead';
            String notificationBody = 'Olá! Seu cliente entrou novamente em contato com você! Verifique as TAREFAS do seu Lead e veja a reiteração.';
            Set<String> recipientsIds = new Set<String>{lead.OwnerId};
     
            notifyUsers(recipientsIds, lead.Id, notificationTitle, notificationBody);
     
        } catch (DmlException e) {
            throw new AuraHandledException('Erro ao criar a tarefa: ' + e.getMessage());
        }
    }
    
}