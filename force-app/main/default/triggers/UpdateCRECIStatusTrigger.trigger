trigger UpdateCRECIStatusTrigger on Contact (before insert, before update) {
    CRECIStatusHandler.updateCRECIStatus(Trigger.new);
}