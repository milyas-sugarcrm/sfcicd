public class PurchaseOrderLineItemTriggerHandler {
  List<PurchaseOrder_LineItem__c> newPurchaseOrder;
  Map<Id, PurchaseOrder_LineItem__c> oldPurchaseOrder;
  public PurchaseOrderLineItemTriggerHandler(
    List<PurchaseOrder_LineItem__c> newValues,
    Map<Id, PurchaseOrder_LineItem__c> oldValues
  ) {
    newPurchaseOrder = newValues;
    oldPurchaseOrder = oldValues;
  }

  public void beforeInsert() {
    PurchaseOrderLineItemTriggerService.linkCheckPBRunOnce(newPurchaseOrder);
    UpdatePurchaseOrderAccount.SetVendorBillingEmail(newPurchaseOrder); // part of Process Builder - Purchase Order Status Change Notifications converted to this method
    UpdatePurchaseOrderAccount.SetAccountId(newPurchaseOrder); // Process Builder - Update Purchase Order Account converted to this method
  }
  public void beforeUpdate() {
    UpdatePurchaseOrderAccount.SetAccountId(newPurchaseOrder); // Process Builder - Update Purchase Order Account converted to this method
    UpdatePurchaseOrderAccount.SetVendorBillingEmail(newPurchaseOrder); // part of Process Builder - Purchase Order Status Change Notifications converted to this method
    PurchaseOrderLineItemTriggerService.changeStatusOfPO(
      newPurchaseOrder,
      oldPurchaseOrder
    );
    PurchaseOrderLineItemTriggerService.calculateCostFinancials(
      newPurchaseOrder,
      oldPurchaseOrder
    );
    PurchaseOrderLineItemTriggerService.linkCheckPBRunOnce(newPurchaseOrder);
  }
  public void afterUpdate() {
    PurchaseOrderLineItemTriggerService.updatePurchaseOrderinQBO(
      newPurchaseOrder,
      oldPurchaseOrder
    );
  }
  public void beforeDelete() {
    PurchaseOrderLineItemTriggerService.deleteBillfromQBO(oldPurchaseOrder);
    PurchaseOrderLineItemTriggerService.removePoPDF(
      newPurchaseOrder,
      oldPurchaseOrder
    );
  }

  public void afterDelete() {
    PurchaseOrderLineItemTriggerService.reCalculateWOCostFinancials(
      oldPurchaseOrder
    );
  }
}
