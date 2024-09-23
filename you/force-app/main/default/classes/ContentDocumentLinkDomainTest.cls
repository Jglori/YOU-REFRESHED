@isTest
public class ContentDocumentLinkDomainTest {

    @isTest
    static void testObterLinkPorIdRegistroRelacionado() {
        // Criação de um ContentDocument (deve ser feito através de ContentVersion)
        // Criação de um ContentVersion associado ao ContentDocument
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Documento de Teste',
            PathOnClient = 'testfile.txt',
            VersionData = Blob.valueOf('Conteúdo do documento de teste'),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        // O ContentDocumentId será obtido a partir do ContentVersion
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
        
        // Criação de um registro fictício para associar ao ContentDocument
        Account account = new Account(Name = 'Conta de Teste');
        insert account;

        // Criação de um ContentDocumentLink associando o ContentDocument à conta
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = account.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert contentDocumentLink;

        // Teste do método obterLinkPorIdRegistroRelacionado
        Test.startTest();
        ContentDocumentLink result = ContentDocumentLinkDomain.obterLinkPorIdRegistroRelacionado(account.Id);
        Test.stopTest();

        // Verificações
        System.assertNotEquals(null, result, 'O ContentDocumentLink retornado não deve ser nulo');
        System.assertEquals(contentDocumentLink.Id, result.Id, 'O ID do ContentDocumentLink retornado deve ser o mesmo que o ID inserido');
        System.assertEquals(account.Id, result.LinkedEntityId, 'O ID da entidade vinculada deve ser o mesmo que o ID inserido');
    }
}