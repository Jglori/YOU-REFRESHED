@isTest
public class ContentDocumentLinkSelectorTest {

    @isTest
    static void testObterLinksPorIdsRegistrosRelacionados() {


        // Criar um ContentVersion de teste
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Arquivo de Teste',
            PathOnClient = 'testfile.txt',
            VersionData = Blob.valueOf('Conteúdo do arquivo de teste'),
            IsMajorVersion = true
        );
        insert contentVersion;

        // Criar um ContentDocument para o ContentVersion
        ContentDocument contentDocument = [
            SELECT Id 
            FROM ContentDocument 
            LIMIT 1
        ];

        // Criar um registro de teste para vincular com ContentDocument
        Account testAccount = new Account(Name = 'Conta de Teste');
        insert testAccount;

        // Criar ContentDocumentLink para vincular o ContentDocument à conta
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = contentDocument.Id,
            LinkedEntityId = testAccount.Id,
            ShareType = 'V',  // "V" para Visualizar, dependendo do seu contexto
            Visibility = 'AllUsers'
        );
        insert contentDocumentLink;

        // Chamar o método obterLinksPorIdsRegistrosRelacionados
        Set<Id> idsRegistrosRelacionados = new Set<Id>{testAccount.Id};
        Test.startTest();
        List<ContentDocumentLink> links = ContentDocumentLinkSelector.obterLinksPorIdsRegistrosRelacionados(idsRegistrosRelacionados);
        Test.stopTest();

        // Verificar os resultados
        System.assertEquals(1, links.size(), 'Deveria haver exatamente 1 ContentDocumentLink');
        ContentDocumentLink link = links[0];
        System.assertEquals(contentDocument.Id, link.ContentDocumentId, 'O ContentDocumentId deve corresponder ao ID do ContentDocument');
        System.assertEquals(testAccount.Id, link.LinkedEntityId, 'O LinkedEntityId deve corresponder ao ID da conta');
        System.assertNotEquals(null, link.ContentDocument.LatestPublishedVersionId, 'O LatestPublishedVersionId não deve ser nulo');
    }
}