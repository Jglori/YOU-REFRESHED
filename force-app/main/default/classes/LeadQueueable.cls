public class LeadQueueable implements Queueable, Database.AllowsCallouts {

    private List<Lead> leadsToInsert;

    public LeadQueueable(List<Lead> leads) {
        this.leadsToInsert = leads;
    }

    public void execute(QueueableContext context) {
        try {
            List<Lead> leadsToUpdate = new List<Lead>();
            List<Lead> leadsToInsertFinal = new List<Lead>();
            Set<Id> leadIdsToUpdate = new Set<Id>();

            // Consulta para buscar todas as roletas, ativas e inativas
            List<RoletaLeads__c> roletaList = [SELECT Id, HoraInicio__c, Ativa__c FROM RoletaLeads__c 
            WHERE CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone'];

            if (roletaList.isEmpty()) {
                System.debug('Nenhuma roleta encontrada.');
                return; // Caso não haja roletas, sai da execução
            }

            // Para simplificar, considera-se que a primeira roleta ativa é a preferencial para ser atribuída
            RoletaLeads__c roletaAtiva = null;
            List<RoletaLeads__c> roletasInativas = new List<RoletaLeads__c>();

            // Separando as roletas ativas e inativas
            for (RoletaLeads__c roleta : roletaList) {
                if (roleta.Ativa__c) {
                    roletaAtiva = roleta; // Atribui a roleta ativa
                    break; // Considera a primeira roleta ativa encontrada
                } else {
                    roletasInativas.add(roleta); 
                }
            }

            if (roletaAtiva == null && !roletasInativas.isEmpty()) {
                // Variável para armazenar a roleta inativa válida
                RoletaLeads__c roletaValida = null;
            
                Datetime horaAtual = System.now();  // Obtém a data e hora atual como Datetime
                Time horaAtualTime = horaAtual.time(); // Extrai a parte do tempo
            
                System.debug('Hora atual: ' + horaAtualTime);
            
                // Percorre todas as roletas inativas
                for (RoletaLeads__c roleta : roletasInativas) {
                    Time horaInicio = roleta.HoraInicio__c;
                    System.debug('Hora de início da roleta ' + roleta.Id + ': ' + horaInicio);
            
                    // Verifica se a hora de início da roleta é superior à hora atual
                    if (horaAtualTime < horaInicio) {
                        roletaValida = roleta;  // A roleta inativa é válida
                        break;  // Sai do loop assim que encontrar a primeira roleta válida
                    }
                }
            
                // Se uma roleta válida for encontrada, atribui como roleta ativa
                if (roletaValida != null) {
                    roletaAtiva = roletaValida;
                    System.debug('Roleta ativa definida: ' + roletaAtiva.Id);
                } else {
                    List<RoletaLeads__c> roletas = [
                        SELECT Id, HoraInicio__c 
                        FROM RoletaLeads__c 
                        WHERE Ativa__c = false 
                        AND CanaisAtendimento__c = 'Fale conosco;Chat;WhatsApp;Telefone' 
                        ORDER BY HoraInicio__c ASC
                    ];                
                    if (!roletas.isEmpty()) {
                        roletaAtiva = roletas[0];
                    } else {
                        System.debug('Nenhuma roleta encontrada para os critérios fornecidos.');
                    }
                    System.debug('Nenhuma roleta com hora futura encontrada, usando a primeira roleta inativa.');
                }
            }
            
            
            List<ParticipanteRoleta__c> participantes = [SELECT Id FROM ParticipanteRoleta__c WHERE RoletaLeads__c = :roletaAtiva.Id AND Situacao__c = 'Online' LIMIT 1];

            if (participantes.isEmpty()) {
                for (Lead lead : leadsToInsert) {
                    lead.hasPendingLead__c = true; 
                }
                System.debug('Nenhum participante online. Leads marcados como pendentes.');
            } else {
                System.debug('Participante online encontrado. Distribuição pode continuar.');
            }

            // Processando os leads
            for (Lead lead : leadsToInsert) {
                if (lead.CanalAtendimento__c == 'Telefone' || lead.CanalAtendimento__c == 'Fale conosco' || lead.CanalAtendimento__c == 'Whatsapp') {
                    lead.RoletaLeads__c = roletaAtiva.Id;
                }

                if (lead.Id != null && !leadIdsToUpdate.contains(lead.Id)) {
                    leadsToUpdate.add(lead);  
                    leadIdsToUpdate.add(lead.Id);
                } else {
                    leadsToInsertFinal.add(lead);
                }
            }

            if (!leadsToInsertFinal.isEmpty()) {
                insert leadsToInsertFinal;
            }

            if (!leadsToUpdate.isEmpty()) {
                update leadsToUpdate;
            }

        } catch (DmlException e) {
            System.debug('Falha ao inserir ou atualizar leads: ' + e.getMessage());
            throw new CustomException('Erro ao inserir ou atualizar leads: ' + e.getMessage());
        } catch (Exception e) {
            // Captura de exceção genérica
            System.debug('Erro inesperado ao processar o batch: ' + e.getMessage());
            throw new CustomException('Erro inesperado: ' + e.getMessage());
        }
    }
}