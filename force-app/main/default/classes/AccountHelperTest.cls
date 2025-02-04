@isTest
private class AccountHelperTest {
    @isTest
    static void cnpjValidoTest() {

        Account validAcc = TestDataFactory.gerarConta();
        validAcc.CNPJ__c = '';
        insert validAcc;

        validAcc.CNPJ__c = '37629040000107';
        Test.startTest();
        AccountHelper.verifyCNPJ(new List<Account>{validAcc});
        update validAcc;
        Test.stopTest();

       
    }

    @isTest
    static void cnpjInvalidoTest() {
        Account invalidAcc = TestDataFactory.gerarConta();
        invalidAcc.CNPJ__c = '85050402000153';
        insert invalidAcc;
    
        invalidAcc.CNPJ__c = '41768261000133';
    
        Test.startTest();
  
            update invalidAcc;
          //  System.assert(false, 'Esperava uma exceção devido ao CNPJ inválido na atualização.');
       
        Test.stopTest();
    }

    @isTest
    static void cnpjVazioInformadoTest() {
        Account emptyCnpjAcc = TestDataFactory.gerarConta();
        emptyCnpjAcc.CNPJ__c = '37629040000107';

        insert emptyCnpjAcc;

        emptyCnpjAcc.CNPJ__c = '';
    
        Test.startTest();
   
            update emptyCnpjAcc;
          
        Test.stopTest();
    }


    // TODO: vericar se essa logica de passar o cnpj vazio realmente é correto pq existe validaçao de campo obrigatorio e valido
    // @isTest
    // static void cnpjTamanhoIncorretoTest() {
    //     Account lenghtCnpjAcc = TestDataFactory.gerarContaPessoal();
    //     lenghtCnpjAcc.CNPJ__c = '';

    //     insert lenghtCnpjAcc;

    //     Test.startTest();

    //     try {
    //         AccountHelper.verifyCNPJ(new List<Account>{lenghtCnpjAcc});
    //     } catch (DmlException e) {
    //         System.assertEquals('CNPJ inválido. Por favor, insira um CNPJ válido.', e.getMessage());
    //     }
    //     Test.stopTest();
    // }
}