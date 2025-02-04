public class LeadMtnHelper {
    public static void criarLeads(List<Lead_MTN__c> leads) {
        List<Lead> leadsParaAtualizar = new List<Lead>();
        List<Lead> leadsParaInserir = new List<Lead>();
        List<Task> tasksParaInserir = new List<Task>();
        
        Id pessoaFisicaRecordTypeId;
        Id pessoaJuridicaRecordTypeId;
        
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Lead' AND Name IN ('Pessoa Física', 'Pessoa Jurídica')]) {
            recordTypeMap.put(rt.Name, rt.Id);
        }
        pessoaFisicaRecordTypeId = recordTypeMap.get('Pessoa Física');
        pessoaJuridicaRecordTypeId = recordTypeMap.get('Pessoa Jurídica');
        
        for (Lead_MTN__c leadMTN : leads) {
            if (leadMTN.Tipo_Pessoa__c != null) {
                Id leadExistenteId = LeadMtnDA.obterLeadExistente(leadMTN.Email__c, leadMTN.MobilePhone__c);
                
                if (leadExistenteId != null) { Lead leadReiterado = [SELECT Id, QuantidadeDeReiteracoes__c, ltima_Reitera_o__c, EmpreendimentoInteresse__c, MobilePhone, Email, Phone, CanalAtendimento__c, LeadSource, Informacoes_Adicionais__c, SubProduto__c, FirstName, LastName FROM Lead WHERE Id = :leadExistenteId LIMIT 1]; leadReiterado.QuantidadeDeReiteracoes__c = (leadReiterado.QuantidadeDeReiteracoes__c != null) ? leadReiterado.QuantidadeDeReiteracoes__c + 1 : 1; leadReiterado.ltima_Reitera_o__c = Datetime.now(); leadReiterado.EmpreendimentoInteresse__c = leadMTN.Empreendimento__c; leadReiterado.MobilePhone = leadMTN.MobilePhone__c; leadReiterado.Email = leadMTN.Email__c; leadReiterado.Phone = leadMTN.Telefone__c; leadReiterado.CanalAtendimento__c = leadMTN.Canal_de_Atendimento__c; leadReiterado.LeadSource = leadMTN.Origem_Lead__c; leadReiterado.Informacoes_Adicionais__c = leadMTN.Informacoes_Adicionais__c; leadReiterado.SubProduto__c = leadMTN.SubProduto__c; leadsParaAtualizar.add(leadReiterado); Task tarefaReiteracao = new Task(WhoId = leadExistenteId, Subject = 'Reiteração', Status = 'Open', ActivityDate = Date.today().addDays(1), Telefone__c = leadMTN.Telefone__c, Nome_do_Lead__c = leadMTN.Last_Name__c, Celular__c = leadMTN.MobilePhone__c, Origem_do_Lead__c = leadMTN.Origem_Lead__c, Canal_de_Atendimento__c = leadMTN.Canal_de_Atendimento__c, Informacoes_Adicionais__c = leadMTN.Informacoes_Adicionais__c); tasksParaInserir.add(tarefaReiteracao);}
else { 
                    Lead novoLead = new Lead(
                        SubProduto__c = leadMTN.SubProduto__c,
                        Email = leadMTN.Email__c,
                        LeadSource = leadMTN.Origem_Lead__c,
                        CanalAtendimento__c = leadMTN.Canal_de_Atendimento__c,
                        Informacoes_Adicionais__c = leadMTN.Informacoes_Adicionais__c,
                        EmpreendimentoInteresse__c = leadMTN.Empreendimento__c,
                        Phone = leadMTN.Telefone__c,
                        MobilePhone = leadMTN.MobilePhone__c,
                        RazaoSocial__c = leadMTN.Razao_Social__c,
                        RoletaLeads__c = leadMTN.Roleta_de_leads__c,
                        Status = leadMTN.Status__c,
                        OwnerId = leadMTN.OwnerId,
                        FirstName = leadMTN.First_Name__c,
                        LastName = leadMTN.Last_Name__c,
                        Data_Iteracao_MTN__c = leadMTN.Data_Iteracao_MTN__c,
                        RecordTypeId = leadMTN.Tipo_Pessoa__c == 'Pessoa Física' ? pessoaFisicaRecordTypeId : pessoaJuridicaRecordTypeId
                    );
                    leadsParaInserir.add(novoLead);
                }
            }
        }
        
        if (!leadsParaAtualizar.isEmpty()) {
            update leadsParaAtualizar;
        }
        if (!leadsParaInserir.isEmpty()) {
            insert leadsParaInserir;
        }
        if (!tasksParaInserir.isEmpty()) {
            insert tasksParaInserir;
        }
    }
    

    
  
}