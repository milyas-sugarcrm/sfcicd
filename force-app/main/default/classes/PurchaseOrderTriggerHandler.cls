public class PurchaseOrderTriggerHandler {
  List<PurchaseOrder__c> neworder;
  Map<Id, PurchaseOrder__c> oldOrdre;
  public PurchaseOrderTriggerHandler(
    List<PurchaseOrder__c> newValues,
    Map<Id, PurchaseOrder__c> oldValues
  ) {
    neworder = newValues;
    oldOrdre = oldValues;
  }
  public void afterInsert() {
    if (!system.isBatch() && !System.isFuture()) {
      PurchaseOrderTriggerService.changeTheStageOfOpportunity(neworder);
    }
  }
}
