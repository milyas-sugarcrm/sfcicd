trigger TriggerOnFixedCharges on OpportunityLineItem_Add_Fixed_Charge__c(
  after update
) {
  if (System.Label.Triggers == 'True') {
    TriggerOnFixedChargesHandler handler = new TriggerOnFixedChargesHandler(
      Trigger.new,
      Trigger.oldMap
    );

    if (Trigger.isAfter) {
      if (Trigger.isUpdate) {
        handler.afterUpdate();
      }
    }
  }

}
