@isTest
public class LeadMtnHelperTest {
    
    @testSetup
    static void setup() {
        // Criar um Empreendimento para referência nos Leads
        Empreendimento__c empreendimento = new Empreendimento__c(
            Name = 'Teste empreendimento',
            CNPJEmpreendimento__c = '12345678000195'
        );
        insert empreendimento;

        // Buscar RecordType IDs para Lead
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Lead' AND Name IN ('Pessoa Física', 'Pessoa Jurídica')]) {
            recordTypeMap.put(rt.Name, rt.Id);
        }
        
        // Criar um Lead de teste
        Lead testLead = new Lead(
            LastName = 'Silva',
            Company = 'Empresa XYZ',
            Email = 'silva@xyz.com',
            LeadSource = 'Chat',
            CanalAtendimento__c = 'Telefone',
            MobilePhone = '5511987654321',
            Status = 'Novo',
            EmpreendimentoInteresse__c = empreendimento.Id,
            RecordTypeId = recordTypeMap.get('Pessoa Física') // Usando o RecordType recuperado
        );
        insert testLead;
    }
    
    @isTest
    static void testCriarLeads() {
        // Criar um Lead_MTN__c de teste
        // 
        Id ownerId = [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 1].Id;
        Lead_MTN__c leadMTN = new Lead_MTN__c(
            Email__c = 'teste@exemplo.com',
            MobilePhone__c = '5511988887777',
            Telefone__c = '1122334455',
            Canal_de_Atendimento__c = 'WhatsApp',
            Origem_Lead__c = 'Anúncio',
            Informacoes_Adicionais__c = 'Interessado no produto',
            SubProduto__c = 'Park Mariana Life by You,inc',
            Empreendimento__c = [SELECT Id FROM Empreendimento__c LIMIT 1].Id,
            First_Name__c = 'Carlos',
            Last_Name__c = 'Pereira',
            Tipo_Pessoa__c = 'Pessoa Física',
            OwnerId = ownerId
        );

        Test.startTest();
        LeadMtnHelper.criarLeads(new List<Lead_MTN__c>{leadMTN});
        Test.stopTest();
        
        // Verificar se o Lead foi criado
        Lead createdLead = [SELECT Id FROM Lead WHERE Email = :leadMTN.Email__c LIMIT 1];
        System.assertNotEquals(null, createdLead, 'Lead deveria ter sido criado.');
    }
}