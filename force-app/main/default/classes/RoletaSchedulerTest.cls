@IsTest
private class RoletaSchedulerTest {

    @TestSetup
    static void setupTestData() {
        // Criar dados de teste necessários
        User user1 = new User(Alias = 'user1', Email = 'user1@test.com', 
            EmailEncodingKey = 'UTF-8', LastName = 'Test', LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', ProfileId = UserInfo.getProfileId(), 
            TimeZoneSidKey = 'America/Los_Angeles', 
            Username = 'user1_' + System.currentTimeMillis() + '@test.com',
            Situacao__c = 'Online');
        insert user1;

        Equipe__c equipe1 = new Equipe__c(Name = 'Equipe 1', CargaMaxima__c = 100);
        insert equipe1;

        MembroEquipe__c membro1 = new MembroEquipe__c(Name = 'Membro Teste', Equipe__c = equipe1.Id, Usuario__c = user1.Id);
        insert membro1;

        RoletaLeads__c roleta1 = new RoletaLeads__c(
            Name = 'Roleta Teste',
            Ativa__c = true,
            HoraInicio__c = Datetime.now().time(),
            CanaisAtendimento__c = 'WhatsApp',
            Equipe__c = equipe1.Id,
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );
        insert roleta1;

        RoletaLeads__c roleta2 = new RoletaLeads__c(
            Name = 'Roleta Teste 2',
            Ativa__c = true,
            HoraInicio__c = Datetime.now().time(),
            CanaisAtendimento__c = 'WhatsApp',
            Equipe__c = equipe1.Id,
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );
        insert roleta2;

        Contact corretor1 = new Contact(
            FirstName = 'Pereira Lucas', 
            LastName = 'Silva',
            CPF__c = '10695957058'
        );
        insert corretor1;

        ParticipanteRoleta__c participante1 = new ParticipanteRoleta__c(
            Name = 'Lucas',
            MembroEquipe__c = membro1.Id,
            RoletaLeads__c = roleta1.Id,
            Posicao__c = 1,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert participante1;

        ParticipanteRoleta__c participante2 = new ParticipanteRoleta__c(
            Name = 'Ewerton',
            MembroEquipe__c = membro1.Id,
            RoletaLeads__c = roleta1.Id,
            Posicao__c = 2,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert participante2;

        ParticipanteRoleta__c participante3 = new ParticipanteRoleta__c(
            Name = 'Luan',
            MembroEquipe__c = membro1.Id,
            RoletaLeads__c = roleta2.Id,
            Posicao__c = 3,
            UsuarioCorretor__c = corretor1.Id 
        );
        insert participante3;
    }

    @IsTest
    static void testRoletaSchedulerExecution() {
        // Obter IDs de roletas criadas no setup
        RoletaLeads__c roleta1 = [SELECT Id FROM RoletaLeads__c LIMIT 1];
        RoletaLeads__c roleta2 = [SELECT Id FROM RoletaLeads__c LIMIT 1 OFFSET 1];
        
        List<ParticipanteRoleta__c> participantesAntes = [SELECT Id FROM ParticipanteRoleta__c WHERE RoletaLeads__c = :roleta1.Id];
       // System.assertEquals(2, participantesAntes.size(), 'Deve haver dois participantes antes da execução do agendador.');

        RoletaScheduler scheduler = new RoletaScheduler(roleta1.Id);

        Test.startTest();
        scheduler.execute(null);
        Test.stopTest();

        List<ParticipanteRoleta__c> participantesDepois = [SELECT Id FROM ParticipanteRoleta__c WHERE RoletaLeads__c = :roleta2.Id];
     //   System.assertEquals(0, participantesDepois.size(), 'Não deve haver participantes após a execução do agendador.');
    }
}