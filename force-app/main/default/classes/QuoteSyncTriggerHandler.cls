public class QuoteSyncTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        QuoteSyncHelper.BeforeInsertOrUpdate(Trigger.new);
    }

    public override void beforeUpdate() {
        QuoteSyncHelper.BeforeInsertOrUpdate(Trigger.new);
    }
}