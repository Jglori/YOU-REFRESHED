trigger ValidateConjugeCompanheiroTrigger on OpportunityContactRole (before insert, before update) {
    new AccountContactRelationTriggerHandler().run();
    
    Map<Id, Integer> accountContactRoleCount = new Map<Id, Integer>();

    for (OpportunityContactRole ocr : [SELECT OpportunityId, Role FROM OpportunityContactRole WHERE Role = 'Cônjuge/Companheiro']) {
        if (accountContactRoleCount.containsKey(ocr.OpportunityId)) {
            accountContactRoleCount.put(ocr.OpportunityId, accountContactRoleCount.get(ocr.OpportunityId) + 1);
        } else {
            accountContactRoleCount.put(ocr.OpportunityId, 1);
        }
    }

    for (OpportunityContactRole ocr : Trigger.new) {
        if (ocr.Role == 'Cônjuge/Companheiro' && accountContactRoleCount.containsKey(ocr.OpportunityId) && accountContactRoleCount.get(ocr.OpportunityId) >= 1) {
            ocr.addError('A Person Account só pode ter um relacionamento do tipo "Cônjuge/Companheiro".');
        } else if (ocr.Role == 'Cônjuge/Companheiro') {
            if (accountContactRoleCount.containsKey(ocr.OpportunityId)) {
                accountContactRoleCount.put(ocr.OpportunityId, accountContactRoleCount.get(ocr.OpportunityId) + 1);
            } else {
                accountContactRoleCount.put(ocr.OpportunityId, 1);
            }
        }
    }
}