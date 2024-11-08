@isTest
public class DocumentacaoHelperTest {
    
	@TestSetup
    static void setup() {
		Documentacao__c doc = TestDataFactory.gerarDocumentacao();
        insert doc;
        
       	Opportunity opp = TestDataFactory.gerarOportunidade();
		opp.StageName = 'Pré-análise';
        insert opp;
        
        AnaliseCredito__c analise = TestDataFactory.gerarAnaliseCredito(opp);
        insert analise;
        
        Checklist_de_Documentos__c checklists = TestDataFactory.gerarChecklistDocumentos(opp, doc);
        insert checklists;
    }
    
    @IsTest
    static void testCriarDocumentacao() {
        String nomeDocumento = 'Dock Test';
        
        Test.startTest();
        DocumentacaoHelper.criarDocumentacao(nomeDocumento);
        Test.stopTest();
        
        Documentacao__c doc = [
            SELECT Id, Name
            FROM Documentacao__c
            WHERE Name = 'Dock Test'
        ];
        
        System.assertNotEquals(null, doc, 'Deveria existir um Documento salvo.');
        System.assertEquals(nomeDocumento, doc.Name, 'Deveria existir uma Documentação com o nome "Dock Test".');
    }
    
    @IsTest
    static void testGetByAnaliseCreditoValidate() {
        AnaliseCredito__c analise = [
            SELECT Id
            FROM AnaliseCredito__c
        ];
        
        Test.startTest();
        List<Documentacao__c> docs = DocumentacaoHelper.getByAnaliseCredito(analise.Id);
        Test.stopTest();
        
        List<Documentacao__c> expected = [
            SELECT Id, Name, Validado__c, Obrigatorio__c, Entregue__c 
        	FROM Documentacao__c
        ];
		
        System.assertEquals(expected, docs, 'Deveria retornar uma lista de Documentos.');
    }
    
    @IsTest
    static void testValidateDocuments() {
        Documentacao__c doc = [
            SELECT Id, Validado__c
            FROM Documentacao__c
        ];
        doc.Validado__c = false;
        update doc; 
        
        Test.startTest();
        List<Documentacao__c> docs = DocumentacaoHelper.validateDocuments(new Set<Id>{ doc.Id });
        Test.stopTest();
        
        List<Documentacao__c> expected = [
            SELECT Id, Name, Contato__c, ContentDocumentId_c__c, Entregue__c, Validado__c
        	FROM Documentacao__c
        ];
		
        System.assertEquals(expected, docs, 'Deveria retornar uma lista de Documentos válidos.');
    }
    
    @IsTest
    static void testInvalidateDocuments() {
        Documentacao__c doc = [
            SELECT Id, Validado__c
            FROM Documentacao__c
        ];
        doc.Validado__c = true;
        update doc; 
        
        Test.startTest();
        List<Documentacao__c> docs = DocumentacaoHelper.invalidateDocuments(new Set<Id>{ doc.Id });
        Test.stopTest();
        
        List<Documentacao__c> expected = [
            SELECT Id, Name, Contato__c, ContentDocumentId_c__c, Entregue__c, Validado__c
        	FROM Documentacao__c
        ];
		
        System.assertEquals(expected, docs, 'Deveria retornar uma lista de Documentos inválidos.');
    }
    
}