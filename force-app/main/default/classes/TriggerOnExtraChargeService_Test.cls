@isTest
public class TriggerOnExtraChargeService_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('test', 'test', 'test', 'test');
    testFactory.createEstimate();
    testFactory.createProducts();
    // testFactory.createSalesOrder();
    System.Test.startTest();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    System.Test.stopTest();
  }
  @isTest
  public static void testcheckAndUpdateStatusOfOutdatedCheckbox() {
    Test.startTest();
    ExtraChargesEstimate__c pricing = [
      SELECT Id, Margin__c, Duty_Percentage__c, Title__c, Net_Cost__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];
    pricing.Margin__c = 100;
    pricing.Duty_Percentage__c = 10;
    pricing.Title__c = 'test title';
    pricing.Net_Cost__c = 10;
    update pricing;
    delete pricing;
    Test.stopTest();
  }
}
