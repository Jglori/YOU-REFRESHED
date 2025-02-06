trigger ContractTrigger on Contract (before insert, before update) {
    new ContractTriggerHandler().run();
}