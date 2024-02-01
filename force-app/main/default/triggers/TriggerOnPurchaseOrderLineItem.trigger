trigger TriggerOnPurchaseOrderLineItem on PurchaseOrder_LineItem__c(
  before insert,
  before update,
  before delete,
  after update,
  after delete
) {
  PurchaseOrderLineItemTriggerHandler handler = new PurchaseOrderLineItemTriggerHandler(
    Trigger.new,
    Trigger.oldMap
  );
  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      handler.beforeInsert();
    }
    if (Trigger.isUpdate) {
      handler.beforeUpdate();
    }
    if (Trigger.isDelete) {
      handler.beforeDelete();
    }
  }
  if (Trigger.isAfter) {
    if (Trigger.isUpdate) {
      handler.afterUpdate();
    }
    if (Trigger.isDelete) {
      handler.afterDelete();
    }
  }
}
