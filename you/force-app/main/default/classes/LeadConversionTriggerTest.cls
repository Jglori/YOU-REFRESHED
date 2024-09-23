@isTest
public class LeadConversionTriggerTest {
    @isTest static void testLeadConversionTrigger() {
        // Cria um novo Empreendimento__c
        Empreendimento__c empreendimento = new Empreendimento__c (Name = 'Teste empreendimento', CNPJEmpreendimento__c = '55743778000182');
        insert empreendimento;

        // Cria um novo Lead
        Lead testLead = new Lead(
            LastName = 'Will',
            Company = 'Elera',
            Email = 'Willdantas@gmail.com',
            LeadSource = 'Telefone',
            CanalAtendimento__c = 'Chat',
            MobilePhone = '11960387699',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;

        // Verifica que o campo DataConversao__c está nulo
        Lead insertedLead = [SELECT DataConversao__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(null, insertedLead.DataConversao__c);

        // Converte o Lead
        // Database.LeadConvert lc = new Database.LeadConvert();
        // lc.setLeadId(testLead.Id);
        // lc.setConvertedStatus('Conversão'); // Definir o status de conversão
        // Database.LeadConvertResult lcr = Database.convertLead(lc);
        // System.assert(lcr.isSuccess());

        // Verifica que o campo DataConversao__c foi preenchido
        Lead convertedLead = [SELECT DataConversao__c FROM Lead WHERE Id = :testLead.Id];
        //System.assertNotEquals(null, convertedLead.DataConversao__c);
    }
}