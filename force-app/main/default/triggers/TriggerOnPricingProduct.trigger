trigger TriggerOnPricingProduct on Pricing_Product__c(before insert) {
  TriggerOnPricingProductHandler handler = new TriggerOnPricingProductHandler(
    Trigger.new,
    Trigger.oldMap
  );

  if (Trigger.isBefore) {
    handler.beforeInsert();
  }
}
