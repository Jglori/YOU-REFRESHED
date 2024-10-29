@isTest
private class SorteioControllerTest {

    @isTest
    static void testExecutarSorteioFlow() {
        Test.startTest();

        List<String> dummyParam = new List<String>();

        SorteioController.executarSorteioFlow(dummyParam);
        Test.stopTest();

    }
}