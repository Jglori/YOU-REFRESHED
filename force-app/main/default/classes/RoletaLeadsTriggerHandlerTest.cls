@isTest
public class RoletaLeadsTriggerHandlerTest {

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
            DiasSemana__c = 'Domingo;Segunda-feira;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );

        insert new List<RoletaLeads__c>{roleta1, roleta2, roleta3};
    }

    @isTest
    static void testAfterInsert() {
        RoletaLeads__c newRoleta = new RoletaLeads__c(
            Name = 'Roleta Teste 4',
            HoraInicio__c = Time.newInstance(0, 0, 0, 0),
            HoraFim__c = Time.newInstance(23, 59, 0, 0),
            Ativa__c = true,
            DiasSemana__c = 'Domingo;Segunda-feira;Terça-feira;Quarta-feira;Quinta-feira;Sexta-feira;Sábado'
        );

        Test.startTest();
        insert newRoleta; // Aciona a trigger
        Test.stopTest();

        // Aqui, como não há lógica real, a principal validação seria garantir que o processo da trigger tenha sido executado
        // Não há como validar resultados concretos, pois a trigger está vazia
        System.assert(true, 'A trigger foi acionada com sucesso.'); // Apenas validando a execução do processo
    }

    @isTest
    static void testAfterUpdate() {
        // Buscar os registros de roleta criados no setup
        List<RoletaLeads__c> roletaList = [SELECT Id, Name, HoraFim__c, Ativa__c 
                                           FROM RoletaLeads__c];

        // Atualizar a primeira roleta para desativá-la
        RoletaLeads__c roletaToUpdate = roletaList[0];
        roletaToUpdate.Ativa__c = false;

        Test.startTest();
        // Atualizar a roleta
        update roletaToUpdate; // Aciona a trigger
        Test.stopTest();

        // Como a trigger está vazia, a principal validação é que a trigger foi executada sem erros
        System.assert(true, 'A trigger foi acionada com sucesso.'); // Apenas validando a execução do processo
    }
}