@isTest
public class AtualizarLeadBolsaoJobTest {

    @isTest
    static void testLeadClonagem() {
        // Criando um Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c();  
        empreendimento.Name = 'Teste empreendimento';  
        empreendimento.CNPJEmpreendimento__c = '12345678000195';  
        insert empreendimento;

        // Criando um Lead para teste
        Lead testLead = new Lead(
            LastName = 'Ewerton Lima',
            Company = 'Ewerton Empresa',
            Email = 'ewertonzorolima@gmail.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '5511989062680',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;

        // Criando o Lead duplicado para testar clonagem
        Lead duplicateLead = new Lead(
            LastName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'silva@xyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '5511987654321',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert duplicateLead;

        // Criando a instância de RoletaLeads com a estrutura fornecida
        RecordType recordTypeCorretor = [SELECT Id, Name FROM RecordType WHERE Name = 'Corretor' LIMIT 1];
        Id perfilAdministradorSistema = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator'].id;
        
        // Criando e inserindo um Contact
        Contact ctt = new Contact(
            LastName = 'Jorge',
            DatadeVencimento__c = Date.today(),
            Cpf__c = '18875199043',
            RecordTypeId = recordTypeCorretor.Id
        );
        insert ctt;

        // Atualizando o Contact (seguindo a estrutura fornecida)
        update ctt;

        // Criando usuários para a roleta
        List<User> usuarios = new List<User>{
            new User(
                Alias = 'usuario1',
                Email = 'usuario1@example.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'User1',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'novoteste@example.com',
                ProfileId = perfilAdministradorSistema,
                Situacao__c = 'Online'
            ),
            new User(
                Alias = 'usuario2',
                Email = 'usuario2@example.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'User2',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'salada1@example.com',
                ProfileId = perfilAdministradorSistema,
                Situacao__c = 'Online'
            )
        };
        insert usuarios;

        // Criando e inserindo a Equipe
        Equipe__c equipe = new Equipe__c();
        insert equipe;

        // Criando membros para a Equipe
        List<MembroEquipe__c> membrosEquipes = new List<MembroEquipe__c>{
            new MembroEquipe__c(
                Name = 'Equipe A',
                Equipe__c = equipe.Id,
                Usuario__c = usuarios.get(0).Id
            ),
            new MembroEquipe__c(
                Name = 'Equipe B',
                Equipe__c = equipe.Id,
                Usuario__c = usuarios.get(1).Id
            )
        };
        insert membrosEquipes;

        // Criando a RoletaLeads
        RoletaLeads__c roletaLeads = new RoletaLeads__c(
            Name = 'Roleta - Equipe 0',
            Ativa__c = true,
            HoraInicio__c = Datetime.now().time(),
            CanaisAtendimento__c = 'WhatsApp',
            Equipe__c = equipe.Id,
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );
        insert roletaLeads;

        // Criando o participante da roleta
        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            Entrada__c = System.now(),
            MembroEquipe__c = membrosEquipes.get(0).Id,
            RoletaLeads__c = roletaLeads.Id
        );
        insert participante;

        // Atualizando o campo RoletaLeads__c nos Leads
        testLead.RoletaLeads__c = roletaLeads.Id;
        duplicateLead.RoletaLeads__c = roletaLeads.Id;
        update new List<Lead>{testLead, duplicateLead};

        // Executando o job
        Test.startTest();
        AtualizarLeadBolsaoJob job = new AtualizarLeadBolsaoJob(roletaLeads.Id);
        System.schedule('Test Lead Clonagem Job', '0 0 0 1 1 ?', job);
        Test.stopTest();

    }

    @isTest
    static void testLeadsSemDuplicidade() {
        // Criando um Empreendimento
        Empreendimento__c empreendimento = new Empreendimento__c();  
        empreendimento.Name = 'Teste empreendimento 2';  
        empreendimento.CNPJEmpreendimento__c = '98765432000195';  
        insert empreendimento;

        // Criando um Lead sem duplicidade
        Lead testLead = new Lead(
            LastName = 'Souza',
            Company = 'Empresa ABC',
            Email = 'souza@abc.com',
            LeadSource = 'WhatsApp',
            CanalAtendimento__c = 'WhatsApp',
            MobilePhone = '5511987654322',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;

        // Criando a instância de RoletaLeads para a busca
        RecordType recordTypeCorretor = [SELECT Id, Name FROM RecordType WHERE Name = 'Corretor' LIMIT 1];
        Id perfilAdministradorSistema = [SELECT Id FROM Profile WHERE Name = 'Administrador do sistema' OR Name = 'System Administrator'].id;
        
        // Criando o Lead para a roleta
        Contact ctt = new Contact(
            LastName = 'Maria',
            DatadeVencimento__c = Date.today(),
            Cpf__c = '12345678901',
            RecordTypeId = recordTypeCorretor.Id
        );
        insert ctt;

        // Atualizando o Contact
        update ctt;

        // Criando usuários para a roleta
        List<User> usuarios = new List<User>{
            new User(
                Alias = 'testesal',
                Email = 'testesalada@example.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'User1',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'salad3nha@gmail.com',
                ProfileId = perfilAdministradorSistema,
                Situacao__c = 'Online'
            )
        };
        insert usuarios;

        // Criando a Equipe e a Roleta
        Equipe__c equipe = new Equipe__c();
        insert equipe;

        // Criando o membro da Equipe
        MembroEquipe__c membroEquipe = new MembroEquipe__c(
            Name = 'Equipe 1',
            Equipe__c = equipe.Id,
            Usuario__c = usuarios.get(0).Id
        );
        insert membroEquipe;

        RoletaLeads__c roletaLeads = new RoletaLeads__c(
            Name = 'Roleta - Equipe 1',
            Ativa__c = true,
            HoraInicio__c = Datetime.now().time(),
            CanaisAtendimento__c = 'WhatsApp',
            Equipe__c = equipe.Id,
            DiasSemana__c = 'Segunda-feira;Terça-feira'
        );
        insert roletaLeads;

        // Criando o participante da roleta
        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            Entrada__c = System.now(),
            MembroEquipe__c = membroEquipe.Id,
            RoletaLeads__c = roletaLeads.Id
        );
        insert participante;

        // Atualizando o campo RoletaLeads__c no Lead
        testLead.RoletaLeads__c = roletaLeads.Id;
        update testLead;

        // Executando o job
        Test.startTest();
        AtualizarLeadBolsaoJob job = new AtualizarLeadBolsaoJob(roletaLeads.Id);
        System.schedule('Test Lead Clonagem Job', '0 0 0 1 1 ?', job);
        Test.stopTest();
    }
}