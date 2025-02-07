@IsTest
public with sharing class AnaliseCreditoTriggerHandlerTest {
    
    @TestSetup
    static void setup() {
        // Criando um Account
        Account accTest = new Account(
            Name = 'Conta Teste',
            EmailJuridico__c = 'teste.@elera.io'
        );
        insert accTest;
        
        // Criando uma Opportunity
        Opportunity opp1 = new Opportunity(
            Name = 'Teste',
            Amount = 1000,
            CanalAtendimento__c = 'WhatsApp',
            Probability = 20,
            TipoVenda__c = 'Negócio novo',
            StageName = 'Pré-análise',
            CloseDate = System.today().addDays(15),
            AccountId = accTest.Id
        );
        insert opp1;

        // Criando um Documento
        Documentacao__c doc = new Documentacao__c(
            Name = 'Documento test',
            Obrigatorio__c = true,
            Entregue__c = false,
            Validado__c = false
        );
        insert doc;

        // Criando um Checklist de Documentos
        Checklist_de_Documentos__c checklists = new Checklist_de_Documentos__c(
            Oportunidade__c = opp1.Id,
            Documenta_o__c = doc.Id
        );
        insert checklists;
    }
    
    @IsTest
    static void testBeforeInsert() {
        Opportunity oppTest = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        
        AnaliseCredito__c analise1 = gerarAnaliseCredito(oppTest.Id);
        AnaliseCredito__c analise2 = gerarAnaliseCredito(oppTest.Id);
        analise2.Status__c = 'Aprovada';
        
        Test.startTest();
        insert new List<AnaliseCredito__c>{ analise1, analise2 };
        Test.stopTest();
    }

    @IsTest
    static void testBeforeUpdate() {
        Opportunity oppTest = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        
        AnaliseCredito__c analise1 = gerarAnaliseCredito(oppTest.Id);
        AnaliseCredito__c analise2 = gerarAnaliseCredito(oppTest.Id);
        insert new List<AnaliseCredito__c>{ analise1, analise2 };

        analise1.Status__c = 'Aprovada';
        analise2.Name = 'SIRRRRR';

        Test.startTest();
        update new List<AnaliseCredito__c>{ analise1, analise2 };
        Test.stopTest();
    }

    @IsTest
    static void testAfterInsert() {
        Opportunity oppTest = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        
        AnaliseCredito__c analise1 = gerarAnaliseCredito(oppTest.Id);
        AnaliseCredito__c analise2 = gerarAnaliseCredito(oppTest.Id);
        
        Test.startTest();
        insert new List<AnaliseCredito__c>{ analise1, analise2 };
        Test.stopTest();
    }

    @IsTest
    static void testAfterUpdate() {
        Opportunity oppTest = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        
        AnaliseCredito__c analise1 = gerarAnaliseCredito(oppTest.Id);
        AnaliseCredito__c analise2 = gerarAnaliseCredito(oppTest.Id);
        insert new List<AnaliseCredito__c>{ analise1, analise2 };

        analise1.Status__c = 'Aprovada';
        analise2.Name = 'SIRRRRR';

        Test.startTest();
        update new List<AnaliseCredito__c>{ analise1, analise2 };
        Test.stopTest();
    }

    // Método auxiliar para gerar AnaliseCredito
    private static AnaliseCredito__c gerarAnaliseCredito(Id oppId) {
        return new AnaliseCredito__c(
            Name = 'Teste',
            Status__c = 'Em Análise',
            Opportunity__c = oppId,
            DataVencimento__c = Date.today()
        );
    }
}