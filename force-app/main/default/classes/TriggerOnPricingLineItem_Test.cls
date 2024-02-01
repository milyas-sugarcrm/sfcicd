@isTest
public class TriggerOnPricingLineItem_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('test', 'test', 'test', 'test');
    testFactory.createEstimate();
    testFactory.createProducts();
    //testFactory.createSalesOrder();
    //System.Test.startTest();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    // System.Test.stopTest();
  }
  @isTest
  public static void testcheckAndUpdateStatusOfOutdatedCheckbox() {
    //TriggerOnPricingLineItemService_Test.testfunction();
  }
}
