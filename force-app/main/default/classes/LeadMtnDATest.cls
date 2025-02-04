@isTest
private class LeadMtnDATest {
    @testSetup
    static void setupTestData() {
        Empreendimento__c empreendimento = new Empreendimento__c();  
        empreendimento.Name = 'Teste empreendimento';  
        empreendimento.CNPJEmpreendimento__c = '12345678000195';  
        insert empreendimento;

        Lead testLead = new Lead(
            LastName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'silva@xyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '5511987654321',
            EmailAdicional__c = 'silva.adicional@xyz.com',
            CelularAdicional__c = '11912345678',
            CelularAdicional1__c = '11923456789',
            CelularAdicional2__c = '11934567890',
            CelularComercialAdicional__c = '11945678901',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;
    }

    @isTest
    static void testBuscarPorEmail() {
        Test.startTest();
        Id leadId = LeadMtnDA.obterLeadExistente('silva@xyz.com', null);
        Test.stopTest();
        System.assertNotEquals(null, leadId, 'O Lead deve ser encontrado pelo email.');
    }

    @isTest
    static void testBuscarPorCelular() {
        Test.startTest();
        Id leadId = LeadMtnDA.obterLeadExistente(null, '5511987654321');
        Test.stopTest();
        System.assertNotEquals(null, leadId, 'O Lead deve ser encontrado pelo celular.');
    }

    @isTest
    static void testBuscarPorCelularAdicional() {
        Test.startTest();
        Id leadId = LeadMtnDA.obterLeadExistente(null, '11912345678');
        Test.stopTest();
        System.assertNotEquals(null, leadId, 'O Lead deve ser encontrado pelo celular adicional.');
    }

    @isTest
    static void testBuscarPorEmailECell() {
        Test.startTest();
        Id leadId = LeadMtnDA.obterLeadExistente('silva@xyz.com', '5511987654321');
        Test.stopTest();
        System.assertNotEquals(null, leadId, 'O Lead deve ser encontrado pelo email e celular.');
    }

    @isTest
    static void testNenhumParametro() {
        Test.startTest();
        Id leadId = LeadMtnDA.obterLeadExistente(null, null);
        Test.stopTest();
        System.assertEquals(null, leadId, 'Nenhum Lead deve ser encontrado sem parâmetros.');
    }

    @isTest
    static void testLeadNaoEncontrado() {
        Test.startTest();
        Id leadId = LeadMtnDA.obterLeadExistente('naoexiste@xyz.com', '5500000000000');
        Test.stopTest();
        System.assertEquals(null, leadId, 'Nenhum Lead deve ser encontrado para email e celular inexistentes.');
    }
}