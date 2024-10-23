trigger RegistrarValorOriginal on Lead (before insert, before update) {
    // for (Lead obj : Trigger.new) {
    //     if (obj.MidiaOriginal__c == null) {
    //         obj.MidiaOriginal__c = obj.LeadSource;
    //     }
    //     if (!Schema.sObjectType.Lead.fields.MidiaOriginal__c .isUpdateable()) {
    //         obj.MidiaOriginal__c .addError('Field is read-only and cannot be modified.');
    //     }
    // }
}