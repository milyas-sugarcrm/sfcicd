@istest
public class Test_EstimateTriggerHandler {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('test', 'test', 'test', 'test');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    Test.startTest();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    Test.stopTest();
  }

  @istest
  public static void testDeleteOppLineItemsRelatedToEstimate() {
    Test_EstimateTriggerService.testDeleteOppLineItemsRelatedToEstimate();
  }
}
