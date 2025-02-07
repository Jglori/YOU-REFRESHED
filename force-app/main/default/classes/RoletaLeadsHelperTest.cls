@isTest
public class RoletaLeadsHelperTest {
    
    @testSetup
    static void setup() {
        // Configuração das roletas com horários que garantem estar dentro do horário de funcionamento
        RoletaLeads__c roleta1 = new RoletaLeads__c(
            Name = 'Roleta Teste 1',
            HoraInicio__c = Time.newInstance(0, 0, 0, 0),
            HoraFim__c = Time.newInstance(23, 59, 0, 0),
            Ativa__c = true,
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );

        RoletaLeads__c roleta2 = new RoletaLeads__c(
            Name = 'Roleta Teste 2',
            HoraInicio__c = Time.newInstance(0, 0, 0, 0),
            HoraFim__c = Time.newInstance(23, 59, 0, 0),
            Ativa__c = true,
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );

        // Roleta inativa, que não deverá ter job agendado
        RoletaLeads__c roleta3 = new RoletaLeads__c(
            Name = 'Roleta Teste 3',
            HoraInicio__c = Time.newInstance(0, 0, 0, 0),
            HoraFim__c = Time.newInstance(23, 59, 0, 0),
            Ativa__c = false,
            DiasSemana__c = 'Domingo;Segunda-feira;Segunda-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );

        // Inserção das roletas
        insert new List<RoletaLeads__c>{roleta1, roleta2, roleta3};

        // Criação do lead de teste associado à primeira roleta
        Lead testLead = new Lead(
            LastName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'silva@xyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '5511987654321',
            Status = 'Novo',
            RoletaLeads__c = roleta1.Id
        );
        insert testLead;
    }

   
    
    @isTest
    static void testLeadsBolsao() {
        // Buscar os registros de roleta criados no setup
        List<RoletaLeads__c> roletaList = [SELECT Id, HoraInicio__c FROM RoletaLeads__c WHERE Ativa__c = true];

        // Verificar se foram criadas 2 roletas ativas
        System.assertEquals(2, roletaList.size(), 'A quantidade de registros de roleta ativas deveria ser 2.');

        // Iniciar o teste
        Test.startTest();
        RoletaLeadsHelper.LeadsBolsao(roletaList);
        Test.stopTest();

        // Verificar se os jobs foram agendados
        Integer scheduledJobsCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Bolsao de Leads da Roleta%'];
    }
    
    @isTest
    static void testLeadsBolsaoHorarioAgendado() {
        // Buscar os registros de roleta criados no setup
        List<RoletaLeads__c> roletaList = [SELECT Id, HoraInicio__c FROM RoletaLeads__c WHERE Ativa__c = true];
        
        // Definir um horário de início para o agendamento
        Time horaInicio = Time.newInstance(10, 0, 0, 0);

        // Iniciar o teste
        Test.startTest();
        RoletaLeadsHelper.LeadsBolsaoHorarioAgendado(roletaList, horaInicio);
        Test.stopTest();

        // Verificar se os jobs foram agendados
        Integer scheduledJobsCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Bolsao de Leads da Roleta%'];
    }
}