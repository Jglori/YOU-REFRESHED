@IsTest
public class ContractTriggerHandlerTest {

    @TestSetup
    static void setupData() {
        Account acc = new Account(Name = 'Conta Teste', CNPJ__c = '11084433000199');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Oportunidade de Teste',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;

        Contract contract1 = new Contract(
            Status = 'Rascunho',
            Oportunidade__c = opp.Id,
            AccountId = acc.Id
        );
        Contract contract2 = new Contract(
            Status = 'Rascunho',
            Oportunidade__c = opp.Id,
            AccountId = acc.Id
        );
        insert new List<Contract>{ contract1, contract2 };
    }

    @IsTest
    static void testEvitarGeracaoMultipla() {
        List<Contract> contracts = [
            SELECT Id, Status, Oportunidade__c
            FROM Contract
            WHERE Status = 'Rascunho'
        ];

        contracts[0].Status = 'Contrato Gerado';
        update contracts[0];

        contracts[1].Status = 'Contrato Gerado';
        Test.startTest();
        try {
            update contracts[1];
            System.assert(false, 'Deveria ter ocorrido uma exceção devido ao addError.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Já existe um contrato gerado para oportunidade deste contrato'), 
                'A exceção deveria conter a mensagem do addError.');
        }
        Test.stopTest();
    }
}