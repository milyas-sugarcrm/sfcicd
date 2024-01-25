@istest
public class Test_TriggerOnPurchaseOrder {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('test', 'test', 'test', 'test');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
  }

  @istest
  public static void testChangeTheStageOfOpportunity() {
    Test.startTest();
    PurchaseOrder__c order = new PurchaseOrder__c();
    order.Opportunity__c = [SELECT id FROM Opportunity LIMIT 1].id;
    insert order;
    Test.stopTest();
  }
}
