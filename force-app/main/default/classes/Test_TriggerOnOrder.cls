@isTest
public class Test_TriggerOnOrder {
  @testSetup
  public static void populateData() {
    Test_OrderTriggerService.populateData();
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
  }
}
