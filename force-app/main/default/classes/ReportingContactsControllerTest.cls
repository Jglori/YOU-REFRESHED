@IsTest
public class ReportingContactsControllerTest {

    @TestSetup
    static void setup(){
        Account acc1 = TestDataFactory.gerarConta();
        insert acc1;

        Account acc2 = TestDataFactory.gerarConta();
        insert acc2;

        Contact reportaSeCtt = TestDataFactory.gerarContato(acc2);
        insert reportaSeCtt;

        Contact ctt = TestDataFactory.gerarContato(acc1);
        ctt.Reporta_se_A__c = reportaSeCtt.Id;
        insert ctt;
    }

    @IsTest
    static void getReportingContactsTest() {
        Contact reportaSeCtt = [
            SELECT 
                Id, 
                Name, 
                AccountId, 
                account.name, 
                Email, 
                Reporta_se_A__c, 
                MobilePhone 
            FROM Contact 
            WHERE Reporta_se_A__c = null 
        ];

        Test.startTest();
        List<Contact> result = ReportingContactsController.getReportingContacts(reportaSeCtt.Id);
        Test.stopTest();

        List<Contact> expected = [
            SELECT 
                Id, 
                Name, 
                AccountId, 
                account.name, 
                Email, 
                Reporta_se_A__c, 
                MobilePhone 
            FROM Contact 
            WHERE Reporta_se_A__c = :reportaSeCtt.Id
        ];
        System.assertNotEquals(null, result, 'Resultado não pode ser null');
        System.assertEquals(expected.size(), result.size(), 'O resultado deveria ter 1 de tamanho');
        System.assertEquals(expected, result, 'Resultado não corresponde ao esperado');
    } 
}