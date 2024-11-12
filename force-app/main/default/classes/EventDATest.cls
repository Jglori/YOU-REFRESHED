@IsTest
public class EventDATest {
    @TestSetup
    static void setup() {
        // Criar Empreendimento de teste
        Empreendimento__c empreendimento = new Empreendimento__c();
        empreendimento.Name = 'Teste empreendimento';
        empreendimento.CNPJEmpreendimento__c = '12345678000195'; // Substitua por um CNPJ válido
        insert empreendimento;

        // Criar Lead de teste
        Lead testLead = new Lead(
            LastName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'silva@xyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '5511987654321',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id
        );
        insert testLead;

        // Criar Eventos de teste associados ao Lead
        List<Event> events = new List<Event>();

        // Evento que corresponde aos critérios da consulta
        events.add(new Event(
            Subject = 'Visita',
            idLead__c = testLead.Id,
            Status_do_Compromisso__c = 'Realizada com Sucesso',
            DurationInMinutes = 30,
            ActivityDateTime = Datetime.now().addDays(-1)
        ));
        
        // Evento que não corresponde aos critérios da consulta
        events.add(new Event(
            Subject = 'Outra Coisa',
            idLead__c = testLead.Id,
            Status_do_Compromisso__c = 'Realizada com Sucesso',
            DurationInMinutes = 30,
            ActivityDateTime = Datetime.now().addDays(-1)
        ));

        events.add(new Event(
            Subject = 'Visita',
            idLead__c = testLead.Id,
            Status_do_Compromisso__c = 'Não Realizada',
            DurationInMinutes = 30,
            ActivityDateTime = Datetime.now().addDays(-1)
        ));

        insert events;
    }

    @IsTest
    static void testGetAllEventByLead() {
        // Recuperar o Lead de teste
        Lead testLead = [SELECT Id FROM Lead WHERE Email = 'silva@xyz.com' LIMIT 1];

        // Chamar o método a ser testado
        List<Event> events = EventDA.getAllEventByLead(testLead.Id);

        // Verificar os resultados
        System.assertNotEquals(null, events, 'A lista de eventos não deve ser nula');
        System.assertEquals(1, events.size(), 'Deve haver 1 evento que corresponde aos critérios');

        // Verificar os detalhes do evento recuperado
        Event event = events[0];
        System.assertEquals('Visita', event.Subject, 'O assunto do evento deve ser "Visita"');
        System.assertEquals('Realizada com Sucesso', event.Status_do_Compromisso__c, 'O status do compromisso deve ser "Realizada com Sucesso"');
    }
}