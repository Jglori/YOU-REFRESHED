trigger AtualizarFaseLead on Event (after update) {
    // Set<Id> leadIds = new Set<Id>();
    // for (Event visita : Trigger.new) {
    //     if (visita.Status_do_Compromisso__c == 'Realizada com Sucesso') {
    //         leadIds.add(visita.WhoId);
    //     }
    // }

    // List<Lead> leadsToUpdate = [SELECT Id, Status FROM Lead WHERE Id IN :leadIds AND Status = 'Agendamento de Visita'];
    // for (Lead lead : leadsToUpdate) {
    //     lead.Status = 'Qualificação';
    // }

    // update leadsToUpdate;
}