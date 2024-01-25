trigger TriggerOnPricingLineItem on PricingLineItem__c(
  before update,
  before insert,
  before delete,
  after update,
  after insert,
  after delete
) {
  if (System.Label.Triggers == 'True') {
    TriggerOnPricingLineItemHandler handler = new TriggerOnPricingLineItemHandler(
      Trigger.new,
      Trigger.oldMap
    );
    if (Trigger.isAfter) {
      if (Trigger.isInsert) {
        handler.afterInsert();
      }
      if (Trigger.isUpdate) {
        handler.afterUpdate();
      }
    }
    if (Trigger.isBefore) {
      if (Trigger.isUpdate) {
        handler.beforeUpdate();
      }
      if (Trigger.isDelete) {
        handler.beforeDelete();
      }
      if (Trigger.isInsert) {
        handler.beforeInsert();
      }
    }
  }
}
