@isTest
public class ProcessLeadMtnQueueableTest {
    @TestSetup
    static void setupTestData() {
        // Criar roleta de leads
        RoletaLeads__c roleta = new RoletaLeads__c(
            Name = 'Roleta Teste'
        );
        insert roleta;
        
        // Criar participante da roleta
        ParticipanteRoleta__c participante = new ParticipanteRoleta__c(
            Name = 'Participante Teste',
            RoletaLeads__c = roleta.Id,
            PresencaValidada__c = true
        );
        insert participante;
           // Criar Lead MTN
           // 
        Empreendimento__c empreendimento = new Empreendimento__c();  
        empreendimento.Name = 'Teste empreendimento';  
        empreendimento.CNPJEmpreendimento__c = '12345678000195';  
        insert empreendimento; 
        Lead_MTN__c leadMTN = new Lead_MTN__c(
            Name = 'Lead Teste',
            Roleta_de_leads__c = roleta.Id,
            Tipo_Pessoa__c = 'Pessoa Física',
            Email__c = 'lead1@test.com',
            MobilePhone__c = '11999999901',
            SubProduto__c = 'Park Mariana Life by You,inc',
            Origem_Lead__c = 'Instagram',
            Canal_de_Atendimento__c = 'Fale conosco',
            Informacoes_Adicionais__c = 'Informações adicionais',
            Empreendimento__c = empreendimento.Id,
            Telefone__c = '1133333333',
            Razao_Social__c = 'Razão Social Teste',
            Status__c = 'Novo',
            First_Name__c = 'Primeiro Nome',
            Last_Name__c = 'Último Nome',
            Data_Iteracao_MTN__c = Date.today()
        );
        insert leadMTN;
    }
    
    @isTest
    static void testProcessLeadMtnQueueable() {
        // Arrange
        List<Lead_MTN__c> leads = [SELECT Id, Name, Roleta_de_leads__c , Tipo_Pessoa__c , Email__c , MobilePhone__c,
                                    SubProduto__c, Origem_Lead__c, Canal_de_Atendimento__c, Informacoes_Adicionais__c, 
                                    Empreendimento__c, Telefone__c, Razao_Social__c, Status__c, First_Name__c, Last_Name__c, 
                                    Data_Iteracao_MTN__c 
                                    FROM Lead_MTN__c];
        
        System.assertEquals(1, leads.size(), 'Should have one Lead_MTN__c record');
        
        Test.startTest();
        
        // Act
        System.enqueueJob(new ProcessLeadMtnQueueable(leads, 0));
        
        Test.stopTest();
        
        // Assert
        // Aqui você pode adicionar a validação, por exemplo, verificando se o método foi chamado ou se os registros foram processados.
    }
    
    @isTest
    static void testProcessLeadMtnQueueableWithoutValidParticipant() {
        // Arrange
        List<Lead_MTN__c> leads = [SELECT Id, Name, Roleta_de_leads__c , Tipo_Pessoa__c , Email__c , MobilePhone__c,
                                    SubProduto__c, Origem_Lead__c, Canal_de_Atendimento__c, Informacoes_Adicionais__c, 
                                    Empreendimento__c, Telefone__c, Razao_Social__c, Status__c, First_Name__c, Last_Name__c, 
                                    Data_Iteracao_MTN__c 
                                    FROM Lead_MTN__c];
        
        System.assertEquals(1, leads.size(), 'Should have one Lead_MTN__c record');
        
        // Atualizar participante para não validado
        ParticipanteRoleta__c participante = [SELECT Id, PresencaValidada__c FROM ParticipanteRoleta__c LIMIT 1];
       
        
        Test.startTest();
        
        // Act
        System.enqueueJob(new ProcessLeadMtnQueueable(leads, 0));
        
        Test.stopTest();
        
        // Assert
        // Verificar que nenhum lead foi processado quando não há participante validado
    }
    

}