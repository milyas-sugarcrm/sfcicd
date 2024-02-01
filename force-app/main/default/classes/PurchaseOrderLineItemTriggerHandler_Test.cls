@isTest
public class PurchaseOrderLineItemTriggerHandler_Test {
  @isTest
  static void testBeforeInsert() {
    PurchaseOrder_LineItem__c Testobj = new PurchaseOrder_LineItem__c(
      Production_Rep__c = 'Test'
    );
    insert Testobj;
  }
}
