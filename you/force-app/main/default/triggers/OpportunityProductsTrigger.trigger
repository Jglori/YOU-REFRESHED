trigger OpportunityProductsTrigger on OpportunityLineItem (before delete)  {
    new OpportunityProductsTriggerHandler().run();
}