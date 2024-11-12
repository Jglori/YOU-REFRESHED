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
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );

        insert new List<RoletaLeads__c>{roleta1, roleta2, roleta3};
    }

    @isTest
    static void testScheduleRoletaCleanUp() {
        // Buscar os registros de roleta criados no setup
        List<RoletaLeads__c> roletaList = [SELECT Id, Name, HoraFim__c, Ativa__c, DentroHorarioFuncionamento__c 
                                           FROM RoletaLeads__c];

       
        for (RoletaLeads__c roleta : roletaList) {
            System.debug('Roleta: ' + roleta.Name + ', DentroHorarioFuncionamento__c: ' + roleta.DentroHorarioFuncionamento__c);
        }

       
        System.assertEquals(3, roletaList.size(), 'A quantidade de registros de roleta criados deveria ser 3.');

        
        Test.startTest();
        RoletaLeadsHelper.scheduleRoletaCleanUp(roletaList);
        Test.stopTest();

        
        Integer scheduledJobsCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Limpar Participantes da Roleta%'];
        
    
    }
}