public with sharing class EventTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        EventHelper.validateLeadStatus((List<Event>) Trigger.new);
        EventHelper.validateEventDate(Trigger.new);
    }
    
    public override void beforeUpdate() {
        EventHelper.validateLeadStatus((List<Event>) Trigger.new);
        EventHelper.validateEventDate(Trigger.new);
    }

    public override void afterInsert() {
        EventHelper.validateEventStatus(Trigger.new);   
    }

    public override void afterUpdate(){
        EventHelper.validateEventStatus(Trigger.new);
    }
}