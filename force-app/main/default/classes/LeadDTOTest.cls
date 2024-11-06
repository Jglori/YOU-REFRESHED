@isTest
private class LeadDTOTest {
    @isTest
    static void testLeadDTO() {
        Lead lead = new Lead(
            LastName = 'Teste',
            FirstName = 'Nome',
            Email = 'teste@exemplo.com',
            MobilePhone = '11999999999',
            Status = 'Novo',
            ChaveExternaWhatsApp__c = '123456',
            InicioDialogo__c = DateTime.now(),
            FimDialogo__c = DateTime.now().addHours(1),
            UltimaMensagem__c = DateTime.now(),
            Phone = '11222222222',
            OwnerId = UserInfo.getUserId()
        );
        insert lead;

        LeadDTO leadDTO = new LeadDTO(lead);

        System.assertEquals(lead.Id, leadDTO.id);
        System.assertEquals(lead.ChaveExternaWhatsApp__c, leadDTO.chaveExternaWhatsApp);
        System.assertEquals(lead.Name, leadDTO.nome);
        System.assertEquals(lead.FirstName, leadDTO.primeiroNome);
        System.assertEquals(lead.LastName, leadDTO.sobrenome);
        System.assertEquals(lead.Email, leadDTO.email);
        System.assertEquals(lead.MobilePhone, leadDTO.celular);
        System.assertEquals(lead.Status, leadDTO.status);
        System.assertEquals(lead.Owner.Name, leadDTO.proprietario);
        System.assertEquals(lead.InicioDialogo__c, leadDTO.inicioDialogo);
        System.assertEquals(lead.FimDialogo__c, leadDTO.fimDialogo);
        System.assertEquals(lead.UltimaMensagem__c, leadDTO.ultimaMensagem);
        System.assertEquals(lead.CreatedDate, leadDTO.CreatedDate);
        System.assertEquals(lead.Phone, leadDTO.telefone);
    }

    @isTest
    static void testLeadDTOWithConfiguracaoCanalAtendimento() {
        Lead lead = new Lead(
            LastName = 'Teste',
            FirstName = 'Nome',
            Email = 'teste@exemplo.com',
            MobilePhone = '11999999999',
            Status = 'Novo',
            ChaveExternaWhatsApp__c = '123456',
            InicioDialogo__c = DateTime.now(),
            FimDialogo__c = DateTime.now().addHours(1),
            UltimaMensagem__c = DateTime.now(),
            Phone = '11222222222',
            OwnerId = UserInfo.getUserId()
        );
        insert lead;

        ConfiguracaoCanalAtendimento__mdt configuracao = new ConfiguracaoCanalAtendimento__mdt(
            Label = 'Config',
            Carga__c = 100,
            Bypass__c = false
        );

        LeadDTO leadDTO = new LeadDTO(lead, configuracao);

        System.assertEquals(100, leadDTO.carga);
        System.assertEquals(null, leadDTO.cargaRestante); // Altere conforme a lógica desejada
        System.assertEquals(false, leadDTO.naoPodeAceitar);
    }
}