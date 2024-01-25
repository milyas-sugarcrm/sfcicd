@istest
public class Test_TriggerOnEstimate {
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
  public static void testChangeTheStageOfOpportunity() {
    //  Test_EstimateTriggerService.testChangeTheStageOfOpportunity();
  }

  @istest
  public static void testDeleteOppLineItemsRelatedToEstimate() {
    Test_EstimateTriggerService.testDeleteOppLineItemsRelatedToEstimate();
  }

  @isTest
  public static void testcheckAndUpdateStatusOfOutdatedCheckbox() {
    Test_EstimateTriggerService.testcheckAndUpdateStatusOfOutdatedCheckbox();
  }
}
