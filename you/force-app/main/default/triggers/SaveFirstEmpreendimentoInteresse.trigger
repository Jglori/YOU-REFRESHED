trigger SaveFirstEmpreendimentoInteresse on Lead (before insert) {
    for (Lead newRecord : Trigger.new) {
        if (newRecord.PrimeiroEmpreendimento__c == null) {
            newRecord.PrimeiroEmpreendimento__c = newRecord.EmpreendimentoInteresse__c;
        }
    }
}