trigger LeadConversionTrigger on Lead (before update) {
    List<Lead> convertedLeads = new List<Lead>();
    for (Lead lead : Trigger.new) {
        if (lead.IsConverted && !Trigger.oldMap.get(lead.Id).IsConverted) {
            lead.DataConversao__c = System.now();
        }
    }
}