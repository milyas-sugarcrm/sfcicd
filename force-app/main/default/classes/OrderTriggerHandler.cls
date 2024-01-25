public class OrderTriggerHandler {
  List<Order> triggerNew;
  Map<Id, Order> triggerOldMap;
  Map<Id, Order> triggerNewMap;

  public OrderTriggerHandler(
    List<Order> triggerNew,
    Map<Id, Order> triggerOldMap,
    Map<Id, Order> triggerNewMap
  ) {
    this.triggerNew = triggerNew;
    this.triggerOldMap = triggerOldMap;
    this.triggerNewMap = triggerNewMap;
  }

  public void beforeInsert() {
    OrderTriggerService.OrderProcess(triggerNew, true); //replacement of process builder "Order Processes"
    OrderTriggerService.setBalanceDue(triggerNew);
    OrderTriggerService.setPriceBook(triggerNew);
    OrderTriggerService.setOrderStage(triggerNew, triggerOldMap);
    OrderTriggerService.setQBOInstanceDetails(triggerNew);
    OrderTriggerService.updateWONotesAndPriority(triggerNew);
    OrderTriggerService.orderStatusChanged(triggerNew, triggerOldMap);
    OrderTriggerService.OrderFillArtApproval(triggerNew); //replacement of process builder "Set Art Approval Email/Billing Contact - WO"
    OrderTriggerService.UpdateOrderOwner(triggerNew); //replacement of process builder "Set Work Order Owner"
  }
  public void afterInsert() {
    // OrderTriggerService.updateWorkOrderAmount(triggerNew);
    OrderTriggerService.syncInvoiceAmount(triggerNew);
    OrderTriggerService.addProducts(triggerNew);
    //OrderTriggerService.markInvoicesPaid(triggerNew);
    if (!system.isBatch() && !System.isFuture()) {
      OrderTriggerService.changeTheStageOfOpportunity(triggerNew, null);
    } else if (System.isFuture()) {
      OrderTriggerService.changeTheStageOfOpportunity(triggerNew, null);
    }
  }
  public void afterUpdate() {
    OrderTriggerService.syncInvoiceAmount(triggerNew, triggerOldMap);
    OrderTriggerService.sendWorkOrderEmailNotifications(
      triggerNew,
      triggerOldMap
    );
    OrderTriggerService.generatePDF(triggerNew, triggerOldMap);
    OrderTriggerService.checkAndUpdateStatusOfOutdatedCheckbox(
      triggerNew,
      triggerOldMap
    );
    OrderTriggerService.updateShippingDetails(
      triggerNew,
      triggerOldMap,
      triggerNewMap
    );
    OrderTriggerService.updateWOSyncStatusOnInvoiceChange(
      triggerNew,
      triggerOldMap
    );
    //OrderTriggerService.markInvoicesPaid(triggerNew);
    if (!system.isBatch() && !System.isFuture()) {
      OrderTriggerService.UpdateInvoiceInQBO(triggerNew, triggerOldMap);
    }
  }

  public void beforeDelete() {
    OrderTriggerService.deleteOppLineItemsRelatedToWorkOrder(
      triggerNew,
      triggerOldMap
    );
    OrderTriggerService.deleteQboRecords(triggerNew, triggerOldMap);
  }

  public void afterDelete() {
    OrderTriggerService.deletePDF(triggerNew, triggerOldMap);
  }

  public void beforeUpdate() {
    OrderTriggerService.OrderProcess(triggerNew, false); //replacement of process builder "Order Processes"
    OrderTriggerService.setBalanceDue(triggerNew);
    OrderTriggerService.setOrderStage(triggerNew, triggerOldMap);
    OrderTriggerService.retainOldOwnerOfWorkOrder(triggerNew, triggerOldMap);
    OrderTriggerService.setQBOInstanceDetails(triggerNew);
    OrderTriggerService.checkFunctionalOrder(triggerNew);
    OrderTriggerService.restrictToChangeStageofWorkOrder(
      triggerNew,
      triggerOldMap
    );
    OrderTriggerService.orderStatusChanged(triggerNew, triggerOldMap); //replacement of process builder "stage time limit alerts"
  }
}
