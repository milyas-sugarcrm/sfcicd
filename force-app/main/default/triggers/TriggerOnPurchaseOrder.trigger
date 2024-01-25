trigger TriggerOnPurchaseOrder on PurchaseOrder__c(after insert) {
  PurchaseOrderTriggerHandler handler = new PurchaseOrderTriggerHandler(
    Trigger.new,
    Trigger.oldMap
  );
  if (Trigger.isAfter) {
    if (Trigger.isInsert) {
      handler.afterInsert();
    }
  }
}
