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
    static void testbeforeUpdate() {
        Contract ctrs = [
            SELECT Id, Status FROM Contract LIMIT 1
        ];
        ctrs.Status = 'ContratoGerado';

        update ctrs;
    }
}