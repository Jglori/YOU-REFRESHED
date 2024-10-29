trigger ContractTrigger on Contract (after update) {
    new ContractTriggerHandler().run();
}