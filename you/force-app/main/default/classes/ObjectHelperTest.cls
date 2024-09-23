@isTest
private class ObjectHelperTest {
    
    @TestSetup
    static void makeData(){
        doMakeData();
    }

    private static void doMakeData(){
        Empreendimento__c empreendimento = new Empreendimento__c();
        empreendimento.Name = 'Empreendimento de Teste';
        empreendimento.CNPJEmpreendimento__c = '22416340000130';
        insert empreendimento;

        

        insert new Lead(
                LastName = 'Zika',
                Company = 'Chave',
                Status = 'Novo',
                Email = 't@g.com',
                CanalAtendimento__c = 'Loja',
                EmpreendimentoInteresse__c = empreendimento.Id
            );
    }

    @isTest
    private static void getLookUpId(){
        Empreendimento__c empreendimento = [SELECT Id FROM Empreendimento__c LIMIT 1].get(0);
        List<Lead> leads = [SELECT Id, EmpreendimentoInteresse__c FROM Lead];

        Set<Id> empreendimentosId = new Set<Id>();

        Test.startTest();

        empreendimentosId = ObjectHelper.getLookUpId(leads, 'EmpreendimentoInteresse__c');

        Test.stopTest();

        Assert.isTrue(empreendimentosId.contains(empreendimento.Id));
    }
}