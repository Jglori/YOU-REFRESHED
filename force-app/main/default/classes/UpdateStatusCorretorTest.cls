@isTest
public class UpdateStatusCorretorTest {

    @isTest
    static void testUpdateStatusCorretor() {
        Contact contact1 = new Contact(LastName = 'Teste1', StatusUsuarioCorretor__c = 'Congelado' , CPF__c = '54092472056');
        insert contact1;
        contact1 = [SELECT StatusCorretor__c FROM Contact WHERE Id = :contact1.Id];

        Contact contact2 = new Contact(LastName = 'Teste2', StatusUsuarioCorretor__c = 'Desativado' , CPF__c = '83519292041');
        insert contact2;
        contact2 = [SELECT StatusCorretor__c FROM Contact WHERE Id = :contact2.Id];

        Contact contact3 = new Contact(LastName = 'Teste3', StatusUsuarioCorretor__c = 'Ativo' , CPF__c = '75644131076');
        insert contact3;
        contact3 = [SELECT StatusCorretor__c FROM Contact WHERE Id = :contact3.Id];

        contact3.StatusUsuarioCorretor__c = 'Congelado';
        update contact3;
        contact3 = [SELECT StatusCorretor__c FROM Contact WHERE Id = :contact3.Id];

        contact3.StatusUsuarioCorretor__c = 'Desativado';
        update contact3;
        contact3 = [SELECT StatusCorretor__c FROM Contact WHERE Id = :contact3.Id];
    }
}