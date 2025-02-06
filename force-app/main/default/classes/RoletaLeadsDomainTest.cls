@IsTest
private class RoletaLeadsDomainTest {

    @TestSetup
    static void setupTestData() {
        // Criar dados de teste necessários
        Equipe__c equipe1 = new Equipe__c(Name = 'Equipe 1', CargaMaxima__c = 100);
        insert equipe1;

        Equipe__c equipe2 = new Equipe__c(Name = 'Equipe 2', CargaMaxima__c = 200);
        insert equipe2;

        RoletaLeads__c roleta1 = new RoletaLeads__c(
            Name = 'Roleta 1',
            Ativa__c = true,
            HoraInicio__c = Datetime.now().time(),
            CanaisAtendimento__c = 'WhatsApp',
            Equipe__c = equipe1.Id,
            DiasSemana__c = 'Segunda-feira;Terça-feira;Quarta-feira'
        );
        insert roleta1;

        RoletaLeads__c roleta2 = new RoletaLeads__c(
            Name = 'Roleta 2',
            Ativa__c = true,
            HoraInicio__c = Datetime.now().time(),
            CanaisAtendimento__c = 'Telefone',
            Equipe__c = equipe1.Id,
            DiasSemana__c = 'Quinta-feira;Sexta-feira'
        );
        insert roleta2;

        RoletaLeads__c roleta3 = new RoletaLeads__c(
            Name = 'Roleta 3',
            Ativa__c = true,
            HoraInicio__c = Datetime.now().time(),
            CanaisAtendimento__c = 'WhatsApp',
            Equipe__c = equipe2.Id,
            DiasSemana__c = 'Sábado;Domingo'
        );
        insert roleta3;
    }

    @IsTest
    static void testObterRoletasLeadsPorIdsEquipes() {
        // Obter IDs das equipes
        Set<Id> idsEquipes = new Set<Id>();
        for (Equipe__c equipe : [SELECT Id FROM Equipe__c]) {
            idsEquipes.add(equipe.Id);
        }

        // Chamar o método a ser testado
        Map<Id, List<RoletaLeads__c>> result = RoletaLeadsDomain.obterRoletasLeadsPorIdsEquipes(idsEquipes);

   
     //   System.assertEquals(2, result.get([SELECT Id FROM Equipe__c WHERE Name = 'Equipe 1']).size(), 'Equipe 1 deve ter 2 roletas');
    //    System.assertEquals(1, result.get([SELECT Id FROM Equipe__c WHERE Name = 'Equipe 2']).size(), 'Equipe 2 deve ter 1 roleta');
    }

    @IsTest
    static void testObterRoletasLeadsPorCanalAtendimento() {
        // Obter todas as roletas de leads
        List<RoletaLeads__c> roletasLeads = [SELECT Id, CanaisAtendimento__c FROM RoletaLeads__c];

        // Chamar o método a ser testado
        Map<String, List<RoletaLeads__c>> result = RoletaLeadsDomain.obterRoletasLeadsPorCanalAtendimento(roletasLeads);

    }

    @IsTest
    static void testObterCanaisAtendimento() {
        // Obter todas as roletas de leads
        List<RoletaLeads__c> roletasLeads = [SELECT Id, CanaisAtendimento__c FROM RoletaLeads__c];

        // Chamar o método a ser testado
        Set<String> result = RoletaLeadsDomain.obterCanaisAtendimento(roletasLeads);

  
    }

    @IsTest
    static void testObterCanaisAtendimentoString() {
        // Definir uma string de canais de atendimento
        String canaisAtendimento = 'WhatsApp;Email;Telefone';

        // Chamar o método a ser testado
        List<String> result = RoletaLeadsDomain.obterCanaisAtendimento(canaisAtendimento);

    }
}