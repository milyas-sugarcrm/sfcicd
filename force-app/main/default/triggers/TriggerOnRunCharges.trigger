trigger TriggerOnRunCharges on Line_Item_Pricing_RunCharge__c(after update) {
  if (System.Label.Triggers == 'True') {
    TriggerOnRunChargesHandler handler = new TriggerOnRunChargesHandler(
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
