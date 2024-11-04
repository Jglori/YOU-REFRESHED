trigger ContractTrigger on Contract (after update, before update) {
    new ContractTriggerHandler().run();
}