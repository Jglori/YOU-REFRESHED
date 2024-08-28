List<SeriePagamentos__c> unidades = [SELECT id, Name, TabelaVenda__c FROM SeriePagamentos__c WHERE TabelaVenda__c = 'a0Gbe0000009kMzEAI'];
System.debug(unidades[0]);
