@isTest
public class Test_OrderTriggerHandler {
  @testSetup
  public static void populateData() {
    Test_OrderTriggerService.populateData();
  }

  @isTest
  public static void testChangeStageofWorkOrder() {
    Test_OrderTriggerService.ChangeStageofWorkOrder();
  }

  @isTest
  public static void testWorkOrderProductLineItemCreation() {
    Test_OrderTriggerService.testWorkOrderProductLineItemCreation();
  }

  @isTest
  public static void testWorkOrderEmailNotificationsOnStatusUpdates() {
    Test_OrderTriggerService.testWorkOrderEmailNotificationsOnStatusUpdates();
  }

  @isTest
  public static void testdeleteOppLineItemsRelatedToWorkOrder() {
    Test_OrderTriggerService.testdeleteOppLineItemsRelatedToWorkOrder();
  }

  @isTest
  public static void testRetainOldOwnerOfWorkOrder() {
    Test_OrderTriggerService.testRetainOldOwnerOfWorkOrder();
    List<Order> workOrders = [SELECT id, Primary_Contact__c FROM Order LIMIT 1];
    if (workOrders != null)
      delete workOrders;
  }

  @isTest
  public static void testgeneratePDF() {
    Test_OrderTriggerService.generatePDF();
  }

  @isTest
  public static void testMarkInvoicesPaid() {
    Test_OrderTriggerService.markInvoicesPaid();
  }
}
