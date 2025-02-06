public with sharing class AccountContactRelationHelper {
    
    public static void processBeforeInsert(List<OpportunityContactRole> newRecords) {
        Set<Id> opportunityIds = collectOpportunityIds(newRecords);
        
        validateOpportunityPercentages(opportunityIds);
        // validateSpouseRelationship(newRecords, null);
    }
    
    public static void processBeforeUpdate(List<OpportunityContactRole> newRecords, Map<Id, OpportunityContactRole> oldMap) {
        Set<Id> opportunityIds = collectOpportunityIds(newRecords);
        
        validateOpportunityPercentages(opportunityIds);
        // validateSpouseRelationship(newRecords, oldMap);
    }
    
    private static Set<Id> collectOpportunityIds(List<OpportunityContactRole> records) {
        Set<Id> opportunityIds = new Set<Id>();
        
        for (OpportunityContactRole ocr : records) {
            List<OpportunityContactRole> ocrList = [
                SELECT OpportunityId 
                FROM OpportunityContactRole 
                WHERE ContactId = :ocr.ContactId
            ];
            
            for (OpportunityContactRole ocrr : ocrList) {
                opportunityIds.add(ocrr.OpportunityId);
            }
        }
        
        return opportunityIds;
    }
    
    public static void validateOpportunityPercentages(Set<Id> opportunityIds) {
        if (opportunityIds.isEmpty()) {
            return;
        }
    
        Map<Id, Decimal> opportunityPercentMap = new Map<Id, Decimal>();
    
        List<OpportunityContactRole> relatedRoles = [
            SELECT Id, OpportunityId, PorcentagemParticipacao__c
            FROM OpportunityContactRole
            WHERE OpportunityId IN :opportunityIds
        ];
    
        for (OpportunityContactRole ocr : relatedRoles) {
            Decimal currentTotal = opportunityPercentMap.get(ocr.OpportunityId);
            if (currentTotal == null) {
                currentTotal = 0;
            }
            currentTotal += (ocr.PorcentagemParticipacao__c != null ? ocr.PorcentagemParticipacao__c : 0);
            opportunityPercentMap.put(ocr.OpportunityId, currentTotal);
        }
    
        for (SObject obj : Trigger.new) {
            OpportunityContactRole newOCR = (OpportunityContactRole) obj;
            Decimal updatedTotal = opportunityPercentMap.get(newOCR.OpportunityId);
            if (updatedTotal == null) {
                updatedTotal = 0;
            }
    
            if (Trigger.isUpdate && Trigger.oldMap.containsKey(newOCR.Id)) {
                OpportunityContactRole oldOCR = (OpportunityContactRole) Trigger.oldMap.get(newOCR.Id);
                updatedTotal -= (oldOCR.PorcentagemParticipacao__c != null ? oldOCR.PorcentagemParticipacao__c : 0);
            }
    
            updatedTotal += (newOCR.PorcentagemParticipacao__c != null ? newOCR.PorcentagemParticipacao__c : 0);
            opportunityPercentMap.put(newOCR.OpportunityId, updatedTotal);
        }
    
        for (Id oppId : opportunityPercentMap.keySet()) {
            Decimal totalPercent = opportunityPercentMap.get(oppId);
            if (totalPercent != null && totalPercent > 100) {
                for (SObject obj : Trigger.new) {
                    OpportunityContactRole ocr = (OpportunityContactRole) obj;
                    if (ocr.OpportunityId == oppId) {
                        ocr.addError('A soma das porcentagens dos contatos ultrapassa 100% na oportunidade.');
                    }
                }
            }
        }
    }
}