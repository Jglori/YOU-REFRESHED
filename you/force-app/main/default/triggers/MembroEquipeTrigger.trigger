trigger MembroEquipeTrigger on MembroEquipe__c (before insert) {
	new MembroEquipeTriggerHandler().run();
}